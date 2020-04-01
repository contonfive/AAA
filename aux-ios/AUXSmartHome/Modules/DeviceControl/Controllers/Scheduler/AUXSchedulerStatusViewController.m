//
//  AUXSchedulerStatusViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSchedulerStatusViewController.h"
#import "AUXSchedulerEditTableViewCell.h"
#import "AUXSchedulerTimeEditViewController.h"
#import "AUXSchedulerDeviceEditViewController.h"

#import "AUXAfterSaleHeaderView.h"
#import "AUXAlertCustomView.h"

#import "AUXNetworkManager.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "NSError+AUXCustom.h"

@interface AUXSchedulerStatusViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *sureBarButtonItem;

@property (nonatomic, strong) NSTimer *deleteTimer;
@property (nonatomic, strong) NSTimer *editTimer;

@property (nonatomic, copy) AUXSchedulerModel *lastSchedulerModel;
@end

@implementation AUXSchedulerStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.device.delegates addObject:self];
    [self.tableView registerCellWithNibName:@"AUXSchedulerEditTableViewCell"];
    
    self.lastSchedulerModel = [self.schedulerModel copy];
    self.customBackAtcion = YES;
}

- (void)editStatus:(AUXSchedulerModel *)schedulerModel {
    self.schedulerModel = schedulerModel;
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = self.sureBarButtonItem;
    
}

- (BOOL)whtherEditSchedulerData {
    
    if (self.lastSchedulerModel.deviceOperate != self.schedulerModel.deviceOperate) {
        return NO;
    }
    
    if (self.lastSchedulerModel.mode != self.schedulerModel.mode) {
        return NO;
    }
    
    if (self.lastSchedulerModel.windSpeed != self.schedulerModel.windSpeed) {
        return NO;
    }
    
    if (self.lastSchedulerModel.temperature != self.schedulerModel.temperature) {
        return NO;
    }
    
    if (self.lastSchedulerModel.hour != self.schedulerModel.hour) {
        return NO;
    }
    
    if (self.lastSchedulerModel.minute != self.schedulerModel.minute) {
        return NO;
    }
    
    if (self.lastSchedulerModel.repeatValue != self.schedulerModel.repeatValue) {
        return NO;
    }
    
    return YES;
}

#pragma mark getter
- (UIBarButtonItem *)sureBarButtonItem {
    if (!_sureBarButtonItem) {
        _sureBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(actionEditScheduler:)];
    }
    
    return _sureBarButtonItem;
}

#pragma mark atcion
- (void)backAtcion {
    [super backAtcion];
    
    if (![self whtherEditSchedulerData]) {
        [AUXAlertCustomView alertViewWithMessage:@"是否放弃更改?" confirmAtcion:^{
            [self.navigationController popViewControllerAnimated:YES];
        } cancleAtcion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionEditScheduler:(UIBarButtonItem *)item {
    [self editSchedulerByServer];
}

- (IBAction)deleteAtcion:(id)sender {
    @weakify(self);
    [self alertWithMessage:@"确定删除定时吗?" confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
        @strongify(self);
        [self deleteSchedulerByServer];
    } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:nil];
}

#pragma mark 网络请求
/// 通过服务器更新定时
- (void)editSchedulerByServer {
    
    if (!self.device) {
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self editSchedulerBySDK];
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] updateSchedulerWithModel:self.schedulerModel completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self editSchedulerSuccessfully];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self editSchedulerFailed:error];
                break;
        }
    }];
}

/// 通过SDK更新定时
- (void)editSchedulerBySDK {
    
    WindGearType gearType = self.deviceInfo.windGearType;
    
    AUXACControl *currentControl = self.device.controlDic[self.address];
    
    [self.schedulerModel updateCycleTimer];
    
    AUXACControl *timerControl = [self.schedulerModel getControlWithGearType:gearType currentControl:currentControl];
    
    NSLog(@"更新定时: %@ %@", [self.schedulerModel yy_modelToJSONObject], [self.schedulerModel.cycleTimer yy_modelToJSONObject]);
    
    [self showLoadingHUD];
    
    self.editTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(editSchedulerBySDKTimeout) userInfo:nil repeats:NO];
    
    [[AUXACNetwork sharedInstance] setCycleTimerForDevice:self.device timer:self.schedulerModel.cycleTimer control:timerControl cmdType:Broadlink2UartCmdEdit hardwareType:self.hardwaretype windGearType:gearType];
}

/// 通过SDK更新定时超时
- (void)editSchedulerBySDKTimeout {
    [self hideLoadingHUD];
    self.editTimer = nil;
    
    [self editSchedulerFailed:[NSError errorForTimeout]];
}

