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

#import "AUXSmartPowerViewController.h"
#import "AUXPickerPopupViewController.h"

#import "AUXSwitchTableViewCell.h"
#import "AUXTimePeriodPickerTableViewCell.h"
#import "AUXSubtitleTableViewCell.h"
#import "AUXIntelligentElectricityOperationCell.h"
#import "AUXIntelligentElectricityCycleCell.h"
#import "AUXSchedulerCycleTableViewCell.h"
#import "AUXPeakVallyFooterView.h"

#import "AUXAlertCustomView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "UILabel+AUXCustom.h"
#import "AUXNetworkManager.h"
#import "AUXTimerObject.h"

@interface AUXSmartPowerViewController () <UITableViewDelegate, UITableViewDataSource, AUXACDeviceProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// 设备操作列表 (AUXSmartPowerMode)
@property (nonatomic, strong) NSArray<NSNumber *> *deviceOperationArray;
/// 执行周期列表 (AUXIntelligentElectricityCycle)
@property (nonatomic, strong) NSArray<NSNumber *> *executeCycleArray;

@property (nonatomic, weak) UILabel *degreeLabel;   // 用电总量

@property (nonatomic, assign) NSInteger minValue;   // 用电总量最小值
@property (nonatomic, assign) NSInteger maxValue;   // 用电总量最大值
@property (nonatomic,assign) BOOL showEntireCycleView;
@property (nonatomic,assign) BOOL smartPowerOn;

@property (nonatomic,strong) NSTimer *oldDeviceSetTimer;

@property (nonatomic, strong) AUXSmartPowerModel *lastSmartPowerModel;
@end

@implementation AUXSmartPowerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSwitchTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXTimePeriodPickerTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXSchedulerCycleTableViewCell"];
    
    // 计算用电总量的范围
    [self calculateRange];
    
    if (self.smartPowerModel.totalElec < self.minValue) {
        self.smartPowerModel.totalElec = self.minValue;
    } else if (self.smartPowerModel.totalElec > self.maxValue) {
        self.smartPowerModel.totalElec = self.maxValue;
    }
    
    if (self.device.bLDevice) {
        [self.device.delegates addObject:self];
    }
    
    self.customBackAtcion = YES;
    
    self.lastSmartPowerModel = [self.smartPowerModel copy];
    
    self.smartPowerOn = self.smartPowerModel.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)whtherChangeSmartData {
    
    if (self.lastSmartPowerModel.on != self.smartPowerModel.on) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.startHour != self.smartPowerModel.startHour) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.endHour != self.smartPowerModel.endHour) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.startMinute != self.smartPowerModel.startMinute) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.endMinute != self.smartPowerModel.endMinute) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.executeCycle != self.smartPowerModel.executeCycle) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.mode != self.smartPowerModel.mode) {
        return YES;
    }
    
    if (self.lastSmartPowerModel.totalElec != self.smartPowerModel.totalElec) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Actions

