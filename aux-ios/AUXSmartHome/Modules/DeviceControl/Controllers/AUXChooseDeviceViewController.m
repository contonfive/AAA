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

#import "AUXChooseDeviceViewController.h"
#import "AUXDeviceShareQRCodeViewController.h"
#import "AUXDeviceControlViewController.h"

#import "AUXButton.h"
#import "AUXChooseDeviceTableViewCell.h"
#import "AUXChooseDeviceLeftTableViewCell.h"
#import "AUXChooseDeviceSubtitleTableViewCell.h"

#import "UITableView+AUXCustom.h"

#import "AUXNetworkManager.h"

//#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AUXDeviceStateInfo.h"


@interface AUXChooseDeviceViewController () <QMUINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet AUXButton *confirmButton;

@property (nonatomic, strong) UIBarButtonItem *selectAllBarButtonItem;  // 全选
@property (nonatomic, strong) UIBarButtonItem *sureBarButtonItem;  // 全选

// 多联机子设备地址列表，用于排序显示子设备
@property (nonatomic, strong) NSArray<NSString *> *addressArray;

@property (nonatomic,strong) NSMutableDictionary *deviceDictionary;

@end

@implementation AUXChooseDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.purpose) {
        case AUXChooseDevicePurposeShareDevice: // 选择要分享的设备
            self.title = @"选择分享设备";
            self.deviceInfoArray = [AUXUser defaultUser].deviceInfoArray;
            self.navigationItem.rightBarButtonItem = self.sureBarButtonItem;
            break;
            
        case AUXChooseDevicePurposeControlDevice:   // 单联机、多联机集中控制
            self.title = @"选择设备";
            self.navigationItem.rightBarButtonItem = self.selectAllBarButtonItem;
            break;
            
        case AUXChooseDevicePurposeChooseSubdevice: {   // 多联机，选择子设备
            self.bottomView.hidden = YES;
            self.tableViewBottom.constant = 0;
        }   // 这里不要加 break
            
        case AUXChooseDevicePurposeControlSubdevice: {  // 多联机子设备集中控制
            self.title = self.deviceInfo.alias;
            self.navigationItem.rightBarButtonItem = self.selectAllBarButtonItem;
            
            // address 从小到大排序
            self.addressArray = [self.deviceInfo.device.aliasDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSString *key1 = (NSString *)obj1;
                NSString *key2 = (NSString *)obj2;
                
                NSComparisonResult result = [key1 compare:key2 options:NSCaseInsensitiveSearch];
                return result;
            }];
        }
            break;
            
        default:
            break;
    }
    
    [self.tableView registerCellWithNibName:@"AUXChooseDeviceTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXChooseDeviceLeftTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXChooseDeviceSubtitleTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark getter
- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    
    return [AUXUser defaultUser].deviceDictionary;
}

- (UIBarButtonItem *)selectAllBarButtonItem {
    if (!_selectAllBarButtonItem) {
        _selectAllBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(actionSelectAll)];
    }
    
    return _selectAllBarButtonItem;
}

- (UIBarButtonItem *)sureBarButtonItem {
    if (!_sureBarButtonItem) {
        _sureBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(actionShareDevice)];
    }
    return _sureBarButtonItem;
}

- (NSMutableArray<NSNumber *> *)selectedRows {
    if (!_selectedRows) {
        _selectedRows = [[NSMutableArray alloc] init];
    }
    
    return _selectedRows;
}

- (NSMutableArray<NSString *> *)selectedAddresses {
    if (!_selectedAddresses) {
        _selectedAddresses = [[NSMutableArray alloc] init];
    }
    
    return _selectedAddresses;
}

#pragma mark - Actions

- (IBAction)actionConfirm:(id)sender {
    
    switch (self.purpose) {
        case AUXChooseDevicePurposeShareDevice: {   // 选择要分享的设备
            
            self.confirmButton.selected = !self.confirmButton.selected;
            
            if (self.confirmButton.selected) {
                [self actionSelectAll];
            } else {
                [self.selectedRows removeAllObjects];
                [self.tableView reloadData];
            }
        }
            break;
            
        case AUXChooseDevicePurposeControlDevice: { // 选择要集中控制的设备
            [self actionMultiControl];
        }
            break;
            
        case AUXChooseDevicePurposeControlSubdevice: {  // 多联机子设备集中控制
            [self actionMultiControlSubdevices];
        }
            break;
            
        default:
            break;
    }
}

