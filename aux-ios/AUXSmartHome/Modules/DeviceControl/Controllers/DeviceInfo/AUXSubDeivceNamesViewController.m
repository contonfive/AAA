//
//  AUXSubDeivceNamesViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSubDeivceNamesViewController.h"

#import "AUXSubDeviceNameTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
@interface AUXSubDeivceNamesViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 多联机子设备地址列表，用于排序显示子设备
@property (nonatomic, strong) NSArray<NSString *> *addressArray;
@end

@implementation AUXSubDeivceNamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
        [self.tableView reloadData];
    }
    [self.tableView registerCellWithNibName:@"AUXSubDeviceNameTableViewCell"];
}

#pragma mark getter
- (AUXACDevice *)device {
    return self.deviceInfo.device;
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
    return 60;
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
    
    AUXSubDeviceNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubDeviceNameTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = deviceName;
    
    cell.editNameBlock = ^{
        [self editNameAtcion:deviceName address:address];
    };
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.addressArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark atcion
- (void)editNameAtcion:(NSString *)deviceName address:(NSString *)address {
    @weakify(self);
    
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
        
        [self.tableView reloadData];
        
    } close:^{
        
    }];
    
    alertView.currentVC = self;
}
@end