- (IBAction)confirmAtcion:(id)sender {
    
    if (self.deviceInfo.virtualDevice) {
        [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
        return ;
    }
    
    if (!self.device) {
        return;
    }
    
    NSString *errorMessage;
    
    if (![self.deviceControlViewController canTurnOnSmartPower:&errorMessage]) {
        [self showErrorViewWithMessage:errorMessage];
        return;
    }
    
    if (self.smartPowerModel.on) {
        NSInteger startTime = self.smartPowerModel.startHour * 60 + self.smartPowerModel.startMinute;
        NSInteger endTime = self.smartPowerModel.endHour * 60 + self.smartPowerModel.endMinute;
        
        if (startTime == endTime) {
            [self showErrorViewWithMessage:@"开始时间不能等于结束时间"];
            return;
        }
        
        if (endTime > startTime && (endTime - startTime) < 60) {
            [self showErrorViewWithMessage:@"时间间隔不能少于1小时"];
            return;
        }
    }
    
    self.smartPowerModel.executeCycle = AUXSmartPowerCycleOnce;
    
    if (self.device.bLDevice) {
        
        if (self.smartPowerOn) {
            [self setupSmartPowerBySDK];
        } else {
            if (self.smartPowerModel.on) {
                [self setupSmartPowerBySDK];
            } else {
                [self showSuccess:@"保存成功" completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
        
        
    } else {
        
        if (self.smartPowerOn) {
            
            if (self.smartPowerModel.on) {
                [self updateOnSmartPowerServer];
            } else {
                [self turnOffSmartPowerByServer];
            }
            
        } else {
            if (self.smartPowerModel.on) {
                [self turnOnSmartPowerByServer];
            } else {
                [self showSuccess:@"保存成功" completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
    }
}

- (void)backAtcion {
    [super backAtcion];
    
    if ([self whtherChangeSmartData]) {
        [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改?" confirmAtcion:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancleAtcion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 && self.smartPowerModel.on) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 45.0;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: // 开关
                height = AUXSwitchTableViewCell.properHeight;
                break;
                
            case 1:
                height = AUXTimePeriodPickerTableViewCell.properHeight;
                break;
                
            case 2: // 用电总量
                height = AUXSubtitleTableViewCell.properHeight;
                break;
                
            case 3: // 设备操作
                height = AUXIntelligentElectricityOperationCell.properHeight;
                break;
            default:
                break;
        }
    } else {
        return height = 108;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (!self.smartPowerModel.on) {
        return 65;
    }
    
    return 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    AUXPeakVallyFooterView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"AUXPeakVallyFooterView" owner:nil options:nil] firstObject];
    footerView.contentLabel.text = @"限制用电总量后，会一定程度影响空调运行的效果，请谨慎使用该功能。";
    [footerView.contentLabel setLabelAttributedString:@"谨慎使用" color:[UIColor colorWithHexString:@"10BFCA"]];
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0: {
                AUXSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:@"AUXSwitchTableViewCell" forIndexPath:indexPath];
                cell = switchCell;
                
                switchCell.titleLabel.text = @"智能用电";
                switchCell.switchButton.selected = self.smartPowerModel.on;
                
                if (self.smartPowerModel.on) {
                    switchCell.bottomView.hidden = NO;
                }
                
                @weakify(self , switchCell);
                switchCell.switchBlock = ^(BOOL on) {
                    @strongify(self , switchCell);

                    if (on) {
                        
                        NSString *errorMessage;
                        
                        if (![self.deviceControlViewController canTurnOnSmartPower:&errorMessage]) {
                            [self showErrorViewWithMessage:errorMessage];
                            return;
                        }
                    }
                    
                    self.smartPowerModel.on = on;
                    [tableView reloadData];
                };
            }
                break;
                
            case 1: {
                AUXTimePeriodPickerTableViewCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:@"AUXTimePeriodPickerTableViewCell" forIndexPath:indexPath];
                cell = pickerCell;

                pickerCell.titleLabel.text = @"智能用电时间段";
                
                [pickerCell selectStartHour:self.smartPowerModel.startHour animated:NO];
                [pickerCell selectEndHour:self.smartPowerModel.endHour animated:NO];
                
                @weakify(self);
                pickerCell.didSelectTimeBlock = ^(NSInteger startHour, NSInteger startMinute, NSInteger endHour, NSInteger endMinute) {
                    @strongify(self);
                    self.smartPowerModel.startHour = startHour;
                    self.smartPowerModel.startMinute = startMinute;
                    self.smartPowerModel.endHour = endHour;
                    self.smartPowerModel.endMinute = endMinute;
                    [self calculateRange];
                    
                    [self didSelectDegree:self.minValue];
                };
                pickerCell.bottomView.hidden = NO;
            }
                break;
                
            case 2: {   // 用电总量
                AUXSubtitleTableViewCell *subtitleCell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
                cell = subtitleCell;
                
                subtitleCell.titleLabel.text = @"用电总量";
                subtitleCell.subtitleLabel.text = [NSString stringWithFormat:@"%@度", @(self.smartPowerModel.totalElec)];
                self.degreeLabel = subtitleCell.subtitleLabel;
                subtitleCell.hidden = NO;
                subtitleCell.bottomView.hidden = NO;
            }
                break;
                
            case 3: {   // 设备操作
                AUXIntelligentElectricityOperationCell *operationCell = [tableView dequeueReusableCellWithIdentifier:@"deviceOperationCell" forIndexPath:indexPath];
                cell = operationCell;
                
                operationCell.tipLabel.text = @"设备运行模式";
                operationCell.multiSelection = NO;
                NSUInteger index = [self.deviceOperationArray indexOfObject:@(self.smartPowerModel.mode)];
                [operationCell selectsButtonAtIndex:index];
                UIImageView *imageView = operationCell.imageArray[index];
                imageView.highlighted = YES;
                
                @weakify(self , operationCell);
                operationCell.didSelectBlock = ^(NSInteger index) {
                    @strongify(self , operationCell);
                    
                    for (UIImageView *imageView in operationCell.imageArray) {
                        imageView.highlighted = NO;
                    }
                    
                    if (index < self.deviceOperationArray.count) {
                        self.smartPowerModel.mode = self.deviceOperationArray[index].integerValue;
                        UIImageView *imageView = operationCell.imageArray[index];
                        imageView.highlighted = YES;
                    }
                };
            }
                break;
            default:
                break;
        }
    } else {
        AUXIntelligentElectricityCycleCell *cycleCell = [tableView dequeueReusableCellWithIdentifier:@"executeCycleCell" forIndexPath:indexPath];
        cell = cycleCell;
        
        cycleCell.multiSelection = NO;
        NSUInteger index = [self.executeCycleArray indexOfObject:@(self.smartPowerModel.executeCycle)];
        [cycleCell selectsButtonAtIndex:index];
        
        if (self.device.bLDevice) {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:0];
            [indexSet addIndex:1];
            [cycleCell disablesButtonsAtIndexes:indexSet];
        }
        
        @weakify(self);
        cycleCell.didSelectBlock = ^(NSInteger index) {
            @strongify(self);
            if (index < self.executeCycleArray.count) {
                self.smartPowerModel.executeCycle = self.executeCycleArray[index].integerValue;
            }
        };
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self showElectricityDegreePickerView];
    }
}

