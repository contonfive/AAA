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

#import "AUXDeviceInfoViewController.h"
#import "AUXDeviceShareViewController.h"
#import "AUXScanCodeViewController.h"
#import "AUXFaultHistoryListViewController.h"
#import "AUXSubDeivceNamesViewController.h"

#import "AUXSubtitleTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXAlertCustomView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

#import <AUXACNetwork/AUXACDevice.h>

@interface AUXDeviceInfoViewController () <UITableViewDelegate, UITableViewDataSource , AUXACDeviceProtocol , AUXACNetworkProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSString *firmwareVersion;//固件版本

@property (nonatomic, strong) NSMutableArray<AUXDeviceShareInfo *> *deviceShareInfoList;    // 分享列表
@property (nonatomic, strong) NSMutableArray<AUXFaultInfo *> *faultInfoList;

@property (nonatomic,strong) NSMutableArray <NSNumber *> *rowTypeArray;
@end

@implementation AUXDeviceInfoViewController

- (NSMutableArray<NSNumber *> *)rowTypeArray {
    if (!_rowTypeArray) {
        _rowTypeArray = [NSMutableArray array];
        
        [_rowTypeArray addObject:@(AUXDeviceInfoRowTypeOfDeviceName)];
        [_rowTypeArray addObject:@(AUXDeviceInfoRowTypeOfDeviceSn)];
        [_rowTypeArray addObject:@(AUXDeviceInfoRowTypeOfDeviceMac)];
        [_rowTypeArray addObject:@(AUXDeviceInfoRowTypeOfDeviceFirmwareVersion)];
        [_rowTypeArray addObject:@(AUXDeviceInfoRowTypeOfDeviceHistoryFaults)];
        [_rowTypeArray addObject:@(AUXDeviceInfoRowTypeOfDeviceShare)];
        
    }
    return _rowTypeArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    
    [self.device.delegates addObject:self];
    [[AUXACNetwork sharedInstance] getFirmwareVersionForDevice:self.device];
    
    // 旧设备不显示历史故障信息
    if (self.deviceInfo.source == AUXDeviceSourceGizwits) {
        [self getDeviceFaultList];
    }
    
    if (self.controlType == AUXDeviceControlTypeGateway || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        if ([self.rowTypeArray containsObject:@(AUXDeviceInfoRowTypeOfDeviceSn)]) {
            [self.rowTypeArray removeObject:@(AUXDeviceInfoRowTypeOfDeviceSn)];
        }
        [self.rowTypeArray insertObject:@(AUXDeviceInfoRowTypeOfDeviceSubName) atIndex:1];
    }
    
    if (self.oldDevice) {
        if ([self.rowTypeArray containsObject:@(AUXDeviceInfoRowTypeOfDeviceHistoryFaults)]) {
            [self.rowTypeArray removeObject:@(AUXDeviceInfoRowTypeOfDeviceHistoryFaults)];
        }
    }
    if (self.deviceInfo.userTag == AUXDeviceShareTypeFriend) {
        if ([self.rowTypeArray containsObject:@(AUXDeviceInfoRowTypeOfDeviceShare)]) {
            [self.rowTypeArray removeObject:@(AUXDeviceInfoRowTypeOfDeviceShare)];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidDeleteShareNotification:) name:AUXDeviceDidDeleteShareNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceNameDidChangeNotification:) name:AUXDeviceNameDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceSNDidChangeNotification:) name:AUXDeviceSNDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getDeviceShareList];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)actionDeleteDevice:(id)sender {
    
    if (!self.deviceInfo) {
        return;
    }
    
    if (self.deviceInfo.virtualDevice) {
        [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
        return ;
    }
    
    @weakify(self);
    [self alertWithMessage:@"确定要删除设备吗?" confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
        @strongify(self);
        [self unbindDevice];
    } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.rowTypeArray.count;
    } else {
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXBaseTableViewCell *cell;
    if (indexPath.section == 0) {
        
        NSNumber *rowType = self.rowTypeArray[indexPath.row];
        
        switch (rowType.integerValue) {
            case AUXDeviceInfoRowTypeOfDeviceName:
                // 设备名称
                cell = [self tableView:tableView deviceNameCellForRowAtIndexPath:indexPath];
                break;
            case AUXDeviceInfoRowTypeOfDeviceSubName:
                // 子设备名称
                cell = [self tableView:tableView deviceSubNameCellForRowAtIndexPath:indexPath];
                break;
            case AUXDeviceInfoRowTypeOfDeviceSn:
                // 设备SN码
                cell = [self tableView:tableView deviceSNCellForRowAtIndexPath:indexPath];
                break;
            case AUXDeviceInfoRowTypeOfDeviceMac:
                //mac 地址
                cell = [self tableView:tableView macCellForRowAtIndexPath:indexPath];
                break;
            case AUXDeviceInfoRowTypeOfDeviceFirmwareVersion:
                // 固件版本
                cell = [self tableView:tableView firmwareVersionCellForRowAtIndexPath:indexPath];
                break;
            case AUXDeviceInfoRowTypeOfDeviceHistoryFaults:
                // 历史故障信息
                cell = [self tableView:tableView faultListCellForRowAtIndexPath:indexPath];
                break;
            case AUXDeviceInfoRowTypeOfDeviceShare:
                // 设备分享
                cell = [self tableView:tableView shareCellForRowAtIndexPath:indexPath];
                break;
                
            default:
                break;
        }
        
        cell.bottomView.hidden = NO;
        if (indexPath.row == self.rowTypeArray.count - 1) {
            cell.bottomView.hidden = YES;
        }
        
    } else {
        // 删除设备
        AUXSubtitleTableViewCell *deleteCell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
        
        deleteCell.titleLabel.text = @"删除设备";
        deleteCell.subtitleLabel.hidden = YES;
        deleteCell.indicatorImageView.hidden = YES;
        cell = deleteCell;
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}

- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView deviceNameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = @"设备名称";
    cell.indicatorImageView.hidden = NO;
    
    cell.subtitleLabel.text = self.deviceInfo.alias;
    
    return cell;
}

- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView deviceSubNameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = @"子设备";
    cell.indicatorImageView.hidden = NO;
    
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%ld台" , self.device.aliasDic.allKeys.count];
    
    return cell;
}


- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView deviceSNCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"设备SN码";
    cell.indicatorImageView.hidden = NO;
    
    if (self.deviceInfo.sn && self.deviceInfo.sn.length > 0) {
        cell.subtitleLabel.text = self.deviceInfo.sn;
        cell.indicatorImageView.hidden = YES;
        cell.subtitleLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
    } else {
        cell.subtitleLabel.text = @"待完善";
        cell.subtitleLabel.textColor = [UIColor colorWithHexString:@"C1C1C1"];
    }
    
    return cell;
}

- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView macCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"Mac地址";
    cell.subtitleLabel.text = self.deviceInfo.mac;
    
    cell.indicatorImageView.hidden = YES;
    
    return cell;
}

- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView firmwareVersionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"固件版本";
    cell.subtitleLabel.text = self.firmwareVersion;
    cell.indicatorImageView.hidden = YES;
    if ([cell.subtitleLabel.text isEqualToString:@"0"]) {
        cell.subtitleLabel.text = @"";
    }
    
    return cell;
}

- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView faultListCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"历史故障信息";
    cell.subtitleLabel.hidden = YES;
    cell.indicatorImageView.hidden = NO;
    
    return cell;
}

- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView shareCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"设备共享";
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@位子用户", @([self.deviceShareInfoList count])];
    cell.indicatorImageView.hidden = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AUXDeviceInfoAlertView *alertView = nil;
    
    if (indexPath.section == 0) {
        
        NSNumber *rowType = self.rowTypeArray[indexPath.row];
        
        switch (rowType.integerValue) {
            case AUXDeviceInfoRowTypeOfDeviceName: {
                // 设备名称
                alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeDeviceName deviceInfo:self.deviceInfo device:self.device address:self.address content:self.deviceInfo.alias confirm:^(NSString *name) {
                    
                    self.deviceInfo.alias = name;
                    
                    [tableView reloadData];
                } close:^{}];
                alertView.currentVC = self;
                break;
            }
            case AUXDeviceInfoRowTypeOfDeviceSubName:{
                
                if (!self.device || self.device.controlDic.allKeys.count == 0) {
                    return ;
                }
                
                AUXSubDeivceNamesViewController *subDeviceViewController = [AUXSubDeivceNamesViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                
                subDeviceViewController.deviceInfo = self.deviceInfo;
                [self.navigationController pushViewController:subDeviceViewController animated:YES];
                
                break;
            }
            case AUXDeviceInfoRowTypeOfDeviceSn: {
                // 设备SN码
                if (!self.deviceInfo.sn || self.deviceInfo.sn.length == 0)  {
                    
                    alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeDeviceSN deviceInfo:self.deviceInfo device:self.device address:self.address content:self.deviceInfo.sn confirm:^(NSString *name) {
                        
                        self.deviceInfo.sn = name;
                        
                        [tableView reloadData];
                    } close:^{}];
                    alertView.currentVC = self;
                    
                    @weakify(alertView);
                    alertView.deviceSnBlock = ^{
                        @strongify(alertView);
                        AUXScanCodeViewController *scanVC = [AUXScanCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
                        scanVC.scanPurpose = AUXScanPurposeCompletingDeviceSN;
                        @weakify(alertView);
                        scanVC.didScanCodeBlock = ^(NSString *code) {
                            @strongify(alertView);
                            
                            if (!alertView) {
                                
                                alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeDeviceSN deviceInfo:self.deviceInfo device:self.device address:self.address content:self.deviceInfo.sn confirm:^(NSString *name) {
                                    @weakify(alertView);
                                    self.deviceInfo.sn = name;
                                    [tableView reloadData];
                                    
                                } close:^{}];
                                alertView.currentVC = self;
                            }
                            alertView.deviceSn = code;
                        };
                        [self.navigationController pushViewController:scanVC animated:YES];
                    };
                }
                break;
            }
            case AUXDeviceInfoRowTypeOfDeviceHistoryFaults: {
                // 历史故障信息
                AUXFaultHistoryListViewController *faultListVC = [AUXFaultHistoryListViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                faultListVC.deviceInfo = self.deviceInfo;
                [self.navigationController pushViewController:faultListVC animated:YES];
            }
                break;
            case AUXDeviceInfoRowTypeOfDeviceShare: {
                // 设备分享
                AUXDeviceShareViewController *deviceShareViewController = [AUXDeviceShareViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                deviceShareViewController.deviceInfo = self.deviceInfo;
                [self.navigationController pushViewController:deviceShareViewController animated:YES];
                break;
            }
                
            default:
                break;
        }
        
    } else {
        if (!self.deviceInfo) {
            return;
        }
        
        if (self.deviceInfo.virtualDevice) {
            [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
            return ;
        }
        
        if (indexPath.section == 1) {
            @weakify(self);
            
            [AUXAlertCustomView alertViewWithMessage:@"确定要删除设备吗?" confirmAtcion:^{
                @strongify(self);
                [self unbindDevice];
            } cancleAtcion:^{
                
            }];
            return ;
        }
    }
}

#pragma mark - auxDeviceDelegates

- (void)auxACNetworkDidGetFirmwareVersionForDevice:(AUXACDevice *)device firmwareVersion:(int)firmwareVersion success:(BOOL)success withError:(NSError *)error {
    if (firmwareVersion) {
        self.firmwareVersion = [NSString stringWithFormat:@"%d" , firmwareVersion];
        [self.tableView reloadData];
    }
}

#pragma mark - Notifications

/// 解除了分享
- (void)deviceDidDeleteShareNotification:(NSNotification *)notification {
    AUXDeviceShareInfo *shareInfo = (AUXDeviceShareInfo *)notification.object;
    
    if ([self.deviceShareInfoList containsObject:shareInfo]) {
        [self.deviceShareInfoList removeObject:shareInfo];
        [self.tableView reloadData];
    }
}

/// 修改了设备名
- (void)deviceNameDidChangeNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

/// 修改了设备SN码
- (void)deviceSNDidChangeNotification:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - 网络请求

/// 获取分享用户列表
- (void)getDeviceShareList {
    
    if (AUXWhtherNullString(self.deviceInfo.deviceId)) {
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] getDeviceShareListWithDeviceId:self.deviceInfo.deviceId completion:^(NSArray<AUXDeviceShareInfo *> * _Nullable deviceShareInfoList, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.deviceShareInfoList = [deviceShareInfoList mutableCopy];
                [self.tableView reloadData];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"获取设备分享信息失败"];
                break;
        }
    }];
}

- (void)getDeviceFaultList {
    if (AUXWhtherNullString(self.deviceInfo.mac)) {
        return;
    }
    
    [[AUXNetworkManager manager] getFaultListWithMac:self.deviceInfo.mac completion:^(NSArray<AUXFaultInfo *> * _Nullable faultInfoList, NSError * _Nonnull error) {
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.faultInfoList = [[NSMutableArray alloc] init];
                
                for (AUXFaultInfo *faultInfo in faultInfoList) {
                    if ([faultInfo.faultId isEqualToString:kAUXFilterFaultId]) {
                        continue;
                    }
                    
                    [self.faultInfoList addObject:faultInfo];
                }
                
                [self.tableView reloadData];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                break;
        }
    }];
}

- (void)unbindDevice {
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] unbindDeviceWithDeviceId:self.deviceInfo.deviceId completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
            case AUXNetworkErrorUserNotAssociateWithDevice: {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceDidUnbindNotification object:self.deviceInfo];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"删除设备失败"];
                break;
        }
    }];
}

@end
