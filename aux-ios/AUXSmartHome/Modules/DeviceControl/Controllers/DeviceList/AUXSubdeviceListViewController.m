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

#import "AUXSubdeviceListViewController.h"
#import "AUXDeviceControlViewController.h"

#import "AUXChooseDeviceTableViewCell.h"
#import "AUXButton.h"
#import "UITableView+AUXCustom.h"

//#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXSubdeviceListViewController () <QMUINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, AUXACDeviceProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AUXButton *allSlectedBtn;

// 多联机子设备地址列表，用于排序显示子设备
@property (nonatomic, strong) NSArray<NSString *> *addressArray;
@property (nonatomic,strong) NSMutableArray *selectedArray;

@end

@implementation AUXSubdeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"集中控制";
    
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
    
    [self.tableView registerCellWithNibName:@"AUXChooseDeviceTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initSubviews {
    [super initSubviews];
    
}

#pragma mark - Getters

- (AUXACDevice *)device {
    return self.deviceInfo.device;
}

- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

#pragma mark atcions

- (IBAction)allSelectedAtcion:(id)sender {
    
    [self.selectedArray removeAllObjects];
    
    self.allSlectedBtn.selected = !self.allSlectedBtn.selected;
    
    if (self.allSlectedBtn.selected) {
        for (NSInteger i = 0; i < self.addressArray.count; i++) {
            [self.selectedArray addObject:@(i)];
        }
    }
    [self.tableView reloadData];
    
}

- (IBAction)sureAtcion:(id)sender {
    
    if (self.selectedArray.count == 0) {
        [self showErrorViewWithMessage:@"请选择有效设备"];
        return;
    }
    
    NSMutableArray *addressArray = [NSMutableArray array];
    for (NSNumber *index in self.selectedArray) {
        [addressArray addObject:self.addressArray[index.integerValue]];
    }
    
    AUXDeviceControlViewController *deviceControlViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfo;
    deviceInfo.device = self.device;
    deviceInfo.addressArray = addressArray;
    
    deviceControlViewController.deviceInfoArray = @[deviceInfo];
    deviceControlViewController.controlType = AUXDeviceControlTypeGatewayMultiDevice;
    
    [self.navigationController pushViewController:deviceControlViewController animated:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUXChooseDeviceTableViewCell.properHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    NSString *address = self.addressArray[row];
    
    NSString *deviceName = self.device.aliasDic[address];
    
    AUXChooseDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXChooseDeviceTableViewCell" forIndexPath:indexPath];
    
    NSURL *imageURL = [NSURL URLWithString:self.deviceInfo.deviceMainUri];
    [cell.iconImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"device_list_device_icon_04"] options:SDWebImageRefreshCached];
    
    cell.titleLabel.text = deviceName;
    cell.chosen = [self.selectedArray containsObject:@(indexPath.row)];
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.addressArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AUXChooseDeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL result = [self.selectedArray containsObject:@(indexPath.row)];
    result = !result;
    if (result) {
        cell.chosen = YES;
        [self.selectedArray addObject:@(indexPath.row)];
    } else {
        cell.chosen = NO;
        if ([self.selectedArray containsObject:@(indexPath.row)]) {
             [self.selectedArray removeObject:@(indexPath.row)];
        }
       
    }
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
