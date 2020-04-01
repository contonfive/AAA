//
//  AUXTodayExtensionTableViewCell.m
//  AUXTodayExtension
//
//  Created by AUX Group Co., Ltd on 2018/5/31.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTodayExtensionTableViewCell.h"

#import "AUXUser.h"
#import "AUXDeviceStatus.h"
#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"
#import "AUXNetworkManager.h"

#import <AUXACNetwork/AUXACNetwork.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface AUXTodayExtensionTableViewCell ()
@property (nonatomic, strong) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;  // 设备字典 (key为 deviceId)
@property (nonatomic,strong) AUXDeviceStatus *deviceStatus;// 设备状态 (用于界面更新)
@property (nonatomic, strong) AUXDeviceFeature *deviceFeature;
@property (nonatomic,assign) BOOL offline;
@property (nonatomic,assign) BOOL powerOn;
@property (nonatomic,assign) BOOL hasFault;

@property (nonatomic,strong) NSMutableArray<NSNumber *> *windSpeedArray;;
@property (nonatomic, assign) WindSpeed windSpeed;

@property (nonatomic, assign) BOOL hasControlSecondsBefore; // 控制设备3s内，忽略设备状态上报
@property (nonatomic,assign) AUXDeviceControlType controlType;

@property (nonatomic, strong) AUXACControl *virtualDeviceControl;   // 设备控制状态 (虚拟体验/集中控制)
@property (nonatomic,strong) MBProgressHUD *progressHUD;
@property (nonatomic,strong) MBProgressHUD *transparentProgressHUD;


@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIView *activityViewWithText;

@property (weak, nonatomic) IBOutlet UILabel *activityTextLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWithTextProgress;

@property (nonatomic,assign) BOOL showLoading;

@property (nonatomic,assign) WindGearType windGearType;     //挂机，柜机 风速档位

@end
@implementation AUXTodayExtensionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.offline = NO;
    self.hasFault = NO;
    self.windGearType = WindGearType1;
    
    self.controlBackView.backgroundColor = [[UIColor colorWithHexString:@"737373"] colorWithAlphaComponent:0.06];

    self.virtualDeviceControl = [[AUXACControl alloc] init];
    [self.deviceStatus updateValueForControl:self.virtualDeviceControl];
    
    [self.iconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconImageViewTapAtcion:)]];
    [self.titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titlelabelTapAtcion:)]];
    [self.subTitleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(subTitleTapAtcion:)]];
}

- (void)updateUI {
//    UIImageView *imgView = [[UIImageView alloc]init];
//    [imgView sd_setImageWithURL:imageURL placeholderImage:nil];
//    self.iconImageView.image = [self imageWithImage:imgView.image scaledToSize:CGSizeMake(50, 50)];//压缩图片为50*50像素
    
    NSURL *imageURL = [NSURL URLWithString:self.deviceInfo.deviceMainUri];
    [self.iconImageView sd_setImageWithURL:imageURL placeholderImage:nil];
    self.titleLabel.text = self.deviceInfo.alias;
    
    BOOL powerOffOrOffOnline = (self.offline || !self.powerOn);
    
    if (powerOffOrOffOnline) {
        self.iconImageViewTop.constant = 35;
    } else {
        self.iconImageViewTop.constant = 15;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutIfNeeded];
    });
    
    if (self.offline) {
        self.offOnlineButton.hidden = NO;
        self.powerOnButton.hidden = YES;
        
        self.faultBackView.hidden = YES;
        self.statusBackView.hidden = YES;
        self.controlBackView.hidden = YES;
        
        return ;
    }
    
    if (self.hasFault) {
        self.faultBackView.hidden = NO;
    } else {
        self.faultBackView.hidden = YES;
    }
    
    // 设备已关机
    if (self.powerOn == NO) {
        self.powerOnButton.hidden = NO;
        self.statusBackView.hidden = YES;
        self.controlBackView.hidden = YES;
        self.offOnlineButton.hidden = YES;
        
        return;
    }
    
    if (self.powerOn) {
        self.powerOnButton.hidden = YES;
        self.offOnlineButton.hidden = YES;
        
        self.statusBackView.hidden = NO;
        self.controlBackView.hidden = NO;
    }
    
    if (self.deviceStatus.temperature) {
        self.tempretureLabel.text = [NSString stringWithFormat:@"%.1f°C" , self.deviceStatus.temperature];
    }
    
    if (self.deviceStatus.mode == AirConFunctionVentilate) {
        self.tempretureLabel.text = [NSString stringWithFormat:@"%.1f°C" , self.deviceStatus.roomTemperature * 1.0];
    }
    
    self.modelLabel.text = [AUXConfiguration getModeName:self.deviceStatus.mode];
    UIColor *color;
    switch (self.deviceStatus.mode) {
        case AirConFunctionCool:
        case AirConFunctionDehumidify:
            color = [AUXConfiguration sharedInstance].blueColor;
            self.coolButton.userInteractionEnabled = YES;
            self.heatUpButton.userInteractionEnabled = YES;
            self.coolButton.alpha = 1;
            self.heatUpButton.alpha = 1;
            break;
        case AirConFunctionHeat:
            color = [AUXConfiguration sharedInstance].orangeColor;
            self.coolButton.userInteractionEnabled = YES;
            self.heatUpButton.userInteractionEnabled = YES;
            self.coolButton.alpha = 1;
            self.heatUpButton.alpha = 1;
            break;
        case AirConFunctionAuto:
        case AirConFunctionVentilate:
            color = [AUXConfiguration sharedInstance].greenColor;
            self.coolButton.userInteractionEnabled = NO;
            self.heatUpButton.userInteractionEnabled = NO;
            self.coolButton.alpha = 0.3;
            self.heatUpButton.alpha = 0.3;
            break;
        default:
            break;
    }
    self.modelLabel.textColor = color;
    
    
    if (self.deviceStatus.comfortWind) {
        self.weedGeerLabel.text = [AUXConfiguration getWindSpeedName:WindSpeedAuto];
    } else {
        self.weedGeerLabel.text = [AUXConfiguration getWindSpeedName:self.deviceStatus.convenientWindSpeed];
    }
    
}

