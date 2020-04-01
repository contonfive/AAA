//
//  AUXGatewaySubDeviceViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXGatewaySubDeviceViewController.h"
#import "AUXDeviceControlViewController.h"
#import "AUXSubdeviceListViewController.h"

#import "AUXSubdeviceTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXGatewaySubDeviceViewController ()<UITableViewDelegate , UITableViewDataSource , AUXACDeviceProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 多联机子设备地址列表，用于排序显示子设备
@property (nonatomic, strong) NSArray<NSString *> *addressArray;
@end

@implementation AUXGatewaySubDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.deviceInfo.alias;
    
    if (self.device) {
        [self.device.delegates addObject:self];
        
        // address 从小到大排序
        self.addressArray = [self.device.aliasDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *key1 = (NSString *)obj1;
            NSString *key2 = (NSString *)obj2;
            
            NSComparisonResult result = [key1 compare:key2 options:NSCaseInsensitiveSearch];
            return result;
        }];
        
        [self.device setNeedUpdateSubDeviceAliases];
    }
    
    [self.tableView registerCellWithNibName:@"AUXSubdeviceTableViewCell"];
}

#pragma mark getter
- (AUXACDevice *)device {
    return self.deviceInfo.device;
}

#pragma mark atcion
- (IBAction)mutalControlAtcion:(id)sender {
    
    AUXSubdeviceListViewController *subdeviceListViewController = [AUXSubdeviceListViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    subdeviceListViewController.deviceInfo = self.deviceInfo;
    [self.navigationController pushViewController:subdeviceListViewController animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUXSubdeviceTableViewCell.properHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    NSString *address = self.addressArray[row];
    
    NSString *deviceName = self.device.aliasDic[address];
    
    AUXSubdeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubdeviceTableViewCell" forIndexPath:indexPath];
    
    NSURL *imageURL = [NSURL URLWithString:self.deviceInfo.deviceMainUri];
    [cell.iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"device_list_device_icon_04"] options:SDWebImageRefreshCached];
    cell.deviceName = deviceName;
    
    cell.indicatorImageView.hidden = YES;
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.addressArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *address = self.addressArray[indexPath.row];
    NSString *deviceName = self.device.aliasDic[address];
    
    @weakify(self);
    UITableViewRowAction *renameRowAtcion = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AUXDeviceInfoAlertView *alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeSubdeviceName deviceInfo:self.deviceInfo device:self.device address:address content:deviceName confirm:^(NSString *name) {
            @strongify(self);
            if (self.deviceInfo.virtualDevice) {
                [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
                return ;
            }
            
            if (!self.deviceInfo) {
                return;
            }
            
            if ([name length] == 0) {
                [self showErrorViewWithMessage:@"名称不能为空"];
                return;
            }
            
            self.device.aliasDic[address] = name;
            
            [tableView reloadData];
            
        } close:^{
            
        }];
        alertView.currentVC = self;
        
    }];
    
    renameRowAtcion.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
    
    return @[renameRowAtcion];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 正在编辑子设备名称
    if (tableView.isEditing) {
        
        [self showErrorViewWithMessage:@"列表正在编辑"];
        return;
    }
    
    // 跳转到控制界面，单控子设备
    NSString *address = self.addressArray[indexPath.row];
    
    AUXDeviceControlViewController *deviceControlViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfo;
    deviceInfo.device = self.device;
    deviceInfo.addressArray = @[address];
    
    deviceControlViewController.deviceInfoArray = @[deviceInfo];
    deviceControlViewController.controlType = AUXDeviceControlTypeSubdevice;
    
    [self.navigationController pushViewController:deviceControlViewController animated:YES];
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type {
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
        switch (type) {
            case AUXACNetworkQueryTypeControl:
                //                NSLog(@"子设备列表界面 设备 %@ %@ 控制状态上报: %@", typeString, mac, device.controlDic);
                break;
                
            case AUXACNetworkQueryTypeStatus:
                //                NSLog(@"子设备列表界面 设备 %@ %@ 运行状态上报: %@", typeString, mac, device.statusDic);
                break;
                
            case AUXACNetworkQueryTypeSubDevices:
                //                NSLog(@"子设备列表界面 设备 %@ %@ 子设备列表: %@", typeString, mac, device.aliasDic);
                break;
                
            case AUXACNetworkQueryTypeAliasOfSubDevice:
                //                NSLog(@"子设备列表界面 设备 %@ %@ 子设备别名: %@ %@", typeString, mac, address, device.aliasDic[address]);
                break;
                
            case AUXACNetworkQueryTypeAliasesOfSubDevices:
                //                NSLog(@"子设备列表界面 设备 %@ %@ 子设备别名列表: %@", typeString, mac, device.aliasDic);
                break;
                
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        //        NSLog(@"子设备列表界面 设备 %@ %@ 状态上报错误 type: %@ error: %@", typeString, mac, @(type), error);
    }
}
@end
