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

#import "AUXSchedulerListViewController.h"
#import "AUXSchedulerStatusViewController.h"
#import "AUXSchedulerTimeEditViewController.h"

#import "AUXButton.h"
#import "AUXDeviceFunctionSwitchTableViewCell.h"
#import "AUXCurrentNoDataView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXSchedulerListViewController () <UITableViewDelegate, UITableViewDataSource, AUXACDeviceProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *addBarButtonItem;        // 添加定时

// 用于旧设备
@property (nonatomic, strong) AUXSchedulerModel *operatingSchedulerModel;   // 当前操作的定时
@property (nonatomic, strong) NSTimer *deleteTimer;
@property (nonatomic, strong) NSTimer *switchTimer;

@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@end

@implementation AUXSchedulerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXDeviceFunctionSwitchTableViewCell"];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
    
    if (self.device.bLDevice) {
        [self.device.delegates addObject:self];
    }
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getSchedulerListByServer];
}

- (void)dealloc {
    
}

- (void)updateUI {
    [self.tableView reloadData];
}

- (void)updateUIWithCycleTimerList:(NSArray<AUXACBroadlinkCycleTimer *> *)cycleTimerList {
    if (cycleTimerList && cycleTimerList.count > 0) {
        self.schedulerList = [AUXSchedulerModel schedulerListFromSDKCycleTimerList:cycleTimerList];
    } else {
        self.schedulerList = nil;
    }
    
    [self updateUI];
}

- (void)updateUIWithSchedulerList:(NSArray<AUXSchedulerModel *> *)schedulerList {
    if (schedulerList && schedulerList.count > 0) {
        self.schedulerList = [[NSMutableArray alloc] initWithArray:schedulerList];
    } else {
        self.schedulerList = nil;
    }
    
    [self updateUI];
}

#pragma mark - Getters

- (NSMutableArray<AUXSchedulerModel *> *)schedulerList {
    if (!_schedulerList) {
        _schedulerList = [[NSMutableArray alloc] init];
    }
    
    return _schedulerList;
}

- (UIBarButtonItem *)addBarButtonItem {
    if (!_addBarButtonItem) {
        _addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddScheduler)];
    }
    
    return _addBarButtonItem;
}


- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"device_img_notiming"];
        _noDataView.titleLabel.text = @"暂无定时";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight);
        [self.view addSubview:_noDataView];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}


#pragma mark - Actions

/// 添加定时
- (void)actionAddScheduler {
    
    // 旧设备最多只能添加16个定时
    if (self.device.bLDevice && self.schedulerList.count == 16) {
        [self showErrorViewWithMessage:@"定时已达上限，无法添加"];
        return;
    }
    
    [self pushSchedulerEditViewController:nil addScheduler:YES];
}

