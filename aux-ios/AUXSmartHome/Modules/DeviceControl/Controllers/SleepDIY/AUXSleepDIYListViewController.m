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

#import "AUXSleepDIYListViewController.h"
#import "AUXSleepDIYTimeViewController.h"
#import "AUXSleepDIYDeviceSetViewController.h"
#import "AUXSleepDIYTypeViewController.h"
#import "AUXDeviceControlViewController.h"

#import "AUXButton.h"
#import "AUXDeviceFunctionSwitchTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXCurrentNoDataView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "NSString+AUXCustom.h"

#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXSleepDIYListViewController () <UITableViewDelegate, UITableViewDataSource, AUXACDeviceProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@end

@implementation AUXSleepDIYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXDeviceFunctionSwitchTableViewCell"];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    
    if (self.device) {
        [self.device.delegates addObject:self];
    }
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getSleepDIYList];
}

- (void)initSubviews {
    [super initSubviews];
    
}

- (void)updateUI {

    if (self.sleepDIYList.count == 0) {
        self.tableView.hidden = YES;
    } else {
        self.tableView.hidden = NO;
    }
    [self tableViewReloadData];
}

- (void)setDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    _deviceStatus = deviceStatus;
}

- (BOOL)isSleepDIYOn:(AUXSleepDIYModel *)sleepDIYModel {
    if (sleepDIYModel.deviceManufacturer == 0) {
        
        return self.sleepDIY && [self.currentOnSleepDIYId length] > 0 && [self.currentOnSleepDIYId isEqualToString:sleepDIYModel.sleepDiyId];
    } else {
        return sleepDIYModel.on;
    }
}

- (void)tableViewReloadData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.tableView.isEditing) {
            return ;
        }
        [self.tableView reloadData];
    });
}

#pragma mark - Getters

- (NSMutableArray<AUXSleepDIYModel *> *)sleepDIYList {
    if (!_sleepDIYList) {
        _sleepDIYList = [[NSMutableArray alloc] init];
    }
    
    return _sleepDIYList;
}

- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"device_img_nosleepdiy"];
        _noDataView.titleLabel.text = @"暂无睡眠DIY";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight);
        [self.view addSubview:_noDataView];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}


#pragma mark setter
- (void)setControlType:(AUXDeviceControlType)controlType {
    _controlType = controlType;
}

#pragma mark - Actions

- (IBAction)actionAddSleepDIY:(id)sender {
    
    [self.tableView setEditing:NO animated:NO];
    AUXSleepDIYTypeViewController *sleepDIYVC = [AUXSleepDIYTypeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    sleepDIYVC.addSleepDIY = YES;
    sleepDIYVC.deviceInfo = self.deviceInfo;
    sleepDIYVC.existedModelList = self.sleepDIYList;
    sleepDIYVC.controlType = self.controlType;
    sleepDIYVC.deviceFeature = self.deviceFeature;
    sleepDIYVC.oldDevice = self.oldDevice;
    [self.navigationController pushViewController:sleepDIYVC animated:YES];
    
}

// 跳转到 睡眠DIY编辑/添加界面
- (void)pushSleepDIYEditViewControllerWithMode:(AUXServerDeviceMode)mode addSleepDIY:(BOOL)addSleepDIY sleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel {
    
    AUXSleepDIYDeviceSetViewController *sleepDIYTimeViewController = [AUXSleepDIYDeviceSetViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    sleepDIYTimeViewController.mode = mode;
    sleepDIYTimeViewController.addSleepDIY = addSleepDIY;
    sleepDIYTimeViewController.deviceInfo = self.deviceInfo;
    sleepDIYTimeViewController.sleepDIYModel = sleepDIYModel;
    sleepDIYTimeViewController.existedModelList = self.sleepDIYList;
    sleepDIYTimeViewController.controlType = self.controlType;
    sleepDIYTimeViewController.deviceFeature = self.deviceFeature;
    sleepDIYTimeViewController.oldDevice = self.oldDevice;
    [self.navigationController pushViewController:sleepDIYTimeViewController animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sleepDIYList.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    return self.sleepDIYList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXSleepDIYModel *sleepDIYModel = self.sleepDIYList[indexPath.row];
    
    return AUXDeviceFunctionSwitchTableViewCell.properHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteRowAtcion = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AUXSleepDIYModel *sleepDIYModel = self.sleepDIYList[indexPath.row];
        
        if ([self isSleepDIYOn:sleepDIYModel]) {
            [self showErrorViewWithMessage:@"请关闭睡眠DIY，再删除"];
            [tableView setEditing:NO animated:YES];
            return;
        }
        
        @weakify(self, tableView);
        [self alertWithMessage:@"确定要删除该睡眠DIY吗?" confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
            @strongify(self);
            [self deleteSleepDIY:sleepDIYModel];
        } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:^{
            @strongify(tableView);
            [tableView setEditing:NO animated:YES];
        }];
    }];
    
    UITableViewRowAction *renameRowAtcion = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AUXSleepDIYModel *sleepDIYModel = self.sleepDIYList[indexPath.row];
        
        @weakify(self , sleepDIYModel);
        AUXDeviceInfoAlertView *alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeSleepDIY deviceInfo:self.deviceInfo device:nil address:nil content:sleepDIYModel.name confirm:^(NSString *name) {
            @strongify(self , sleepDIYModel);
            if (self.controlType == AUXDeviceControlTypeVirtual) {
                return ;
            }
            
            if (!self.deviceInfo) {
                return;
            }
            
            if ([name length] == 0) {
                [self showErrorViewWithMessage:@"名称不能为空"];
                return;
            }
            
            sleepDIYModel.name = name;
            
            [self updateSleepDIYByServerModel:sleepDIYModel];
            
        } close:^{
            
        }];
        alertView.currentVC = self;
    }];
    
    deleteRowAtcion.backgroundColor = [UIColor colorWithHexString:@"EF4502"];
    renameRowAtcion.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
    
    return @[deleteRowAtcion];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    AUXSleepDIYModel *sleepDIYModel = self.sleepDIYList[row];
    
    AUXDeviceFunctionSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceFunctionSwitchTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = sleepDIYModel.name;
    
    if (self.device.bLDevice) {
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@小时", @(sleepDIYModel.definiteTime)];
    } else {
        cell.subtitleLabel.text = [sleepDIYModel timePeriod];
    }
    cell.titleLabel.numberOfLines = 1;
    
    NSString *statusStr = [NSString stringWithFormat:@"(%@)" ,  [AUXConfiguration getServerModeName:sleepDIYModel.mode]];
    cell.statusLabel.text = statusStr;
    cell.statusOn = [self isSleepDIYOn:sleepDIYModel];
    
    @weakify(self);
    cell.switchBlock = ^(BOOL on) {
        @strongify(self);
        AUXSleepDIYModel *sleepDIYModel = self.sleepDIYList[row];
        [self switchSleepDIY:sleepDIYModel on:on];
    };
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.sleepDIYList.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AUXSleepDIYModel *sleepDIYModel = self.sleepDIYList[indexPath.row];
    
    if ([self isSleepDIYOn:sleepDIYModel]) {
        [self showErrorViewWithMessage:@"请关闭睡眠DIY，再编辑"];
        return;
    }
    
    [self pushSleepDIYEditViewControllerWithMode:sleepDIYModel.mode addSleepDIY:NO sleepDIYModel:sleepDIYModel];
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidSetSleepDIYPointsForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    if (success) {
        
    } else {
        
    }
}

