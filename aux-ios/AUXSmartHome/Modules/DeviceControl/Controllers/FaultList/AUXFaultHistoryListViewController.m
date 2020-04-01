//
//  AUXFaultHistoryListViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXFaultHistoryListViewController.h"

#import "AUXFaultHistoryTableViewCell.h"

#import "UIColor+AUXCustom.h"
#import "UITableView+AUXCustom.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"

@interface AUXFaultHistoryListViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter1;
@property (nonatomic,strong) NSArray<AUXFaultInfo *> *faultInfoList;
@end

@implementation AUXFaultHistoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXFaultHistoryTableViewCell"];
    
    self.dateFormatter1 = [[NSDateFormatter alloc] init];
    self.dateFormatter1.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self requestHistoryFaultList];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.faultInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXFaultHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"faultCell" forIndexPath:indexPath];
    
    AUXFaultInfo *faultInfo = self.faultInfoList[indexPath.row];
    cell.contentLabel.text = faultInfo.faultReason;
    
    if (!AUXWhtherNullString(faultInfo.occurrenceTime)) {
        cell.detailTimeLabel.text = faultInfo.occurrenceTime;
    } else {
        
        cell.contentLabelBottom.constant = CGRectGetHeight(cell.contentLabel.frame) / 2;
        [cell layoutIfNeeded];
    }
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.faultInfoList.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark 网络请求
- (void)requestHistoryFaultList {
    
    if (AUXWhtherNullString(self.deviceInfo.mac)) {
        return ;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] getFaultListWithMac:self.deviceInfo.mac completion:^(NSArray<AUXFaultInfo *> * _Nullable faultInfoList, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (error.code == AUXNetworkErrorNone) {
            self.faultInfoList = faultInfoList;
            
            [self.tableView reloadData];
            
        }
    }];
}

@end