/// 分享设备
- (void)actionShareDevice {
    if (self.selectedRows.count == 0) {
        [self showErrorViewWithMessage:@"请选择有效设备"];
        return;
    }
    
    NSMutableArray<NSString *> *deviceIdArray = [[NSMutableArray alloc] init];
    for (NSNumber *row in self.selectedRows) {
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray[row.integerValue];
        [deviceIdArray addObject:deviceInfo.deviceId];
    }
    
    // 生成二维码
    [self getQRContentWithDeviceIdArray:deviceIdArray];
}

/// 集中控制 (单联机、多联机混控)
- (void)actionMultiControl {
    if (self.selectedRows.count == 0) {
        [self showErrorViewWithMessage:@"请选择有效设备"];
        return;
    }
    
    NSMutableArray<AUXDeviceInfo *> *deviceInfoArray = [[NSMutableArray alloc] init];
    for (NSNumber *row in self.selectedRows) {
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray[row.integerValue];
        [deviceInfoArray addObject:deviceInfo];
    }
    
    // 获取集中控制功能列表
    [self getMultiControlFunctionListWithDeviceInfoArray:deviceInfoArray];
}

/// 集中控制多联机子设备
- (void)actionMultiControlSubdevices {
    if (self.selectedAddresses.count == 0) {
        [self showErrorViewWithMessage:@"请选择有效设备"];
        return;
    }
    
    self.deviceInfo.addressArray = self.selectedAddresses;
    
    // 获取集中控制功能列表
    [self getMultiControlFunctionListWithDeviceInfoArray:@[self.deviceInfo]];
}

