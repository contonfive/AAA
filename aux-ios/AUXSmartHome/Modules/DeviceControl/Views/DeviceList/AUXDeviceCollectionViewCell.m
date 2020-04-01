/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXDeviceCollectionViewCell.h"
#import "AUXDefinitions.h"
#import "AUXDeviceInfo.h"
#import "AUXConfiguration.h"
#import "AUXUser.h"

#import "AUXTimerObject.h"
#import "AUXNetworkManager.h"
#import "UIColor+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "AUXDeviceStateInfo.h"
#import "AUXTimerObject.h"


#define kDeleteBtnWidth (self.bounds.size.width * 0.2)
@interface AUXDeviceCollectionViewCell()<AUXACDeviceProtocol , UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL hasControlSecondsBefore; // 控制设备3s内，忽略设备状态上报
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSTimer *oldDeviceTimer;
@end

@implementation AUXDeviceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initSubviews];
    
    self.offline = NO;
    self.hasRoomTemperature = YES;
    self.hasFault = NO;
    self.powerOn = NO;
    self.backView.userInteractionEnabled = YES;
    
//    NSTimer *timer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:1.0 target:self selector:@selector(timeFetFaultList) userInfo:nil repeats:YES];
//    self.timer = timer;
    
    [self hideFaultInfo];

}

- (void)initSubviews {
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = [UIColor colorWithHex:0xEAEAEA].CGColor;
}

- (void)timeFetFaultList {
    if (self.deviceInfo) {
        [self getFaultList];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateUI {
    
    if (self.hasFault) {
        [self updateFaultUI];
    } else {
        [self hideFaultInfo];
    }
}

- (void)updateTemperature {

    if (self.offline) {
        return ;
    }
    
    if (!self.powerOn) {
        return ;
    }
    
    CGFloat temperature = 0.0;
    if (self.powerOn) {
        
        temperature = self.deviceStatus.temperature;
        if (self.deviceStatus.mode == AirConFunctionVentilate) {
            
            if (!self.hasRoomTemperature) {
                self.temperatureLabel.text = @"--";
                return;
            }
            temperature = self.roomTemperature;
            
            self.temperatureLabel.text = [NSString stringWithFormat:@"%.1f°C" , temperature];
            return ;
        }
    }
    
    NSInteger nTemperature = (NSInteger)temperature;
    NSString *temperatureText = [NSString stringWithFormat:@"%ld%@°C" , nTemperature , ((temperature - nTemperature) == 0) ? @".0" : @".5"];
    self.temperatureLabel.text = temperatureText;
}

- (UIColor *)modeColor {
    if (self.offline) {
        return [UIColor whiteColor];
    }
    
    UIColor *color;
    switch (self.deviceStatus.mode) {
        case AirConFunctionCool:
        case AirConFunctionDehumidify:
            color = [UIColor colorWithHex:0x2C67FF];
            break;
        case AirConFunctionHeat:
            color = [UIColor colorWithHex:0xFFB93D];
            break;
        case AirConFunctionAuto:
        case AirConFunctionVentilate:
            color = [UIColor colorWithHex:0x10BFCA];
            break;
        default:
            break;
    }
    return color;
}

#pragma mark getter
- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}

#pragma mark - Setters
- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    
    _deviceInfo = deviceInfo;
    
    if (_deviceInfo) {
        self.hasFault = NO;
        
        self.deviceNameLabel.text = self.deviceInfo.alias;
        [self.deviceImageView sd_setImageWithURL:[NSURL URLWithString:self.deviceInfo.deviceMainUri]];
        
        self.deviceStatus = (AUXDeviceStatus *)[[AUXDeviceStatus alloc] initWithGearType:_deviceInfo.windGearType];
        
        AUXACDevice *device = self.deviceDictionary[_deviceInfo.deviceId];
        AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
        AUXACStatus *deviceACStatus = device.statusDic[kAUXACDeviceAddress];

        _deviceInfo.device = device;
        [_deviceInfo.device.delegates addObject:self];
        _deviceInfo.addressArray = @[kAUXACDeviceAddress];
        
        self.hasRoomTemperature = _deviceInfo.deviceFeature.hasRoomTemperature;
        
        if (!device || !deviceControl) {  // SDK未找到对应的设备
            self.offline = YES;
            self.hasFault = NO;
        } else {
            self.offline = (device.wifiState != AUXACNetworkDeviceWifiStateOnline) ? YES : NO;
        }
        
        AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
        
        BOOL iscontain = [deviceStateinfo.dataArray containsObject:deviceInfo.deviceId];
        if (!self.offline) {
            if (iscontain) {
                [deviceStateinfo.dataArray removeObject:deviceInfo.deviceId];
                [deviceStateinfo.dataArray addObject:deviceInfo.deviceId];
            }else{
                [deviceStateinfo.dataArray addObject:deviceInfo.deviceId];
            }
        }else{
            if (iscontain) {
                [deviceStateinfo.dataArray removeObject:deviceInfo.deviceId];
            }
        }
        if (deviceControl) {
            [self.deviceStatus updateWithControl:deviceControl];
            self.deviceStatus.powerOn = deviceControl.onOff;
            self.powerOn = self.deviceStatus.powerOn;
        }
        
        if (deviceACStatus) {
            
            if (deviceACStatus.roomTemperatureDecimal >= 100) {
                deviceACStatus.roomTemperatureDecimal = (CGFloat)deviceACStatus.roomTemperatureDecimal / 100;
            } else if (deviceACStatus.roomTemperatureDecimal >= 10) {
                deviceACStatus.roomTemperatureDecimal = (CGFloat)deviceACStatus.roomTemperatureDecimal / 10;
            }
            
            self.roomTemperature = (CGFloat)deviceACStatus.roomTemperature + (CGFloat)deviceACStatus.roomTemperatureDecimal / 10;
            deviceACStatus.fault = [deviceACStatus getFault];
            
            if (deviceACStatus.fault) {
                self.hasFault = YES;
                [self updateUIWithFaultCode:deviceACStatus.fault.code faultMessage:nil faultId:nil];
            } else {
                [self hideFaultInfo];
            }
        }
    }
    [self updateUI];
}