/// 更新定时成功
- (void)editSchedulerSuccessfully {
    @weakify(self);
    [self showSuccess:@"修改成功" completion:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

/// 更新定时失败
- (void)editSchedulerFailed:(NSError *)error {
    [self showErrorViewWithError:error defaultMessage:@"修改失败"];
}

/// 通过服务器删除定时
- (void)deleteSchedulerByServer {
    
    if (!self.device) {
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self deleteSchedulerBySDK];
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] deleteSchedulerWithId:self.schedulerModel.schedulerId completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self deleteSchedulerSuccessfully];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self deleteSchedulerFailed:error];
                break;
        }
    }];
}

/// 通过SDK删除定时
- (void)deleteSchedulerBySDK {
    
    AUXACControl *currentControl = self.device.controlDic[self.address];
    
    [self showLoadingHUD];
    
    self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(deleteSchedulerBySDKTimeout) userInfo:nil repeats:NO];
    
    [[AUXACNetwork sharedInstance] setCycleTimerForDevice:self.device timer:self.schedulerModel.cycleTimer control:currentControl cmdType:Broadlink2UartCmdDel hardwareType:self.hardwaretype windGearType:self.deviceInfo.windGearType];
}


/// 通过SDK删除定时超时
- (void)deleteSchedulerBySDKTimeout {
    [self hideLoadingHUD];
    self.deleteTimer = nil;
    
    [self deleteSchedulerFailed:[NSError errorForTimeout]];
}

/// 删除定时成功
- (void)deleteSchedulerSuccessfully {
    @weakify(self);
    [self showSuccess:@"删除成功" completion:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

/// 删除定时失败
- (void)deleteSchedulerFailed:(NSError *)error {
    [self showErrorViewWithError:error defaultMessage:@"删除失败"];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUXSchedulerEditTableViewCell.properHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AUXAfterSaleHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"AUXAfterSaleHeaderView" owner:nil options:nil].firstObject;
    headerView.titleLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
    headerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    if (section == 0) {
        headerView.titleLabel.text = @"执行时间";
    } else {
        headerView.titleLabel.text = @"设备操作";
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXSchedulerEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSchedulerEditTableViewCell" forIndexPath:indexPath] ;
    
    cell.schedulerModel = self.schedulerModel;
    if (indexPath.section == 0) {
        cell.type = AUXDeviceControlSchedulerTypeOfTime;
    } else {
        cell.type = AUXDeviceControlSchedulerTypeOfDevice;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        AUXSchedulerTimeEditViewController *schedulerEditTimeViewController = [AUXSchedulerTimeEditViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        schedulerEditTimeViewController.deviceInfo = self.deviceInfo;
        schedulerEditTimeViewController.device = self.device;
        schedulerEditTimeViewController.address = self.address;
        schedulerEditTimeViewController.existedSchedulerArray = self.existedSchedulerArray;
        schedulerEditTimeViewController.addScheduler = self.addScheduler;
        schedulerEditTimeViewController.schedulerModel = self.schedulerModel;
        schedulerEditTimeViewController.hardwaretype = self.hardwaretype;
        
        schedulerEditTimeViewController.editSuccessBlock = ^(AUXSchedulerModel * _Nonnull schedulerModel) {
            [self editStatus:schedulerModel];
        };
        
        [self.navigationController pushViewController:schedulerEditTimeViewController animated:YES];
    } else {
        
        AUXSchedulerDeviceEditViewController *schedulerEditDeviceViewController = [AUXSchedulerDeviceEditViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        schedulerEditDeviceViewController.deviceInfo = self.deviceInfo;
        schedulerEditDeviceViewController.device = self.device;
        schedulerEditDeviceViewController.address = self.address;
        schedulerEditDeviceViewController.existedSchedulerArray = self.existedSchedulerArray;
        schedulerEditDeviceViewController.addScheduler = self.addScheduler;
        schedulerEditDeviceViewController.schedulerModel = self.schedulerModel;
        schedulerEditDeviceViewController.hardwaretype = self.hardwaretype;
        
        schedulerEditDeviceViewController.editSuccessBlock = ^(AUXSchedulerModel * _Nonnull schedulerModel) {
            [self editStatus:schedulerModel];
            
        };
        
        [self.navigationController pushViewController:schedulerEditDeviceViewController animated:YES];
    }
}


#pragma mark - AUXACDeviceProtocol
- (void)auxACNetworkDidSetCycleTimerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    
    NSLog(@"didSetCycleTimer success: %@, error: %@", @(success), error);
    
    [self hideLoadingHUD];
    
    if (self.editTimer) {
        [self.editTimer invalidate];
        self.editTimer = nil;
        
        if (success) {
            [self editSchedulerSuccessfully];
        } else {
            [self editSchedulerFailed:error];
        }
    } else if (self.deleteTimer) {
        [self.deleteTimer invalidate];
        self.deleteTimer = nil;
        
        if (success) {
            [self deleteSchedulerSuccessfully];
        } else {
            [self deleteSchedulerFailed:error];
        }
    }
}

@end