/// 选择全部设备
- (void)actionSelectAll {
    
    switch (self.purpose) {
        case AUXChooseDevicePurposeShareDevice: {
            [self.selectedRows removeAllObjects];
            
            for (NSInteger row = 0; row < self.deviceInfoArray.count; row++) {
                
                AUXDeviceInfo*info = self.deviceInfoArray[row];
                if (info.userTag == AUXDeviceShareTypeFriend) {
                    [self showToastshortWithmessageinCenter:@"好友身份不能分享"];
                }else{
                   [self.selectedRows addObject:@(row)];
                }
            }
            
            [self.tableView reloadData];
            break;
        }
            
        case AUXChooseDevicePurposeControlDevice: {
            [self.selectedRows removeAllObjects];
            
            for (NSInteger row = 0; row < self.deviceInfoArray.count; row++) {
                
                AUXDeviceInfo *deviceInfo = self.deviceInfoArray[row];
                AUXACDevice *device = deviceInfo.device;
                
                if (device.wifiState != AUXACNetworkDeviceWifiStateOnline) {
                    continue;
                }
                
                if (device.controlDic.count == 0) {
                    continue;
                }
                
                if (deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
                    if (device.aliasDic.count == 0) {
                        continue;
                    }
                    
                    deviceInfo.addressArray = [NSArray arrayWithArray:device.aliasDic.allKeys];
                }
                
                [self.selectedRows addObject:@(row)];
            }
            
            [self.tableView reloadData];
        }
            break;
            
        case AUXChooseDevicePurposeControlSubdevice: {
            [self.selectedAddresses removeAllObjects];
            [self.selectedAddresses addObjectsFromArray:self.deviceInfo.device.aliasDic.allKeys];
            [self.tableView reloadData];
        }
            break;
            
        case AUXChooseDevicePurposeChooseSubdevice: {
            [self.selectedAddresses removeAllObjects];
            [self.selectedAddresses addObjectsFromArray:self.deviceInfo.device.aliasDic.allKeys];
            [self.tableView reloadData];
            
            if (self.didSelectSubdevices) {
                self.didSelectSubdevices(self.selectedAddresses);
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    switch (self.purpose) {
        case AUXChooseDevicePurposeShareDevice:
        case AUXChooseDevicePurposeControlDevice:
            numberOfRows = self.deviceInfoArray.count;
            break;
            
        case AUXChooseDevicePurposeChooseSubdevice:
        case AUXChooseDevicePurposeControlSubdevice:
            numberOfRows = self.deviceInfo.device.aliasDic.count;
            break;
            
        default:
            break;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUXChooseDeviceTableViewCell.properHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (self.purpose) {
        case AUXChooseDevicePurposeShareDevice:
            cell = [self tableView:tableView shareDeviceCellForRowAtIndexPath:indexPath];
            break;
            
        case AUXChooseDevicePurposeControlDevice:
            cell = [self tableView:tableView controlDeviceCellForRowAtIndexPath:indexPath];
            break;
            
        case AUXChooseDevicePurposeChooseSubdevice:
        case AUXChooseDevicePurposeControlSubdevice:
        default:
            cell = [self tableView:tableView controlSubdeviceCellForRowAtIndexPath:indexPath];
            break;
    }
    
    return cell;
}

// 分享设备
- (UITableViewCell *)tableView:(UITableView *)tableView shareDeviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXChooseDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXChooseDeviceTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    cell.titleLabel.text = deviceInfo.alias;
    
    AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
    BOOL iscontain = [deviceStateinfo.dataArray containsObject:deviceInfo.deviceId];
    if (iscontain) {
        cell.outLineLabel.text = @"";
        cell.outLineImageView.hidden = YES;
    }else{
        cell.outLineLabel.text = @"(离线)";
        cell.outLineImageView.hidden = NO;
    }

    NSString *placeholderImageName;
    switch (deviceInfo.suitType) {
        case AUXDeviceSuitTypeAC:
            placeholderImageName = @"device_list_device_icon_01";
            break;
            
        default:
            placeholderImageName = @"device_list_device_icon_04";
            break;
    }
    
    NSURL *imageURL = [NSURL URLWithString:deviceInfo.deviceMainUri];
    [cell.iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:placeholderImageName] options:SDWebImageRefreshCached];
    
    NSNumber *row = @(indexPath.row);
    
    cell.chosen = [self.selectedRows containsObject:row];
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.deviceInfoArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

// 集中控制设备
- (UITableViewCell *)tableView:(UITableView *)tableView controlDeviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXBaseTableViewCell *cell;
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    
    switch (deviceInfo.suitType) {
        case AUXDeviceSuitTypeAC:
            cell = [self tableView:tableView controlACDeviceCellForRowAtIndexPath:indexPath];
            break;
            
        default:
            cell = [self tableView:tableView controlGatewayDeviceCellForRowAtIndexPath:indexPath];
            break;
    }
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.deviceInfoArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

// 集中控制设备 - 单元机
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView controlACDeviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXChooseDeviceLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXChooseDeviceLeftTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    
    AUXACDevice *device = self.deviceDictionary[deviceInfo.deviceId];
    AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
    
    if (!device || !deviceControl) {  // SDK未找到对应的设备
        cell.offline = YES;
    } else {
        cell.offline = (device.wifiState != AUXACNetworkDeviceWifiStateOnline) ? YES : NO;
    }
    
    NSURL *imageURL = [NSURL URLWithString:deviceInfo.deviceMainUri];
    [cell.iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"device_list_device_icon_01"] options:SDWebImageRefreshCached];
    cell.titleLabel.text = deviceInfo.alias;
    
    NSNumber *row = @(indexPath.row);
    
    cell.chosen = [self.selectedRows containsObject:row];
    
    return cell;
}

// 集中控制设备 - 多联机
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView controlGatewayDeviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXChooseDeviceSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXChooseDeviceSubtitleTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    AUXACDevice *device = deviceInfo.device;
    AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
    
    if (!device || !deviceControl) {  // SDK未找到对应的设备
        cell.offline = YES;
    } else {
        cell.offline = (device.wifiState != AUXACNetworkDeviceWifiStateOnline) ? YES : NO;
    }
    
    NSURL *imageURL = [NSURL URLWithString:deviceInfo.deviceMainUri];
    [cell.iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"device_list_device_icon_04"] options:SDWebImageRefreshCached];
    cell.titleLabel.text = deviceInfo.alias;
    
    cell.totalCount = device.aliasDic.count;
    cell.selectedCount = deviceInfo.addressArray.count;
    
    cell.chosen = (deviceInfo.addressArray && deviceInfo.addressArray.count > 0);
    
    return cell;
}

