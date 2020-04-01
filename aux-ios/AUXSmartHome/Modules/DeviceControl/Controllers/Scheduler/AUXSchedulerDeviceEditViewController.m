//
//  AUXSchedulerDeviceEditViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSchedulerDeviceEditViewController.h"
#import "AUXSchedulerDevicePowerTableViewCell.h"
#import "AUXSchedulerTemperatureTableViewCell.h"
#import "AUXSchedulerDeviceWindTableViewCell.h"

#import "UITableView+AUXCustom.h"
#import "NSError+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXSchedulerDeviceEditViewController ()<UITableViewDelegate, UITableViewDataSource, AUXACDeviceProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *modeArray;       // 模式列表
@property (nonatomic, strong) NSMutableArray<NSString *> *modeNameArray;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *windSpeedArray;  // 风速列表
@property (nonatomic, strong) NSMutableArray<NSString *> *windSpeedNameArray;  // 风速列表

@property (nonatomic,strong) NSMutableArray <NSDictionary *> *modeDictArray;
@property (nonatomic,strong) NSMutableArray <NSDictionary *> *windSpeedDictArray;

@property (nonatomic, strong) NSTimer *addTimer;
@property (nonatomic, strong) NSTimer *deleteTimer;

@end

@implementation AUXSchedulerDeviceEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeLabel.text = [NSString stringWithFormat:@"执行时间：%@%@" , self.schedulerModel.repeatDescription , self.schedulerModel.timeString];
    if (self.device.bLDevice) {
        [self.device.delegates addObject:self];
    }
}

- (void)initSubviews {
    [super initSubviews];
    
    self.tableView.allowsSelection = NO;
    [self.tableView registerCellWithNibName:@"AUXSchedulerDevicePowerTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXSchedulerTemperatureTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXSchedulerDeviceWindTableViewCell"];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
}

#pragma mark 模式和风速互斥逻辑
- (void)updateWindWithMode:(AUXServerDeviceMode)mode {
    
    if (![self.windSpeedArray containsObject:@(AUXServerWindSpeedTurbo)]) {
        [self.windSpeedArray addObject:@(AUXServerWindSpeedTurbo)];
    }
    if (![self.windSpeedArray containsObject:@(AUXServerWindSpeedAuto)]) {
        [self.windSpeedArray addObject:@(AUXServerWindSpeedAuto)];
    }
    if (![self.windSpeedNameArray containsObject:@"强力"]) {
        [self.windSpeedNameArray addObject:@"强力"];
    }
    if (![self.windSpeedNameArray containsObject:@"自动"]) {
        [self.windSpeedNameArray addObject:@"自动"];
    }
    
    if (mode == AUXServerDeviceModeAuto || mode == AUXServerDeviceModeDry) {
        if ([self.windSpeedArray containsObject:@(AUXServerWindSpeedTurbo)]) {
            [self.windSpeedArray removeObject:@(AUXServerWindSpeedTurbo)];
        }
        
        if ([self.windSpeedNameArray containsObject:@"强力"]) {
            [self.windSpeedNameArray removeObject:@"强力"];
        }
        
        if (self.schedulerModel.windSpeed == AUXServerWindSpeedTurbo) {
            self.schedulerModel.windSpeed = AUXServerWindSpeedLow;
        }
    }
    
    if (mode == AUXServerDeviceModeWind) {
        
        if ([self.windSpeedArray containsObject:@(AUXServerWindSpeedTurbo)]) {
            [self.windSpeedArray removeObject:@(AUXServerWindSpeedTurbo)];
        }
        
        if ([self.windSpeedNameArray containsObject:@"强力"]) {
            [self.windSpeedNameArray removeObject:@"强力"];
        }
        
        if ([self.windSpeedArray containsObject:@(AUXServerWindSpeedAuto)]) {
            [self.windSpeedArray removeObject:@(AUXServerWindSpeedAuto)];
        }
        
        if ([self.windSpeedNameArray containsObject:@"自动"]) {
            [self.windSpeedNameArray removeObject:@"自动"];
        }
        
        if (self.schedulerModel.windSpeed == AUXServerWindSpeedAuto) {
            self.schedulerModel.windSpeed = AUXServerWindSpeedLow;
        }
        
        if (self.schedulerModel.windSpeed == AUXServerWindSpeedTurbo) {
            self.schedulerModel.windSpeed = AUXServerWindSpeedLow;
        }
    }
    
    self.windSpeedDictArray = nil;
    self.modeDictArray = nil;
    [self modeDictArray];
    [self windSpeedDictArray];
    
    [self.tableView reloadData];
}