#pragma mark getters
- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}

#pragma mark setters
- (void)setOffline:(BOOL)offline {
    if (_offline == offline) {
        return;
    }
    _offline = offline;
    if (_offline) {
        self.powerOn = NO;
    }
    
    [self updateUI];
}

- (void)setPowerOn:(BOOL)powerOn {
    if (_powerOn == powerOn) {
        return ;
    }
    _powerOn = powerOn;
    
    if (_powerOn) {
        self.offline = NO;
    }
    
    [self updateUI];
}

- (void)setHasFault:(BOOL)hasFault {
    _hasFault = hasFault;
    [self updateUI];
}

- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    _deviceInfo = deviceInfo;
    
    if (_deviceInfo) {
        
        self.deviceFeature = _deviceInfo.deviceFeature;
        
        AUXACDevice *device = self.deviceDictionary[_deviceInfo.deviceId];
        AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
        AUXACStatus *deviceACStatus = device.statusDic[kAUXACDeviceAddress];
        
        self.windGearType = _deviceInfo.windGearType;
        
        self.deviceStatus = (AUXDeviceStatus *)[[AUXDeviceStatus alloc] initWithGearType:self.windGearType];
        self.deviceStatus.windGearType = self.windGearType;
        
        _deviceInfo.device = device;
        [_deviceInfo.device.delegates addObject:self];
        
        if (!device || !deviceControl) {  // SDK未找到对应的设备
            self.offline = YES;
        } else {
            self.offline = (device.wifiState != AUXACNetworkDeviceWifiStateOnline);
        }
        
        if (deviceACStatus) {
            deviceACStatus.fault = [deviceACStatus getFault];
            self.deviceStatus.roomTemperature = deviceACStatus.roomTemperature;
            if (deviceACStatus.fault) {
                self.hasFault = YES;
            }
        }
        
        if (deviceControl) {
            [self.deviceStatus updateWithControl:deviceControl];
            self.deviceStatus.powerOn = deviceControl.onOff;
            self.powerOn = self.deviceStatus.powerOn;
        }
        
        switch (deviceInfo.suitType) {
            case AUXDeviceSuitTypeAC:
                self.controlType = AUXDeviceControlTypeDevice;
                _deviceInfo.addressArray = @[kAUXACDeviceAddress];
                break;
            case AUXDeviceSuitTypeGateway:
                break;
            default:
                break;
        }
    }
    
    [self updateUI];
}

#pragma mark atcions

- (void)iconImageViewTapAtcion:(UITapGestureRecognizer *)sender {
    self.deviceTap(self.offline);
}
- (void)titlelabelTapAtcion:(id)sender {
    self.deviceTap(self.offline);
}
- (void)subTitleTapAtcion:(id)sender {
    self.deviceTap(self.offline);
}

- (IBAction)actionPoerOn:(id)sender {
    
    if (self.offline) {
        if (self.sendControlError) {
            self.sendControlError(@"设备离线，无法控制");
        }
        return ;
    }
    
    BOOL powerOn = YES;
    [self controlDeviceWithPower:powerOn];
}