#pragma mark - Actions
- (void)powerOnAction:(id)sender {
    if (self.offline) {
        if (self.sendControlError) {
            self.sendControlError(@"设备离线，无法控制");
        }
        return ;
    }
    
    BOOL powerOn = YES;
    [self controlDeviceWithPower:powerOn];
}

- (void)powerOffAtcion:(id)sender {
    
    if (self.offline) {
        if (self.sendControlError) {
            self.sendControlError(@"设备离线，无法控制");
        }
        return ;
    }
    
    BOOL powerOn = NO;
    [self controlDeviceWithPower:powerOn];
}
- (void)heatUpAtcion:(id)sender {
    
    if (self.deviceStatus.childLock) {
        if (self.sendControlError) {
            self.sendControlError(@"空调处于锁定状态，解锁之后才能进行相应操作");
        }
        return ;
    }
    
    if (self.deviceStatus.sleepDIY) {
        if (self.sendControlError) {
            self.sendControlError(@"请关闭睡眠DIY后进行操作");
            return ;
        }
    }
    
    if (self.deviceStatus.mode == AirConFunctionAuto) {
        if (self.sendControlError) {
            self.sendControlError(@"自动模式不能设置温度");
        }
        return ;
    }
    
    if (self.deviceStatus.mode == AirConFunctionVentilate) {
        if (self.sendControlError) {
            self.sendControlError(@"送风模式不能设置温度");
        }
        return ;
    }
    
    if (self.deviceInfo.deviceFeature.halfTemperature) {
        self.deviceStatus.temperature = self.deviceStatus.temperature + 0.5;
    } else {
        self.deviceStatus.temperature++;
    }
    
    if (self.deviceStatus.temperature <= 32.0) {
        [self controlDeviceWithTemperature:self.deviceStatus.temperature];
    }
    
    if (self.deviceStatus.temperature > 32.0) {
        self.deviceStatus.temperature = 32.0;
        if (self.sendControlError) {
            self.sendControlError(kAUXLocalizedString(@"DeviceControlMaxTem"));
        }
    }
}