#pragma mark getters

- (NSMutableArray<NSNumber *> *)modeArray {
    if (!_modeArray) {
        _modeArray = [NSMutableArray arrayWithArray:@[@(AUXServerDeviceModeCool), @(AUXServerDeviceModeHeat), @(AUXServerDeviceModeDry), @(AUXServerDeviceModeWind), @(AUXServerDeviceModeAuto)]];
        
        if (!self.deviceInfo.virtualDevice) {
            
            AUXDeviceFeature *deviceFeature = self.deviceInfo.deviceFeature;
            NSString *addressString = self.deviceInfo.addressArray.firstObject;
            AUXACStatus *deviceStatus = self.deviceInfo.device.statusDic[addressString];
            NSInteger coolType = deviceFeature.coolType.firstObject ? deviceFeature.coolType.firstObject.integerValue : 1;
            if (!deviceStatus.supportHeat || !coolType) {
                if ([_modeArray containsObject:@(AUXServerDeviceModeHeat)]) {
                    [_modeArray removeObject:@(AUXServerDeviceModeHeat)];
                }
            }
            
            if (deviceFeature) {
                
                for (NSNumber *modeNum in self.modeArray) {
                    if (![deviceFeature.supportModes containsObject:modeNum]) {
                        if ([_modeArray containsObject:modeNum]) {
                            [_modeArray removeObject:modeNum];

                        }
                    }
                }
            }
        }
    }
    return _modeArray;
}

- (NSMutableArray<NSString *> *)modeNameArray {
    if (!_modeNameArray) {
        _modeNameArray = [NSMutableArray array];
        
        for (NSNumber *mode in self.modeArray) {
            switch (mode.integerValue) {
                case AUXServerDeviceModeCool: {
                    [_modeNameArray addObject:@"制冷"];
                    break;
                }
                case AUXServerDeviceModeHeat: {
                    [_modeNameArray addObject:@"制热"];
                    break;
                }
                case AUXServerDeviceModeDry: {
                    [_modeNameArray addObject:@"除湿"];
                    break;
                }
                case AUXServerDeviceModeWind: {
                    [_modeNameArray addObject:@"送风"];
                    break;
                }
                case AUXServerDeviceModeAuto: {
                    [_modeNameArray addObject:@"自动"];
                    break;
                }
                    
                default:
                    break;
            }
        }
        
    }
    return _modeNameArray;
}

- (NSMutableArray<NSDictionary *> *)modeDictArray {
    if (!_modeDictArray) {
        _modeDictArray = [NSMutableArray array];
        
        for (NSInteger index = 0; index < self.modeArray.count; index++) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            [dict setObject:self.modeNameArray[index] forKey:@"title"];
            
            AUXServerDeviceMode mode = [self.modeArray[index] integerValue];
            if (mode == self.schedulerModel.mode) {
                [dict setObject:@(YES) forKey:@"selected"];
            } else {
                [dict setObject:@(NO) forKey:@"selected"];
            }
            [_modeDictArray addObject:dict];
        }
    }
    return _modeDictArray;
}