/// 计算用电总量的范围
- (void)calculateRange {
    /*
     可设置一段时间（1-23小时）的设备用电总量、用电模式，用电设置范围为额定功率*30%*n小时至额定功率*200%*n小时（计算结果需向上取整），n为选择的时间。
     */
    
    NSInteger startTime = self.smartPowerModel.startHour * 60 + self.smartPowerModel.startMinute;
    NSInteger endTime = self.smartPowerModel.endHour * 60 + self.smartPowerModel.endMinute;
    
    if (endTime < startTime) {
        endTime += 24 * 60;
    }
    
    CGFloat floatHour = ceil((endTime - startTime) / 60.0);
    
    if (floatHour < 1) {
        floatHour = 1;
    } else if (floatHour > 23) {
        floatHour = 23;
    }
    
    if (self.powerRating <= 0) {
        self.powerRating = 2000;
    }
    
    self.minValue = ceil(self.powerRating / 1000.0 * 0.3 * floatHour);
    self.maxValue = ceil(self.powerRating / 1000.0 * 2.0 * floatHour);
}

/// 弹出用电总量 pickerView
- (void)showElectricityDegreePickerView {
    
    NSInteger selectedValue = self.smartPowerModel.totalElec;
    
    if (selectedValue < self.minValue) {
        selectedValue = self.minValue;
    } else if (selectedValue > self.maxValue) {
        selectedValue = self.maxValue;
    }
    
    NSInteger row = (selectedValue - self.minValue);
    
    AUXPickerPopupViewController *pickerPopupViewController = [[AUXPickerPopupViewController alloc] init];
    pickerPopupViewController.pickerTitle = @"用电总量";
    pickerPopupViewController.indicateString = @"度";
    pickerPopupViewController.indicateLeading = 45;
    
    pickerPopupViewController.minValue = self.minValue;
    pickerPopupViewController.maxValue = self.maxValue;
    
    [pickerPopupViewController selectRow:row inComponent:0 animated:NO];
    [pickerPopupViewController showWithAnimated:YES completion:nil];
    
    @weakify(self);
    pickerPopupViewController.confirmBlock = ^(NSArray<NSNumber *> *selectedRows) {
        @strongify(self);
        [self didSelectDegree:selectedRows.firstObject.integerValue + self.minValue];
    };
}

- (void)didSelectDegree:(NSInteger)degree {
    self.smartPowerModel.totalElec = degree;
    self.degreeLabel.text = [NSString stringWithFormat:@"%@度", @(self.smartPowerModel.totalElec)];
}

