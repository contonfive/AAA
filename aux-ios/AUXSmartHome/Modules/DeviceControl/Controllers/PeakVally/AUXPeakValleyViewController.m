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

#import "AUXPeakValleyViewController.h"

#import "AUXSwitchTableViewCell.h"
#import "AUXTimePeriodPickerTableViewCell.h"
#import "AUXAlertCustomView.h"
#import "AUXPeakVallyFooterView.h"

#import "UITableView+AUXCustom.h"
#import "UILabel+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"
#import "AUXTimerObject.h"

@interface AUXPeakValleyViewController () <UITableViewDelegate, UITableViewDataSource, AUXACDeviceProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AUXPeakValleyModel *lastPeakValleyModel;
@property (nonatomic,strong) NSTimer *oldDeviceTimer;
@property (nonatomic,strong) NSMutableArray *peakHourArray;
@property (nonatomic,strong) NSMutableArray *valleyHourArray;

@end

@implementation AUXPeakValleyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSwitchTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXTimePeriodPickerTableViewCell"];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    
    if (self.device.bLDevice) {
        [self.device.delegates addObject:self];
    }
    
    self.customBackAtcion = YES;
    self.lastPeakValleyModel = [self.peakValleyModel copy];
}

- (NSMutableArray *)peakHourArray{
    if (!_peakHourArray) {
        self.peakHourArray = [[NSMutableArray alloc]init];
    }
    return _peakHourArray;
}

- (NSMutableArray *)valleyHourArray{
    if (!_valleyHourArray) {
        self.valleyHourArray = [[NSMutableArray alloc]init];
    }
    return _valleyHourArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)whtherChangePeakData {
    
    if (self.lastPeakValleyModel.on != self.peakValleyModel.on) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.peakStartHour != self.peakValleyModel.peakStartHour) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.peakStartMinute != self.peakValleyModel.peakStartMinute) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.peakEndHour != self.peakValleyModel.peakEndHour) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.peakEndMinute != self.peakValleyModel.peakEndMinute) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.valleyStartHour != self.peakValleyModel.valleyStartHour) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.valleyStartMinute != self.peakValleyModel.valleyStartMinute) {
        return YES;
    }
    
    if (self.lastPeakValleyModel.valleyEndHour != self.peakValleyModel.valleyEndHour) {
        return YES;
    }
    
    if (!AUXWhtherNullString(self.lastPeakValleyModel.addTime) && !AUXWhtherNullString(self.peakValleyModel.addTime) && ![self.lastPeakValleyModel.addTime isEqualToString:self.peakValleyModel.addTime]) {
        return YES;
    }
    
    return NO;
}

#pragma mark setter
- (void)setPeakValleyModel:(AUXPeakValleyModel *)peakValleyModel {
    _peakValleyModel = peakValleyModel;
    
    // 只有当虚拟体验时，传进来的 peakValleyModel 才会为nil
    if (!_peakValleyModel) {
        _peakValleyModel = [[AUXPeakValleyModel alloc] init];
    }
}