#pragma mark - 网络请求

- (void)getSleepDIYList {
    
    if (!self.device) {
        return;
    }
    
    [[AUXNetworkManager manager] getSleepDIYListWithDeviceId:self.deviceInfo.deviceId completion:^(NSArray<AUXSleepDIYModel *> * _Nullable sleepDIYList, NSError * _Nonnull error) {
        
        if (error.code == AUXNetworkErrorNone) {
            if (sleepDIYList && sleepDIYList.count > 0) {
                self.sleepDIYList = [NSMutableArray arrayWithArray:sleepDIYList];
            } else {
                self.sleepDIYList = nil;
            }
            
            [self updateUI];

        } else if (error.code == AUXNetworkErrorAccountCacheExpired) {
            [self alertAccountCacheExpiredMessage];
        }
    }];
}

- (void)queryDeviceSleepDIYPoints {
    if (self.device.bLDevice) {
        [[AUXACNetwork sharedInstance] queryDevice:self.device withQueryType:AUXACNetworkQueryTypeSleepDIYPoints deviceType:self.device.deviceType atAddress:self.address];
    }
}

- (void)updateSleepDIYByServerModel:(AUXSleepDIYModel *)sleepDIYModel {
    
    sleepDIYModel.deviceId = self.deviceInfo.deviceId;
    [[AUXNetworkManager manager] updateSleepDIYWithModel:sleepDIYModel completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                
                [self showSuccess:@"保存成功" completion:^{
                    [self tableViewReloadData];
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

- (void)switchSleepDIY:(AUXSleepDIYModel *)sleepDIYModel on:(BOOL)on {
    
    if (on) {
        NSString *message = nil;
        
        // 判断是否允许开启当前选中的睡眠DIY
        BOOL canTurnOnSleepDIY = [self.deviceControlViewController canTurnOnSleepDIY:sleepDIYModel message:&message];
        
        if (!canTurnOnSleepDIY) {
            [self showErrorViewWithMessage:message];
            [self tableViewReloadData];
            return;
        }
    }
    
    // 旧设备睡眠DIY开启，由App马上下发命令
    if (self.device.bLDevice) {
        
        self.sleepDIY = on;
        
        if (on) {
            self.currentOnSleepDIYId = sleepDIYModel.sleepDiyId;
        } else {
            self.currentOnSleepDIYId = nil;
        }
        
        [self tableViewReloadData];
        [self.deviceControlViewController switchSleepDIYBySDK:sleepDIYModel on:on];
    } else {
        [self showLoadingHUD];
        
        [[AUXNetworkManager manager] switchSleepDIYWithId:sleepDIYModel.sleepDiyId on:on completion:^(NSError * _Nonnull error) {
            [self hideLoadingHUD];
            
            switch (error.code) {
                case AUXNetworkErrorNone: {
                    sleepDIYModel.on = on;
                }
                    break;
                    
                case AUXNetworkErrorAccountCacheExpired:
                    [self alertAccountCacheExpiredMessage];
                    break;
                    
                default: {
                    [self showErrorViewWithError:error defaultMessage:@"保存失败"];
                    [self tableViewReloadData];
                }
                    break;
            }
        }];
    }
}

- (void)deleteSleepDIY:(AUXSleepDIYModel *)sleepDIYModel {
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] deleteSleepDIYWithId:sleepDIYModel.sleepDiyId completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self didDeleteSleepDIYModel:sleepDIYModel];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"删除失败"];
                break;
        }
    }];
}

- (void)didDeleteSleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel {
    if ([self.sleepDIYList containsObject:sleepDIYModel]) {
        [self.sleepDIYList removeObject:sleepDIYModel];
    }
    
    [self.tableView setEditing:NO animated:YES];
    [self tableViewReloadData];
    [self updateUI];

}

@end
