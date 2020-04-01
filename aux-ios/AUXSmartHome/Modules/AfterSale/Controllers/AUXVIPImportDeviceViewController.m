//
//  AUXVIPImportDeviceViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/12.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXVIPImportDeviceViewController.h"
#import "AUXScanCodeViewController.h"
#import "AUXVIPImportDeviceTableViewCell.h"
#import "UITableView+AUXCustom.h"
#import "AUXDeviceInfo.h"
#import "AUXUser.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXVIPImportDeviceViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong, readonly) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;    // 设备列表
@end

@implementation AUXVIPImportDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXVIPImportDeviceTableViewCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark getter
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {

    NSMutableArray *dataArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    NSMutableArray *array = [NSMutableArray array];
    for (AUXDeviceInfo *deviceInfo in dataArray) {
        if (AUXWhtherNullString(deviceInfo.sn)) {
            [array addObject:deviceInfo];
        }
    }
    [dataArray removeObjectsInArray:array];
    
    return dataArray;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXVIPImportDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VIPImportDeviceTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    [cell.deviceIcon sd_setImageWithURL:[NSURL URLWithString:deviceInfo.deviceMainUri] placeholderImage:nil options:SDWebImageRefreshCached];
    cell.deviceNameLabel.text = deviceInfo.alias;
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.deviceInfoArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    if (self.deviceSnBlock) {
        self.deviceSnBlock(deviceInfo.sn);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

@end