/// 跳转到定时编辑界面
- (void)pushSchedulerEditViewController:(AUXSchedulerModel *)schedulerModel addScheduler:(BOOL)addScheduler {
    
    if (addScheduler) {
        AUXSchedulerTimeEditViewController *schedulerEditViewController = [AUXSchedulerTimeEditViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        schedulerEditViewController.deviceInfo = self.deviceInfo;
        schedulerEditViewController.device = self.device;
        schedulerEditViewController.address = self.address;
        schedulerEditViewController.existedSchedulerArray = [NSArray arrayWithArray:self.schedulerList];
        schedulerEditViewController.addScheduler = addScheduler;
        schedulerEditViewController.schedulerModel = schedulerModel;
        schedulerEditViewController.hardwaretype = self.hardwaretype;
        
        [self.navigationController pushViewController:schedulerEditViewController animated:YES];
    } else {
        AUXSchedulerStatusViewController *schedulerEditViewController = [AUXSchedulerStatusViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        schedulerEditViewController.deviceInfo = self.deviceInfo;
        schedulerEditViewController.device = self.device;
        schedulerEditViewController.address = self.address;
        schedulerEditViewController.existedSchedulerArray = [NSArray arrayWithArray:self.schedulerList];
        schedulerEditViewController.addScheduler = addScheduler;
        schedulerEditViewController.schedulerModel = schedulerModel;
        schedulerEditViewController.hardwaretype = self.hardwaretype;
        
        [self.navigationController pushViewController:schedulerEditViewController animated:YES];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.schedulerList.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    return self.schedulerList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUXDeviceFunctionSwitchTableViewCell.properHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    AUXSchedulerModel *schedulerModel = self.schedulerList[row];
    
    AUXDeviceFunctionSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceFunctionSwitchTableViewCell" forIndexPath:indexPath];
    
    NSString *statusStr;
    if (schedulerModel.deviceOperate) {
        statusStr = [NSString stringWithFormat:@"(%@、%@)" , schedulerModel.deviceOperate == 1 ? @"开机" : @"关机" , [AUXConfiguration getServerModeName:schedulerModel.mode]];
    } else {
        statusStr = @"(关机)";
    }
    
    cell.statusLabel.text = statusStr;
    cell.statusOn = schedulerModel.on;
    cell.titleLabel.text = schedulerModel.timeString;
    cell.subtitleLabel.text = schedulerModel.repeatDescription;
    
    cell.titleLabel.font = [UIFont systemFontOfSize:20];
    cell.statusLabel.font = [UIFont systemFontOfSize:16];
    cell.statusLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.subtitleLabel.font = [UIFont systemFontOfSize:14];
    cell.subtitleLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
    
    @weakify(self);
    cell.switchBlock = ^(BOOL on) {
        @strongify(self);
        AUXSchedulerModel *schedulerModel = self.schedulerList[row];
        [self switchSchedulerByServer:schedulerModel on:on];
    };
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.schedulerList.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AUXSchedulerModel *schedulerModel = self.schedulerList[indexPath.row];
    
    [self pushSchedulerEditViewController:schedulerModel addScheduler:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            AUXSchedulerModel *schedulerModel = self.schedulerList[indexPath.row];
            
            @weakify(self, tableView);
            [self alertWithMessage:@"确定要删除定时吗?" confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
                @strongify(self);
                [self deleteSchedulerByServer:schedulerModel];
            } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:^{
                @strongify(tableView);
                [tableView setEditing:NO animated:YES];
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 网络请求

/// 通过服务器获取定时列表
- (void)getSchedulerListByServer {
    
    if (!self.device) {
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self getSchedulerListBySDK];
        return;
    }
    
    [self showLoadingHUD];
    
    NSString *address = nil;
    
    if (self.deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
        address = self.deviceInfo.addressArray.firstObject;
    }
    
    [[AUXNetworkManager manager] getSchedulerListWithDeviceId:self.deviceInfo.deviceId address:address completion:^(NSArray<AUXSchedulerModel *> * _Nullable schedulerList, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self updateUIWithSchedulerList:schedulerList];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"获取定时列表失败"];
                break;
        }
    }];
}

/// 通过SDK获取定时列表
- (void)getSchedulerListBySDK {
    [self showLoadingHUD];
    [[AUXACNetwork sharedInstance] getTimerListOfDevice:self.device hardwareType:self.hardwaretype];
}

/// 通过服务器删除定时
- (void)deleteSchedulerByServer:(AUXSchedulerModel *)schedulerModel {
    
    if (!self.device) {
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self deleteSchedulerBySDK:schedulerModel];
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] deleteSchedulerWithId:schedulerModel.schedulerId completion:^(NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                if ([self.schedulerList containsObject:schedulerModel]) {
                    [self.schedulerList removeObject:schedulerModel];
                    [self.tableView reloadData];
                }
 
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self deleteSchedulerFailed];
                break;
        }
    }];
}

/// 通过SDK删除定时
- (void)deleteSchedulerBySDK:(AUXSchedulerModel *)schedulerModel {
    
    self.operatingSchedulerModel = schedulerModel;
    
    AUXACControl *control = self.device.controlDic[self.address];
    
    [self showLoadingHUD];
    
    self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(deleteSchedulerBySDKTimeout) userInfo:nil repeats:NO];
    

    [[AUXACNetwork sharedInstance] setCycleTimerForDevice:self.device timer:schedulerModel.cycleTimer control:control cmdType:Broadlink2UartCmdDel hardwareType:self.hardwaretype windGearType:self.deviceInfo.windGearType];
}

/// 通过服务器开启/关闭定时
- (void)switchSchedulerByServer:(AUXSchedulerModel *)schedulerModel on:(BOOL)on {
    
    if (!self.device) {
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self switchSchedulerBySDK:schedulerModel on:on];
        return;
    }
    
    schedulerModel.on = on;
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] switchSchedulerWithId:schedulerModel.schedulerId on:on completion:^(NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self switchSchedulerFailed];
                break;
        }
    }];
}