- (IBAction)atcionPowerOff:(id)sender {
    
    if (self.offline) {
        if (self.sendControlError) {
            self.sendControlError(@"设备离线，无法控制");
        }
        return ;
    }
    
    BOOL powerOn = NO;
    [self controlDeviceWithPower:powerOn];
}
- (IBAction)atcionHeatUp:(id)sender {
    
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
    
    if (self.deviceFeature.halfTemperature) {
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
- (IBAction)atcionHeatDown:(id)sender {
    
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
    
    if (self.deviceFeature.halfTemperature) {
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
            self.sendControlError(@"已是最低温度了");
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
    
    self.tempretureLabel.text = [NSString stringWithFormat:@"%.1f°C" , temperature];
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
    
    switch (self.controlType) {
            
        default: {  // 单控
            AUXDeviceInfo *deviceInfo = self.deviceInfo;
            
            if (!deviceInfo.device || deviceInfo.device.wifiState != AUXACNetworkDeviceWifiStateOnline) {
                break;
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
            
            [self controlDevice:deviceInfo.device controlInfo:control atAddress:address];
        }
            break;
    }
    
    return someControl;
}


- (void)controlDevice:(AUXACDevice *)device controlInfo:(AUXACControl *)control atAddress:(NSString *)address {
    
    if (self.controlType == AUXDeviceControlTypeDevice) {
        if (self.hasControlSecondsBefore) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countdownToUpdateDeviceStatus) object:nil];
        } else {
            // 控制设备之后，3s内忽略设备上报的状态
            self.hasControlSecondsBefore = YES;
        }
        
        [self performSelector:@selector(countdownToUpdateDeviceStatus) withObject:nil afterDelay:3.0];
    }
    
    [[AUXACNetwork sharedInstance] sendCommand2Device:device controlInfo:control atAddress:address withType:device.deviceType];
}

- (void)countdownToUpdateDeviceStatus {
    // 控制设备之后，3s内忽略设备上报的状态
    self.hasControlSecondsBefore = NO;
}

/// 更新设备控制状态 (集中控制不要调用该方法)
- (void)updateStatusWithSDKControl:(AUXACControl *)deviceControl {
    
    if (!deviceControl) {
        return;
    }
    // 更新状态
    [self.deviceStatus updateWithControl:deviceControl];
}

/// 更新设备运行状态 (集中控制不要调用该方法)
- (void)updateStatusWithSDKStatus:(AUXACStatus *)deviceStatus {
    if (!deviceStatus) {
        return;
    }
    // 故障信息
    self.deviceStatus.fault = deviceStatus.fault;
    
//    self.deviceStatus.roomTemperature = deviceStatus.roomTemperature;
    
    if (self.deviceStatus.fault != nil) {
        self.hasFault = YES;
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self updateUI];
//    });
}

#pragma mark 互斥逻辑处理

- (void)updateControl:(AUXACControl *)control withDeviceInfo:(AUXDeviceInfo *)deviceInfo onOff:(BOOL)onOff {
    
    // 是否支持电加热
    BOOL supportElectricHeating = [self.deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncElectricalHeating)];
    
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

//压缩图片
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end

@interface AUXTodayExtensionTableViewCell (DeviceDelegate) <AUXACDeviceProtocol>

@end

@implementation AUXTodayExtensionTableViewCell (DeviceDelegate)

- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSArray *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type {
    
    NSString *mac;
    NSString *typeString;
    
    if (device.bLDevice) {
        mac = device.bLDevice.mac;
        typeString = @"【古北】";
    } else {
        mac = device.gizDevice.macAddress;
        typeString = @"【机智云】";
    }
    
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
                NSLog(@"---------------设备控制界面 设备 %@ %@ %@ 控制状态上报: %@--------", typeString, mac, addressString, device.controlDic);
                
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
                
            case AUXACNetworkQueryTypeStatus: {
//                NSLog(@"设备控制界面 设备 %@ %@ 运行状态上报: %@", typeString, mac, device.statusDic);
                
                AUXACStatus *deviceStatus = device.statusDic[addressString];
                
                if (!deviceStatus) {
                    break;
                }
                
                // 设备控制若干秒之内忽略设备上报的状态
                if (self.hasControlSecondsBefore) {
                    break;
                }
                
//                [self updateStatusWithSDKStatus:deviceStatus];
            }
                break;
                
            default:
                break;
        }
    } else {
//        NSLog(@"设备控制界面 设备 %@ %@ %@ 状态上报错误 %@ %@", typeString, mac, address, @(type), error);
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