- (NSMutableArray<NSNumber *> *)windSpeedArray {
    if (!_windSpeedArray) {
        _windSpeedArray = [NSMutableArray array];
        [_windSpeedArray addObjectsFromArray:@[@(AUXServerWindSpeedLow),
                                               @(AUXServerWindSpeedMid),
                                               @(AUXServerWindSpeedHigh),
                                               @(AUXServerWindSpeedMute), @(AUXServerWindSpeedAuto), @(AUXServerWindSpeedTurbo),
                                               ]];
        
        if (self.deviceInfo.virtualDevice) {
            return _windSpeedArray;
        }
        
        BOOL supportMute = YES;
        BOOL supportTurbo = YES;
        BOOL supportAuto = YES;
        // 设备功能注册表
        AUXDeviceFeature *deviceFeature = self.deviceInfo.deviceFeature;
        if (deviceFeature) {
            // 设备不支持自动风
            if (deviceFeature.windSpeedGear == AUXWindSpeedGearTypeThree || deviceFeature.windSpeedGear == AUXWindSpeedGearTypeFive) {
                supportAuto = NO;
            }
            
            // 设备不支持静音
            if (![deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncWindSpeedMute)]) {
                supportMute = NO;
            }
            
            // 设备不支持强力
            if (![deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncWindSpeedTurbo)]) {
                supportTurbo = NO;
            }
        }
        
        switch (self.schedulerModel.mode) {
            case AUXServerDeviceModeWind:   // 送风模式下，风速无强力、自动
                supportTurbo = NO;
                supportAuto = NO;
                break;
                
            case AUXServerDeviceModeDry:    // 除湿、自动模式下，风速无强力
            case AUXServerDeviceModeAuto:
                supportTurbo = NO;
                break;
                
            default:
                break;
        }
        
        if (!supportMute) {
            if ([_windSpeedArray containsObject:@(AUXServerWindSpeedMute)]) {
                [_windSpeedArray removeObject:@(AUXServerWindSpeedMute)];
            }
            if (self.schedulerModel.windSpeed == AUXServerWindSpeedMute) {
                self.schedulerModel.windSpeed = AUXServerWindSpeedLow;
            }
        }
        if (!supportTurbo) {
            
            if ([_windSpeedArray containsObject:@(AUXServerWindSpeedTurbo)]) {
                [_windSpeedArray removeObject:@(AUXServerWindSpeedTurbo)];
            }
            if (self.schedulerModel.windSpeed == AUXServerWindSpeedTurbo) {
                self.schedulerModel.windSpeed = AUXServerWindSpeedLow;
            }
        }
        if (!supportAuto) {
            if ([_windSpeedArray containsObject:@(AUXServerWindSpeedAuto)]) {
                [_windSpeedArray removeObject:@(AUXServerWindSpeedAuto)];
            }
            
            if (self.schedulerModel.windSpeed == AUXServerWindSpeedAuto) {
                self.schedulerModel.windSpeed = AUXServerWindSpeedLow;
            }
        }
        
    }
    return _windSpeedArray;
}