// 多联机 子设备
- (AUXBaseTableViewCell *)tableView:(UITableView *)tableView controlSubdeviceCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXChooseDeviceLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXChooseDeviceLeftTableViewCell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    NSString *address = self.addressArray[row];
    NSString *deviceName = self.deviceInfo.device.aliasDic[address];
    
    NSURL *imageURL = [NSURL URLWithString:self.deviceInfo.deviceMainUri];
    [cell.iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"device_list_device_icon_04"] options:SDWebImageRefreshCached];
    cell.titleLabel.text = deviceName;
    
    cell.chosen = [self.selectedAddresses containsObject:address];
    
    cell.offline = NO;
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.addressArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AUXChooseDeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (self.purpose) {
        case AUXChooseDevicePurposeShareDevice:
            [self tableView:tableView didSelectShareDeviceAtIndexPath:indexPath];
            break;
            
        case AUXChooseDevicePurposeControlDevice:
            
            if (cell.offline) {
                [self showErrorViewWithMessage:@"设备离线，无法选择"];
                return ;
            }
            [self tableView:tableView didSelectControlDeviceAtIndexPath:indexPath];
            break;
            
        case AUXChooseDevicePurposeControlSubdevice:
        case AUXChooseDevicePurposeChooseSubdevice:
            [self tableView:tableView didSelectSubdeviceAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

/// 更新 selectedRows
- (void)tableView:(UITableView *)tableView updateSelectedRowsWithIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    
    NSNumber *row = @(indexPath.row);
    AUXChooseDeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // 选则或取消选择某台单元机
    if (self.purpose == AUXChooseDevicePurposeShareDevice || deviceInfo.suitType == AUXDeviceSuitTypeAC) {
        if ([self.selectedRows containsObject:row]) {
            [self.selectedRows removeObject:row];
            cell.chosen = NO;
        } else {
            [self.selectedRows addObject:row];
            cell.chosen = YES;
        }
        if (self.selectedRows.count < self.deviceInfoArray.count) {
            self.confirmButton.selected = NO;
        }
        
    } else {
        // 更新某台多联机选中的子设备个数
        AUXChooseDeviceSubtitleTableViewCell *subtitleCell = (AUXChooseDeviceSubtitleTableViewCell *)cell;
        
        if ([deviceInfo.addressArray count] == 0 && [self.selectedRows containsObject:row]) {
            if ([self.selectedRows containsObject:row]) {
                [self.selectedRows removeObject:row];
                subtitleCell.chosen = NO;
            }
        } else if ([deviceInfo.addressArray count] > 0 && ![self.selectedRows containsObject:row]) {
            [self.selectedRows addObject:row];
            subtitleCell.chosen = YES;
        }
        
        subtitleCell.selectedCount = [deviceInfo.addressArray count];
    }
}

/// 选择要分享的设备
- (void)tableView:(UITableView *)tableView didSelectShareDeviceAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    
    // 设备分享，设备权限为“朋友”时，无分享权限。
    if (deviceInfo.userTag == AUXDeviceShareTypeFriend) {
        [self showErrorViewWithMessage:@"好友身份不能分享"];
        return;
    }
    
    [self tableView:tableView updateSelectedRowsWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectControlDeviceAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    
    AUXACDevice *device = [[AUXUser defaultUser] getSDKDeviceWithMac:deviceInfo.mac];
    
    if (!device) {
        return;
    }
    
    switch (deviceInfo.suitType) {
        case AUXDeviceSuitTypeAC: {  // 单元机
            AUXACControl *control = device.controlDic[kAUXACDeviceAddress];
            
            if (!control) {
                return;
            }
            
            [self tableView:tableView updateSelectedRowsWithIndexPath:indexPath];
        }
            break;
            
        default: {  // 多联机，跳转到选择子设备
            AUXChooseDeviceViewController *chooseDeviceViewController = [AUXChooseDeviceViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
            chooseDeviceViewController.purpose = AUXChooseDevicePurposeChooseSubdevice;
            chooseDeviceViewController.deviceInfo = deviceInfo;
            
            if (deviceInfo.addressArray) {
                chooseDeviceViewController.selectedAddresses = [deviceInfo.addressArray mutableCopy];
            }
            
            @weakify(self, deviceInfo, indexPath);
            chooseDeviceViewController.didSelectSubdevices = ^(NSArray<NSString *> *addressArray) {
                @strongify(self, deviceInfo, indexPath);
                deviceInfo.addressArray = addressArray;
                [self tableView:self.tableView updateSelectedRowsWithIndexPath:indexPath];
            };
            
            [self.navigationController pushViewController:chooseDeviceViewController animated:YES];
        }
            break;
    }
}

/// 选择子设备
- (void)tableView:(UITableView *)tableView didSelectSubdeviceAtIndexPath:(NSIndexPath *)indexPath {
    NSString *address = self.addressArray[indexPath.row];
    
    AUXChooseDeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedAddresses containsObject:address]) {
        [self.selectedAddresses removeObject:address];
        cell.chosen = NO;
    } else {
        [self.selectedAddresses addObject:address];
        cell.chosen = YES;
    }
    
    if (self.purpose == AUXChooseDevicePurposeChooseSubdevice && self.didSelectSubdevices) {
        self.didSelectSubdevices(self.selectedAddresses);
    }
}