#pragma mark - 网络请求

- (void)invalidateTimer {
    [self hideLoadingHUD];
    
    if (self.oldDeviceSetTimer) {
        [self.oldDeviceSetTimer invalidate];
        self.oldDeviceSetTimer = nil;
    }
    [self showFailure:@"保存失败" completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
}

- (void)setupSmartPowerBySDK {
    
    [self showLoadingHUD];
    
    AUXACSmartPower *smartPower = [self.smartPowerModel convertToSDKSmartPower];
    
    [[AUXACNetwork sharedInstance] setSmartPowerForDevice:self.device startTime:smartPower.startTime endTime:smartPower.endTime quantity:smartPower.quantity mode:smartPower.mode enabled:smartPower.enabled];
    
    [self.oldDeviceSetTimer invalidate];
    self.oldDeviceSetTimer = nil;
    self.oldDeviceSetTimer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:DeviceControlCommondMaxTime target:self selector:@selector(invalidateTimer) userInfo:nil repeats:NO];
}

- (void)updateOnSmartPowerServer {
    
    self.smartPowerModel.deviceId = self.deviceInfo.deviceId;
    self.smartPowerModel.mac = self.deviceInfo.mac;
    
    [self showLoadingHUD];
    [[AUXNetworkManager manager] turnOffSmartPower:self.deviceInfo.deviceId completion:^(NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone:{
                [[AUXNetworkManager manager] turnOnSmartPower:self.smartPowerModel completion:^(NSError * _Nonnull error) {
                    [self hideLoadingHUD];
                    switch (error.code) {
                        case AUXNetworkErrorNone:{
                            [self showSuccess:@"保存成功" completion:^{
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                        }
                            break;
                            
                        case AUXNetworkErrorAccountCacheExpired:
                            
                            [self alertAccountCacheExpiredMessage];
                            break;
                            
                        default:
                            [self showErrorViewWithError:error defaultMessage:@"保存失败"];
                            break;
                    }
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                break;
                
            default:
                
                break;
        }
    }];
}

- (void)turnOnSmartPowerByServer {
    
    self.smartPowerModel.deviceId = self.deviceInfo.deviceId;
    self.smartPowerModel.mac = self.deviceInfo.mac;
    
    [self showLoadingHUD];
    [[AUXNetworkManager manager] turnOnSmartPower:self.smartPowerModel completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:{
                [self showSuccess:@"保存成功" completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"保存失败"];
                break;
        }
    }];
}

- (void)turnOffSmartPowerByServer {
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] turnOffSmartPower:self.deviceInfo.deviceId completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:{
                [self showSuccess:@"保存成功" completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self showErrorViewWithError:error defaultMessage:@"保存失败"];
//                self.smartPowerModel.on = !self.smartPowerModel.on;
                break;
        }
    }];
}

#pragma mark - AUXACDeviceProtocol
- (void)auxACNetworkDidSetSmartPowerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    [self hideLoadingHUD];
    
    if (self.oldDeviceSetTimer) {
        [self.oldDeviceSetTimer invalidate];
        self.oldDeviceSetTimer = nil;
    }
    
    if (success) {
        [self showSuccess:@"保存成功" completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self showErrorViewWithError:error defaultMessage:@"保存失败"];
    }
}

#pragma mark - Getters & Setters

- (NSArray<NSNumber *> *)deviceOperationArray {
    if (!_deviceOperationArray) {
        _deviceOperationArray = @[@(AUXSmartPowerModeFast),
                                  @(AUXSmartPowerModeBalance),
                                  @(AUXSmartPowerModeStandard)];
    }
    
    return _deviceOperationArray;
}

- (void)setSmartPowerModel:(AUXSmartPowerModel *)smartPowerModel {
    _smartPowerModel = smartPowerModel;
    if (!_smartPowerModel) {
        _smartPowerModel = [[AUXSmartPowerModel alloc] init];
        _smartPowerModel.executeCycle = AUXSmartPowerCycleEveryday;
    }
    
}

- (NSArray<NSNumber *> *)executeCycleArray {
    if (!_executeCycleArray) {
        _executeCycleArray = @[@(AUXSmartPowerCycleEveryday),
                               @(AUXSmartPowerCycleOnce)];
    }
    
    return _executeCycleArray;
}

@end