- (NSMutableArray<NSString *> *)windSpeedNameArray {
    if (!_windSpeedNameArray) {
        
        _windSpeedNameArray = [NSMutableArray array];
        for (NSNumber *windSpeed in self.windSpeedArray) {
            switch (windSpeed.integerValue) {
                case AUXServerWindSpeedLow:{
                    [_windSpeedNameArray addObject:@"低档"];
                }
                    break;
                case AUXServerWindSpeedMid:{
                    [_windSpeedNameArray addObject:@"中档"];
                }
                    break;
                case AUXServerWindSpeedHigh:{
                    [_windSpeedNameArray addObject:@"高档"];
                }
                    break;
                case AUXServerWindSpeedMute:{
                    [_windSpeedNameArray addObject:@"静音"];
                }
                    break;
                case AUXServerWindSpeedAuto:{
                    [_windSpeedNameArray addObject:@"自动"];
                }
                    break;
                case AUXServerWindSpeedTurbo:{
                    [_windSpeedNameArray addObject:@"强力"];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
    }
    return _windSpeedNameArray;
}


- (NSMutableArray<NSDictionary *> *)windSpeedDictArray {
    if (!_windSpeedDictArray) {
        _windSpeedDictArray = [NSMutableArray array];
        
        for (NSInteger index = 0; index < self.windSpeedArray.count; index++) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            [dict setObject:self.windSpeedNameArray[index] forKey:@"title"];
            
            AUXServerWindSpeed windSpeed = [self.windSpeedArray[index] integerValue];
            if (windSpeed == self.schedulerModel.windSpeed) {
                [dict setObject:@(YES) forKey:@"selected"];
            } else {
                [dict setObject:@(NO) forKey:@"selected"];
            }
            
            [_windSpeedDictArray addObject:dict];
        }
    }
    return _windSpeedDictArray;
}

#pragma mark atcion
- (IBAction)confirmAtcion:(id)sender {
    
    if (self.deviceInfo.virtualDevice) {
        [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
        return ;
    }
    
    // 旧设备，限制hour、minute、repeatValue一样时不能保存。
    if (self.device.bLDevice && self.existedSchedulerArray) {
        
        for (AUXSchedulerModel *schedulerModel in self.existedSchedulerArray) {
            
            if (![schedulerModel.schedulerId isEqualToString:@"-1"] && ![self.schedulerModel.schedulerId isEqualToString:@"-1"] && [schedulerModel.schedulerId isEqualToString:self.schedulerModel.schedulerId]) {
                continue;
            }
            
            BOOL hourEqual = (schedulerModel.hour == self.schedulerModel.hour);
            BOOL minuteEqual = (schedulerModel.minute == self.schedulerModel.minute);
            BOOL repeatEqual = (schedulerModel.repeatValue == self.schedulerModel.repeatValue);
            
            if (hourEqual && minuteEqual && repeatEqual) {
                [self showErrorViewWithMessage:@"该定时已存在"];
                return;
            }
        }
    }
    
    // 添加和修改定时，默认开启
    self.schedulerModel.on = YES;
    
    // 自动模式时，将温度设置为24摄氏度
    if (self.schedulerModel.mode == AUXServerDeviceModeAuto) {
        self.schedulerModel.temperature = 24.0;
    }
    
    if (self.addScheduler) {
        [self addSchedulerByServer];
    } else {
        if (self.editSuccessBlock) {
            self.editSuccessBlock(self.schedulerModel);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!self.schedulerModel.deviceOperate) {
        return 1;
    } else {
        if (self.schedulerModel.mode == AUXServerDeviceModeWind || self.schedulerModel.mode == AUXServerDeviceModeAuto) {
            return 3;
        } else {
            return 4;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.schedulerModel.mode == AUXServerDeviceModeCool || self.schedulerModel.mode == AUXServerDeviceModeDry ||
        self.schedulerModel.mode == AUXServerDeviceModeHeat) {
        if (indexPath.row == 2) {
            return 100;
        }
    }
    
    return 107;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXBaseTableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [self tableView:tableView operationCellForRowAtIndexPath:indexPath];
        
    } else if (indexPath.row == 1) {
        cell = [self tableView:tableView modeCellForRowAtIndexPath:indexPath];
        
        if (self.schedulerModel.mode == AUXServerDeviceModeWind || self.schedulerModel.mode == AUXServerDeviceModeAuto) {
            cell.separatorInset = UIEdgeInsetsMake(kAUXScreenWidth, 0, kAUXScreenWidth, 0);
        }
        cell.bottomView.hidden = NO;
    } else if (indexPath.row == 2) {
        if (self.schedulerModel.mode == AUXServerDeviceModeAuto || self.schedulerModel.mode == AUXServerDeviceModeWind) {
            cell = [self tableView:tableView windSpeedCellForRowAtIndexPath:indexPath];
        } else {
            cell = [self tableView:tableView temperatureCellForRowAtIndexPath:indexPath];
        }
        cell.bottomView.hidden = NO;
    } else {
        cell = [self tableView:tableView windSpeedCellForRowAtIndexPath:indexPath];
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

// 设备操作
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView operationCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSchedulerDevicePowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSchedulerDevicePowerTableViewCell" forIndexPath:indexPath];
    
    cell.multiSelection = NO;
    cell.didSelectBlock = ^(NSInteger index) {
        if (index == 0) {
            self.schedulerModel.deviceOperate = 1;
        } else {
            self.schedulerModel.deviceOperate = 0;
        }
        [tableView reloadData];
    };
    
    NSInteger selectedIndex = self.schedulerModel.deviceOperate == 1 ? 0 : 1;
    [cell selectsButtonAtIndex:selectedIndex];
    
    if (self.schedulerModel.deviceOperate) {
        cell.bottomView.hidden = NO;
    }
    
    return cell;
}

// 模式
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView modeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSchedulerDeviceWindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSchedulerDeviceWindTableViewCell" forIndexPath:indexPath];
    
    cell.dataArray = self.modeDictArray;
    cell.titleLabel.text = @"模式";
    @weakify(self);
    cell.selectedBtnBlock = ^(NSString * _Nonnull title) {
        @strongify(self);
        NSInteger index = [self.modeNameArray indexOfObject:title];
        self.schedulerModel.mode = [self.modeArray[index] integerValue];
        
        [self updateWindWithMode:self.schedulerModel.mode];
    };
    
    return cell;
}

// 温度
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView temperatureCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSchedulerTemperatureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSchedulerTemperatureTableViewCell" forIndexPath:indexPath];
    
    cell.temperature = self.schedulerModel.temperature;
    
    @weakify(self);
    cell.didChangeTemperatureBlock = ^(CGFloat temperature) {
        @strongify(self);
        self.schedulerModel.temperature = temperature;
    };
    
    return cell;
}

// 风速
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView windSpeedCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSchedulerDeviceWindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSchedulerDeviceWindTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = @"风速";
    cell.dataArray = self.windSpeedDictArray;
    
    @weakify(self);
    cell.selectedBtnBlock = ^(NSString * _Nonnull title) {
        @strongify(self);
        NSInteger index = [self.windSpeedNameArray indexOfObject:title];
        self.schedulerModel.windSpeed = [self.windSpeedArray[index] integerValue];
        [self updateWindWithMode:self.schedulerModel.mode];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 网络请求
/// 通过服务器添加定时
- (void)addSchedulerByServer {
    
    if (!self.device) {
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self addSchedulerBySDK];
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] addSchedulerWithModel:self.schedulerModel completion:^(NSString * _Nullable schedulerId, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self addSchedulerSuccessfully];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self addSchedulerFailed:error];
                break;
        }
    }];
}