- (void)heatDownAtcion:(id)sender {
    
    if (self.deviceStatus.childLock) {
        if (self.sendControlError) {
            self.sendControlError(@"空调处于锁定状态，解锁之后才能进行相应操作");
        }
        return ;
    }
    
    if (self.deviceStatus.sleepDIY) {
        if (self.sendControlError) {
            self.sendControlError(@"请关闭睡眠DIY后进行操作");
        }
        return ;
    }
    
    if (self.deviceStatus.mode == AirConFunctionAuto) {
        if (self.sendControlError) {
            self.sendControlError(@"自动模式不能设置温度");
        }
        return ;
    }
    
    if (self.deviceStatus.mode == AirConFunctionVentilate) {
        if (self.sendControlError) {
            self.sendControlError(@"送风模式不能设置温度");
        }
        return ;
    }
    
    if (self.deviceInfo.deviceFeature.halfTemperature) {
        self.deviceStatus.temperature = self.deviceStatus.temperature - 0.5;
    } else {
        self.deviceStatus.temperature--;
    }
    
    if (self.deviceStatus.temperature >= 16.0) {
        [self controlDeviceWithTemperature:self.deviceStatus.temperature];
    }
    
    if (self.deviceStatus.temperature < 16.0) {
        self.deviceStatus.temperature = 16.0;
        if (self.sendControlError) {
            self.sendControlError(kAUXLocalizedString(@"DeviceControlMinTem"));
        }
    }
}

#pragma mark 命令下发
/// 开关机
- (void)controlDeviceWithPower:(BOOL)powerOn {
    
    __weak typeof(self) weakSelf = self;
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateControl:control withDeviceInfo:deviceInfo onOff:powerOn];
        return YES;
    }];
    
    [self updateStatusWithSDKControl:someControl];
    [self updateUIWithSDKControl:someControl animated:YES];
}

/// 更改温度
- (void)controlDeviceWithTemperature:(CGFloat)temperature {
    
    int nTemperature = temperature;
    BOOL half = (temperature != (NSInteger)temperature);
    
    [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.temperature = nTemperature;
        control.half = half;
        return YES;
    }];
    
    NSString *temperatureText = [NSString stringWithFormat:@"%d%@°C" , nTemperature , ((temperature - nTemperature) == 0) ? @".0" : @".5"];
    self.temperatureLabel.text = temperatureText;
    
}

/**
 控制设备。（更改 AUXACControl 的属性）
 
 @param handler 可以在该block里更改 control 的值。返回YES表示可以控制该设备，NO则不控制设备 (用于集中控制，当某台设备不满足条件时，不下发控制命令；单控可以直接返回YES)。
 @return 某个 AUXACControl 的实例，用于界面更新。
 */
- (AUXACControl *)controlDeviceWithHandler:(BOOL (^)(AUXDeviceInfo *deviceInfo, AUXACControl *control))handler {
    
    // 童锁开启中，不能关机
    if (self.deviceStatus.childLock) {
        if (self.sendControlError) {
            self.sendControlError(@"空调处于锁定状态，解锁之后才能进行相应操作");
        }
        return nil;
    }
    
    // 用于界面更新
    AUXACControl *someControl;
    AUXDeviceInfo *deviceInfo = self.deviceInfo;
    
    if (!deviceInfo.device || deviceInfo.device.wifiState != AUXACNetworkDeviceWifiStateOnline) {
        return nil;
    }
    
    NSString *address = deviceInfo.addressArray.firstObject;
    
    AUXACControl *control = deviceInfo.device.controlDic[address];
    if (handler) {
        handler(deviceInfo, control);
    }
    
    someControl = control;
    
    if (self.showLoadingBlock) {
        self.showLoadingBlock();
    }
    
    if (self.oldDeviceTimer) {
        [self.oldDeviceTimer invalidate];
        self.oldDeviceTimer = nil;
    }
    self.oldDeviceTimer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:DeviceControlCommondMaxTime target:self selector:@selector(invalidateTimer) userInfo:nil repeats:NO];
    
    [self controlDevice:deviceInfo.device controlInfo:control atAddress:address];
    
    return someControl;
}