#pragma mark - Actions
- (void)backAtcion {
    [super backAtcion];
    
    if ([self whtherChangePeakData]) {
        [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改?" confirmAtcion:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancleAtcion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)confirmAtcion:(id)sender {
    
    if (self.deviceInfo.virtualDevice) {
        [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
        return ;
    }
    
    if (!self.device) {
        return;
    }
    
    NSString *errorMessage = nil;
    
    if (![self.deviceControlViewController canTurnOnPeakValley:&errorMessage]) {
        [self showErrorViewWithMessage:errorMessage];
        return;
    }
    
    if (self.peakValleyModel.on) {
        NSInteger peakStartHour = self.peakValleyModel.peakStartHour;
        NSInteger peakEndHour = self.peakValleyModel.peakEndHour;
        NSInteger valleyStartHour = self.peakValleyModel.valleyStartHour;
        NSInteger valleyEndHour = self.peakValleyModel.valleyEndHour;
        
        if (self.valleyHourArray.count!=0) {
            [self.valleyHourArray removeAllObjects];
        }
        
        if (self.peakHourArray.count !=0) {
            [self.peakHourArray removeAllObjects];
        }
        
        
        if ((peakStartHour == peakEndHour) || (valleyStartHour == valleyEndHour)) {
            [self showErrorViewWithMessage:@"开始时间不能等于结束时间"];
            return;
        }

        if ((peakStartHour == valleyStartHour) || (peakEndHour == valleyEndHour)) {
            [self showErrorViewWithMessage:@"波峰时段和波谷时段有冲突"];
            return;
        }

        if (peakStartHour < valleyStartHour && peakEndHour > valleyStartHour) {
            [self showErrorViewWithMessage:@"波峰时段和波谷时段有冲突"];
            return;
        }

        if (valleyStartHour < peakStartHour && valleyEndHour > peakStartHour) {
            [self showErrorViewWithMessage:@"波峰时段和波谷时段有冲突"];
            return;
        }

        if (peakEndHour == valleyStartHour && valleyEndHour < valleyStartHour && valleyEndHour > peakStartHour) {
            [self showErrorViewWithMessage:@"波峰时段和波谷时段有冲突"];
            return;
        }
        
        
        if (peakStartHour  <= peakEndHour) {
            NSInteger a;
            for (a = peakStartHour; a<=peakEndHour; a++) {
                [self.peakHourArray addObject:[NSString stringWithFormat:@"%ld",a]];
            }
        }else{
             NSInteger a;
            for (a=peakStartHour; a<24; a++) {
                 [self.peakHourArray addObject:[NSString stringWithFormat:@"%ld",a]];
            }
           NSInteger b;
            for (b=0; b<=peakEndHour; b++) {
                 [self.peakHourArray addObject:[NSString stringWithFormat:@"%ld",b]];
            }
        }
        
        if (valleyStartHour  <= valleyEndHour) {
            NSInteger a;
            for (a = valleyStartHour; a<= valleyEndHour; a++) {
                [self.valleyHourArray addObject:[NSString stringWithFormat:@"%ld",a]];
            }
        }else{
            NSInteger a;
            for (a=valleyStartHour; a<24; a++) {
                [self.valleyHourArray addObject:[NSString stringWithFormat:@"%ld",a]];
            }
            NSInteger b;
            for (b=0; b<=valleyEndHour; b++) {
                [self.valleyHourArray addObject:[NSString stringWithFormat:@"%ld",b]];
            }
        }
        
          self.valleyHourArray = [[self.valleyHourArray valueForKeyPath:@"@distinctUnionOfObjects.self"] mutableCopy];
        
          self.peakHourArray = [[self.peakHourArray valueForKeyPath:@"@distinctUnionOfObjects.self"] mutableCopy];

        
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        
        for (NSString *str in self.valleyHourArray) {
            
            for (NSString *str1 in self.peakHourArray) {
                if ([str1 isEqualToString:str]) {
                    [arr addObject:str];
                }
            }
            
        }
        if (arr.count>1) {
            [self showErrorViewWithMessage:@"波峰时段和波谷时段有冲突"];
            return;
        }
    }
    
    if (self.device.bLDevice) {
        [self savePeakValleyBySDK];
    } else {
        [self savePeakValleyByServer];
    }
}

- (void)invalidateTimer {
    [self hideLoadingHUD];
    
    if (self.oldDeviceTimer) {
        [self.oldDeviceTimer invalidate];
        self.oldDeviceTimer = nil;
    }
    
    [self showFailure:@"保存失败" completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)savePeakValleyBySDK {
    
    [self showLoadingHUD];
    
    AUXACPeakValleyPower *peakValleyPower = [self.peakValleyModel convertToSDKPeakValleyPower];
    
    [[AUXACNetwork sharedInstance] setPeakValleyPowerForDevice:self.device peakStartTime:peakValleyPower.peakStartTime peakEndTime:peakValleyPower.peakEndTime valleyStartTime:peakValleyPower.valleyStartTime valleyEndTime:peakValleyPower.valleyEndTime enabled:peakValleyPower.enabled];
    
    self.oldDeviceTimer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:DeviceControlCommondMaxTime target:self selector:@selector(invalidateTimer) userInfo:nil repeats:NO];
    
}

- (void)savePeakValleyByServer {
    
    [self showLoadingHUD];
    
    if (!self.peakValleyModel.peakValleyId || self.peakValleyModel.peakValleyId.length == 0) {
        self.peakValleyModel.deviceId = self.deviceInfo.deviceId;
        
        [[AUXNetworkManager manager] addPeakValley:self.peakValleyModel completion:^(NSString * _Nullable peakValleyId, NSError * _Nonnull error) {
            [self hideLoadingHUD];
            [self handleNetworkResult:error peakValleyId:peakValleyId];
        }];
    } else {
        [[AUXNetworkManager manager] updatePeakValley:self.peakValleyModel completion:^(NSError * _Nonnull error) {
            [self hideLoadingHUD];
            [self handleNetworkResult:error peakValleyId:nil];
        }];
    }
}

- (void)handleNetworkResult:(NSError *)error peakValleyId:(NSString *)peakValleyId {
    switch (error.code) {
        case AUXNetworkErrorNone: {
            if ([peakValleyId length] > 0) {
                self.peakValleyModel.peakValleyId = peakValleyId;
            }
            
            [self showSuccess:@"保存成功" completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
            break;
            
        case AUXNetworkErrorAccountCacheExpired:
            [self hideLoadingHUD];
            [self alertAccountCacheExpiredMessage];
            break;
            
        default:
            [self hideLoadingHUD];
            [self showErrorViewWithError:error defaultMessage:@"保存失败"];
            self.peakValleyModel.on = !self.peakValleyModel.on;
            break;
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.peakValleyModel.on) {
        return 3;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return AUXSwitchTableViewCell.properHeight;
    } else if (indexPath.row == 1) {
        return AUXTimePeriodPickerTableViewCell.properHeight;
    } else {
        return AUXTimePeriodPickerTableViewCell.properHeight - 16;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    AUXPeakVallyFooterView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"AUXPeakVallyFooterView" owner:nil options:nil] firstObject];
    footerView.contentLabel.text = @"峰谷节电功能仅支持制冷模式，用于在波峰时段节约您的用电量。";
    [footerView.contentLabel setLabelAttributedString:@"仅支持制冷模式" color:[UIColor colorWithHexString:@"10BFCA"]];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0: {
            AUXSwitchTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:@"AUXSwitchTableViewCell" forIndexPath:indexPath];
            cell = switchCell;
            
            switchCell.titleLabel.text = @"峰谷节电";
            switchCell.switchButton.selected = self.peakValleyModel.on;
            
            @weakify(self , switchCell);
            switchCell.switchBlock = ^(BOOL on) {
                @strongify(self , switchCell);
                
                if (on) {
                    
                    NSString *errorMessage = nil;
                    
                    if (![self.deviceControlViewController canTurnOnPeakValley:&errorMessage]) {
                        [self showErrorViewWithMessage:errorMessage];
                        return;
                    }
                }
                
                switchCell.bottomView.hidden = NO;
                self.peakValleyModel.on = on;
                [tableView reloadData];
            };
        }
            break;
            
        case 1: {
            AUXTimePeriodPickerTableViewCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:@"AUXTimePeriodPickerTableViewCell" forIndexPath:indexPath];
            cell = pickerCell;
            
            pickerCell.titleLabel.text = @"波峰时段";
            
            [pickerCell selectStartHour:self.peakValleyModel.peakStartHour animated:NO];
            [pickerCell selectEndHour:self.peakValleyModel.peakEndHour animated:NO];
            
            @weakify(self);
            pickerCell.didSelectTimeBlock = ^(NSInteger startHour, NSInteger startMinute, NSInteger endHour, NSInteger endMinute) {
                @strongify(self);
                self.peakValleyModel.peakStartHour = startHour;
                self.peakValleyModel.peakStartMinute = startMinute;
                self.peakValleyModel.peakEndHour = endHour;
                self.peakValleyModel.peakEndMinute = endMinute;
            };
        }
            break;
            
        case 2: {
            AUXTimePeriodPickerTableViewCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:@"AUXTimePeriodPickerTableViewCell" forIndexPath:indexPath];
            cell = pickerCell;
            
            if (pickerCell.titleLabelTop.constant != 0) {
                pickerCell.titleLabelTop.constant = 0;
                [pickerCell setNeedsDisplay];
            }
            
            pickerCell.titleLabel.text = @"波谷时段";
            
            [pickerCell selectStartHour:self.peakValleyModel.valleyStartHour animated:NO];
            [pickerCell selectEndHour:self.peakValleyModel.valleyEndHour animated:NO];
            
            @weakify(self);
            pickerCell.didSelectTimeBlock = ^(NSInteger startHour, NSInteger startMinute, NSInteger endHour, NSInteger endMinute) {
                @strongify(self);
                self.peakValleyModel.valleyStartHour = startHour;
                self.peakValleyModel.valleyStartMinute = startMinute;
                self.peakValleyModel.valleyEndHour = endHour;
                self.peakValleyModel.valleyEndMinute = endMinute;
            };
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidSetPeakValleyPowerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    [self hideLoadingHUD];
    
    if (self.oldDeviceTimer) {
        [self.oldDeviceTimer invalidate];
        self.oldDeviceTimer = nil;
    }
    
    if (success) {
        [self showSuccess:@"保存成功" completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
    
        [self showErrorViewWithError:error defaultMessage:@"保存失败"];
        self.peakValleyModel.on = !self.peakValleyModel.on;
    }
    
    
}

@end
