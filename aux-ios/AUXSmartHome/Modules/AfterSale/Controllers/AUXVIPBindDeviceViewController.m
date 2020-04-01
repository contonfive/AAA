//
//  AUXVIPBindDeviceViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/12.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXVIPBindDeviceViewController.h"
#import "AUXVIPImportDeviceTableViewCell.h"
#import "AUXAfterSaleHeaderView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXDeviceInfo.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"

#import <SDWebImage/UIImageView+WebCache.h>


@interface AUXVIPBindDeviceViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *tableBackView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (nonatomic,strong) AUXDeviceInfo *selectedDeviceInfo;
@property (nonatomic, strong, readonly) NSArray<AUXDeviceInfo *> *deviceInfoArray;    // 设备列表
@end

@implementation AUXVIPBindDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXVIPImportDeviceTableViewCell"];
    
    self.sureButton.enabled = NO;
    
    self.sureButton.layer.cornerRadius = self.sureButton.frame.size.height / 2;
    self.sureButton.layer.borderColor = [UIColor colorWithHexString:@"666666"].CGColor;
    self.sureButton.layer.borderWidth = 2;
    self.sureButton.layer.masksToBounds = YES;
}
#pragma mark atcions
- (IBAction)sureAtcion:(id)sender {
    
    if (!self.selectedDeviceInfo) {
        [self showFailure:@"未选择设备"];
        return ;
    }
    
    [self requestBindDeviceWithDeviceInfo:self.selectedDeviceInfo];
}

- (IBAction)jumpAtcion:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark getter
- (NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    
    NSMutableArray *dataArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    NSMutableArray *array = [NSMutableArray array];
    for (AUXDeviceInfo *deviceInfo in dataArray) {
        if (!AUXWhtherNullString(deviceInfo.sn)) {
            [array addObject:deviceInfo];
        }
    }
    [dataArray removeObjectsInArray:array];
    
    return dataArray;
}

#pragma mark 网络请求
- (void)requestBindDeviceWithDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    if (!deviceInfo) {
        return ;
    }
    
    if (AUXWhtherNullString(self.deviceSN)) {
        return ;
    }
    [[AUXNetworkManager manager] updateDeviceInfoWithMac:deviceInfo.mac deviceSN:self.deviceSN alias:deviceInfo.alias completion:^(NSError * _Nonnull error) {
        if (error.code == 200) {
            [self showSuccess:@"设备关联成功" completion:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceInfoArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AUXAfterSaleHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"AUXAfterSaleHeaderView" owner:nil options:nil].firstObject;
    headerView.titleLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
    headerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    headerView.titleLabel.text = @"将其关联到设备列表中已有设备：";
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXVIPImportDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VIPImportDeviceTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    [cell.deviceIcon sd_setImageWithURL:[NSURL URLWithString:deviceInfo.deviceMainUri] placeholderImage:nil options:SDWebImageRefreshCached];
    cell.deviceNameLabel.text = deviceInfo.alias;
    cell.selectedImageView.hidden = YES;
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.deviceInfoArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self hideSelectedImage];
    
    AUXVIPImportDeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImageView.hidden = NO;
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    self.selectedDeviceInfo = deviceInfo;
    
    self.sureButton.enabled = YES;
}

- (void)hideSelectedImage {
    
    for (NSInteger i = 0; i < self.deviceInfoArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        AUXVIPImportDeviceTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectedImageView.hidden = YES;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

@end