/// 更新设备控制状态 (集中控制不要调用该方法)
- (void)updateStatusWithSDKControl:(AUXACControl *)deviceControl {
    
    if (!deviceControl) {
        return;
    }
    // 更新状态
    [self.deviceStatus updateWithControl:deviceControl];
}

/// 根据设备控制状态更新UI
- (void)updateUIWithSDKControl:(AUXACControl *)deviceControl animated:(BOOL)animated {
    if (deviceControl) {
        
        BOOL powerOn = deviceControl.onOff;
        // 更新开关机状态
        // 32位系统的手机，传过来的形参 powerOn 不是BOOL类型，会导致多次执行后续的代码
        // 所以这里这样处理。
        BOOL boolPowerOn = (powerOn != 0) ? YES : NO;
        
        if (self.deviceStatus.powerOn == boolPowerOn) {
            return;
        }
        self.deviceStatus.powerOn = boolPowerOn;
        self.powerOn = powerOn;
        
    }
    [self updateUI];
}

- (void)controlDevice:(AUXACDevice *)device controlInfo:(AUXACControl *)control atAddress:(NSString *)address {
    
    if (self.hasControlSecondsBefore) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countdownToUpdateDeviceStatus) object:nil];
    } else {
        // 控制设备之后，3s内忽略设备上报的状态
        self.hasControlSecondsBefore = YES;
    }
    
    [self performSelector:@selector(countdownToUpdateDeviceStatus) withObject:nil afterDelay:3.0];
    [[AUXACNetwork sharedInstance] sendCommand2Device:device controlInfo:control atAddress:address withType:device.deviceType];
}

- (void)countdownToUpdateDeviceStatus {
    // 控制设备之后，3s内忽略设备上报的状态
    self.hasControlSecondsBefore = NO;
}

#pragma mark 互斥逻辑处理
- (void)updateControl:(AUXACControl *)control withDeviceInfo:(AUXDeviceInfo *)deviceInfo onOff:(BOOL)onOff {
    
    // 是否支持电加热
    BOOL supportElectricHeating = [self.deviceInfo.deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncElectricalHeating)];
    
    AUXDeviceSuitType suitType;
    
    if (deviceInfo) {
        suitType = deviceInfo.suitType;
    } else {
        suitType = AUXDeviceSuitTypeAC;
    }
    
    control.onOff = onOff;
    
    if (onOff) {
        // 开机：取消清洁、如为制热模式打开电加热
        control.clean = NO;
        
        // 单元机，制热模式强制开启电加热
        if (supportElectricHeating && suitType == AUXDeviceSuitTypeAC && control.airConFunc == AirConFunctionHeat) {
            control.electricHeating = YES;
        }
    } else {
        // 关机：取消静音、取消强力、取消睡眠、取消电加热、取消ECO、取消健康
        control.silence = NO;
        control.turbo = NO;
        control.sleepMode = NO;
        control.electricHeating = NO;
        control.eco = NO;
        control.healthy = NO;
    }
}

#pragma mark 故障
/// 更新故障信息 (滤网信息)
- (void)updateUIWithFaultList:(NSArray<AUXFaultInfo *> *)faultList {
    
    AUXFaultInfo *filterInfo;
    
    for (AUXFaultInfo *faultInfo in faultList) {
        if ([faultInfo.faultId isEqualToString:kAUXFilterFaultId]) {
            filterInfo = faultInfo;
            break;
        }
    }
    self.deviceStatus.filterInfo = filterInfo;
    
    [self updateUIWithFault:self.deviceStatus.fault filter:filterInfo];
}