#pragma mark - 网络请求

/// 获取分享二维码内容
- (void)getQRContentWithDeviceIdArray:(NSArray<NSString *> *)deviceIdArray {
    
    [self showLoadingHUD];
    [[AUXNetworkManager manager] getDeviceShareQRContentWithDeviceIdArray:deviceIdArray type:self.deviceShareType completion:^(NSString * _Nullable qrContent, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                AUXDeviceShareQRCodeViewController *qrcodeViewController = [AUXDeviceShareQRCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                qrcodeViewController.type = self.deviceShareType;
                qrcodeViewController.qrContent = qrContent;
                qrcodeViewController.qrCodeStatus = AUXQRCodeStatusOfShareDevice;
                qrcodeViewController.deviceNames = [NSMutableArray array];
                for (NSString *deviceID in deviceIdArray) {
                    for (NSNumber *row in self.selectedRows) {
                        AUXDeviceInfo *deviceInfo = self.deviceInfoArray[row.integerValue];
                        if ([deviceID isEqualToString:deviceInfo.deviceId]) {
                            [qrcodeViewController.deviceNames addObject:deviceInfo.alias];
                        }
                    }
                }
                [self.navigationController pushViewController:qrcodeViewController animated:YES];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"生成二维码失败"];
                break;
        }
    }];
}

/// 获取集中控制功能列表
- (void)getMultiControlFunctionListWithDeviceInfoArray:(NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    
    AUXDeviceFeature *multiDeviceFeature = [AUXDeviceFeature multiDeviceFeature];
    
    if (multiDeviceFeature) {
        [self pushControlViewControllerWithDeviceInfoArray:deviceInfoArray];
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] getMultiControlFunctionListWithCompletion:^(NSString * _Nullable feature, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        if (error.code == AUXNetworkErrorAccountCacheExpired) {
            [self alertAccountCacheExpiredMessage];
            return;
        }
        
        AUXDeviceFeature *deviceFeature;
        if (error.code == AUXNetworkErrorNone) {
            deviceFeature = [[AUXDeviceFeature alloc] initWithJSON:feature];
            deviceFeature.hasDeviceInfo = NO;
        } else {
            deviceFeature = [AUXDeviceFeature createDefaultMultiDeviceFeature];
        }
        
        [AUXDeviceFeature setMultiDeviceFeature:deviceFeature];
        [self pushControlViewControllerWithDeviceInfoArray:deviceInfoArray];
    }];
}

/// 跳转到设备控制界面
- (void)pushControlViewControllerWithDeviceInfoArray:(NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    AUXDeviceControlViewController *deviceControlViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    deviceControlViewController.controlType = AUXDeviceControlTypeGatewayMultiDevice;
    deviceControlViewController.deviceInfoArray = deviceInfoArray;
    
    [self.navigationController pushViewController:deviceControlViewController animated:YES];
}

@end