/// 通过SDK开启/关闭定时
- (void)switchSchedulerBySDK:(AUXSchedulerModel *)schedulerModel on:(BOOL)on {
    
    self.operatingSchedulerModel = schedulerModel;
    
    WindGearType gearType = self.deviceInfo.windGearType;
    
    AUXACControl *currentControl = self.device.controlDic[self.address];
    
    schedulerModel.on = on;
    [schedulerModel updateCycleTimer];
    
    AUXACControl *timerControl = [schedulerModel getControlWithGearType:gearType currentControl:currentControl];
    
//    NSLog(@"更新定时: %@ %@", [schedulerModel yy_modelToJSONObject], [schedulerModel.cycleTimer yy_modelToJSONObject]);
    
    [self showLoadingHUD];
    
    self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(switchSchedulerBySDKTimeout) userInfo:nil repeats:NO];
    
    [[AUXACNetwork sharedInstance] setCycleTimerForDevice:self.device timer:schedulerModel.cycleTimer control:timerControl  cmdType:Broadlink2UartCmdEdit hardwareType:self.hardwaretype windGearType:gearType];

}

/// 删除定时超时
- (void)deleteSchedulerBySDKTimeout {
    [self hideLoadingHUD];
    self.deleteTimer = nil;
    
    [self deleteSchedulerFailed];
}

/// 定时开启/关闭操作超时
- (void)switchSchedulerBySDKTimeout {
    [self hideLoadingHUD];
    self.switchTimer = nil;
    
    [self switchSchedulerFailed];
}

/// 删除定时成功
- (void)deleteSchedulerSuccessfully {
    if ([self.schedulerList containsObject:self.operatingSchedulerModel]) {
        [self.schedulerList removeObject:self.operatingSchedulerModel];
        [self.tableView reloadData];
        
        [self getSchedulerListBySDK];
    }
}

/// 删除定时失败
- (void)deleteSchedulerFailed {
    [self showErrorViewWithMessage:@"定时删除失败"];
}

/// 开启/关闭定时成功
- (void)switchSchedulerSuccessfully {
    [self.tableView reloadData];
    
    [self getSchedulerListBySDK];
}

/// 开启/关闭定时失败
- (void)switchSchedulerFailed {
    if (self.operatingSchedulerModel.on) {
        [self showErrorViewWithMessage:@"定时开启失败"];
    } else {
        [self showErrorViewWithMessage:@"定时关闭失败"];
    }
    
    self.operatingSchedulerModel.on = !self.operatingSchedulerModel.on;
    [self.tableView reloadData];
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidGetTimerListOfDevice:(AUXACDevice *)device timerList:(NSArray *)timerList cycleTimerList:(NSArray *)cycleTimerList success:(BOOL)success withError:(NSError *)error {
    
    [self hideLoadingHUD];
    
    if (!success) {
        NSLog(@"定时列表界面 设备【古北】 %@ 查询定时列表失败: %@", device.bLDevice.mac, error);
        
        if (error.code == -100) {
            self.navigationItem.rightBarButtonItem = nil;
        } else {
            self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
        }
        
        return;
    }
    
    NSLog(@"定时列表界面 设备【古北】 %@ 查询定时列表成功: %@", device.bLDevice.mac, [cycleTimerList yy_modelToJSONObject]);
    [self updateUIWithCycleTimerList:cycleTimerList];
}

- (void)auxACNetworkDidSetCycleTimerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    
    [self hideLoadingHUD];
    
    if (self.deleteTimer) {
        [self.deleteTimer invalidate];
        self.deleteTimer = nil;
        
        if (success) {
            NSLog(@"定时列表界面 设备【古北】 %@ 删除定时成功", device.bLDevice.mac);
            [self deleteSchedulerSuccessfully];
        } else {
            NSLog(@"定时列表界面 设备【古北】 %@ 删除定时失败: %@", device.bLDevice.mac, error);
            [self deleteSchedulerFailed];
        }
    } else if (self.switchTimer) {
        [self.switchTimer invalidate];
        self.switchTimer = nil;
        
        if (success) {
            NSLog(@"定时列表界面 设备【古北】 %@ 开启/关闭定时成功", device.bLDevice.mac);
            [self switchSchedulerSuccessfully];
        } else {
            NSLog(@"定时列表界面 设备【古北】 %@ 开启/关闭定时失败: %@", device.bLDevice.mac, error);
            [self switchSchedulerFailed];
        }
    }
}

@end