- (void)updateUIWithFault:(AUXACNetworkError *)fault filter:(AUXFaultInfo *)filterInfo {
    if (!self.deviceInfo.deviceFeature.hasFault) {
        return;
    }
    
    self.deviceStatus.fault = fault;
    self.deviceStatus.filterInfo = filterInfo;
    
    if (fault) {
        [self updateUIWithFaultCode:fault.code faultMessage:nil faultId:nil];
    } else if (filterInfo) {
        [self updateUIWithFaultCode:0 faultMessage:nil faultId:filterInfo.faultId];
    } else {
        [self hideFaultInfo];
    }
}

- (void)updateUIWithFaultCode:(NSInteger)code faultMessage:(NSString *)faultMessage faultId:(NSString *)faultId {
    
    // 故障代码为 0x0100 的时候，是正常状态，即没有故障
    if (code == 0x0100) {
        [self hideFaultInfo];
        return;
    }

    if (self.offline) {
        [self hideFaultInfo];
        return;
    }
    
    if (faultId && [faultId isEqualToString:kAUXFilterFaultId]) {
        //滤网清洗
        
    } else {
        //发生故障
        [self updateFaultUI];
    }
}

- (void)updateFaultUI {
    
    self.faultImageView.hidden = NO;
    if (self.currentDeviceListType == AUXDeviceListTypeOfList) {
        self.deviceNameLeading.constant = 36;
    } else {
        self.deviceNameLeading.constant = 26;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutIfNeeded];
    });
}

- (void)hideFaultInfo {
    self.faultImageView.hidden = YES;
    
    if (self.currentDeviceListType == AUXDeviceListTypeOfList) {
        self.deviceNameLeading.constant = 16;
    } else {
        self.deviceNameLeading.constant = 10;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutIfNeeded];
    });
}

#pragma mark 网络请求
/// 获取故障列表
- (void)getFaultList {
    
    // 设备不支持故障报警
    if (!self.deviceInfo.deviceFeature.hasFault) {
        return;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfo;
    
    // 旧设备的故障信息附带在设备运行状态里面 (旧设备没有滤网信息)
    if (!deviceInfo.device || deviceInfo.device.bLDevice) {
        return;
    }
    
    // 新设备的故障信息也附带在设备运行状态里面，这里查询服务器，只是为了获取滤网信息。
    [[AUXNetworkManager manager] getFaultListWithMac:deviceInfo.mac completion:^(NSArray<AUXFaultInfo *> * _Nullable faultInfoList, NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self updateUIWithFaultList:faultInfoList];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                if (self.accountCacheExpiredBlock) {
                    self.accountCacheExpiredBlock();
                }
                break;
                
            default:
                break;
        }
    }];
}


- (void)invalidateTimer {
    
    if (self.hideLoadingBlock) {
        self.hideLoadingBlock();
    }
    
    if (self.oldDeviceTimer) {
        [self.oldDeviceTimer invalidate];
        self.oldDeviceTimer = nil;
    }
}

#pragma mark AUXACDeviceProtocol
- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSArray *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type {
    
    if (success) {
        AUXDeviceInfo *deviceInfo = self.deviceInfo;
        
        if (!deviceInfo || deviceInfo.virtualDevice) {
            return;
        }
        
        if (![device isEqual:deviceInfo.device]) {
            return;
        }
        
        NSString *addressString = deviceInfo.addressArray.firstObject;
        
        switch (type) {
            case AUXACNetworkQueryTypeControl: {
                AUXACControl *deviceControl = device.controlDic[addressString];
                
                if (!deviceControl) {
                    break;
                }
                
                // 设备控制若干秒之内忽略设备上报的状态
                if (self.hasControlSecondsBefore) {
                    break;
                }
                
                [self updateStatusWithSDKControl:deviceControl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIWithSDKControl:deviceControl animated:YES];
                });
            }
                break;
            default:
                break;
        }
    }
}

- (void)auxACNetworkDidSendCommandForDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error {
    
    if (self.hideLoadingBlock) {
        self.hideLoadingBlock();
    }
    
    if (!success) {
        if (self.sendControlError) {
            self.sendControlError(@"通信异常，请稍后重试");
        }
    }
}

@end