/// 通过SDK添加定时
- (void)addSchedulerBySDK {
    
    WindGearType gearType = self.deviceInfo.windGearType;
    
    AUXACControl *currentControl = self.device.controlDic[self.address];
    
    AUXACBroadlinkCycleTimer *cycleTimer = [self.schedulerModel convertToSDKCycleTimer];
    
    AUXACControl *timerControl = [self.schedulerModel getControlWithGearType:gearType currentControl:currentControl];
    
    [self showLoadingHUD];
    
    self.addTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(addSchedulerBySDKTimeout) userInfo:nil repeats:NO];
    
    [[AUXACNetwork sharedInstance] setCycleTimerForDevice:self.device timer:cycleTimer control:timerControl cmdType:Broadlink2UartCmdAdd hardwareType:self.hardwaretype  windGearType:gearType];
}

/// 通过SDK添加定时超时
- (void)addSchedulerBySDKTimeout {
    [self hideLoadingHUD];
    self.addTimer = nil;
    
    [self addSchedulerFailed:[NSError errorForTimeout]];
}

/// 添加定时成功
- (void)addSchedulerSuccessfully {
    @weakify(self);
    [self showSuccess:@"保存成功" completion:^{
        @strongify(self);
        
        NSMutableArray *viewControlers = [self.navigationController.viewControllers mutableCopy];
        
        for (AUXBaseViewController *vc in viewControlers) {
            if ([vc isKindOfClass:NSClassFromString(@"AUXSchedulerListViewController")]) {
                
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }];
}

/// 添加定时失败
- (void)addSchedulerFailed:(NSError *)error {
    [self showErrorViewWithError:error defaultMessage:@"保存失败"];
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidSetCycleTimerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    
    [self hideLoadingHUD];
    if (self.addTimer) {
        [self.addTimer invalidate];
        self.addTimer = nil;
        
        if (success) {
            self.schedulerModel.schedulerId = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceDidAddSchedulerNotification object:self.schedulerModel];
            [self addSchedulerSuccessfully];
        } else {
            [self addSchedulerFailed:error];
        }
    }
}

@end
