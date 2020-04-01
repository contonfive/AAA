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

#import "AUXMessageManagerViewController.h"
#import "AUXMessageManagerTableViewCell.h"
#import "AUXMessageManagerHeaderView.h"
#import "AUXCurrentNoDataView.h"

#import "AUXMessageLinkViewController.h"

#import "AUXUser.h"
#import "AUXMessageContentModel.h"
#import "AUXNotificationTools.h"
#import "AUXRemoteNotificationModel.h"

#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXTouchRemoteOrShareLink.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "UITableView+AUXCustom.h"
#import "AppDelegate.h"

@interface AUXMessageManagerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic,strong) NSArray *remoteListArray;

@property (nonatomic, retain) NSMutableArray *timeAry;
@property (nonatomic,strong) AUXUser *user;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@end

@implementation AUXMessageManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    // 防止页面跳动
    self.tableView.hidden = YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 防止页面跳动
    self.tableView.hidden = NO;
    
    [self getRemoteDataList];
    //清除所有未读推送
    [self updateAllMessageState];
}

- (void)updateAllMessageState {

    if (![AUXUser isLogin]) {
        return ;
    }
    
    [AUXArchiveTool clearRemoteNotificationNum];
}

#pragma mark 获取本地通知缓存
- (void)getRemoteDataList {
    [self showLoadingHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.timeAry removeAllObjects];
        NSMutableArray *dataList = [[AUXRemoteNotificationModel sharedInstance] unarchiveRemoteNotificationList];
        self.remoteListArray = dataList;
        
        for (NSDictionary *dict in dataList) {
            [self.timeAry addObjectsFromArray:[dict allKeys]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
     [self hideLoadingHUD];
    
}

#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    
    if (self.timeAry.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    return self.timeAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dict = self.remoteListArray[section];
    NSArray *dataArray = [dict.allValues firstObject];
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXMessageContentModel *record;

    NSDictionary *dict = self.remoteListArray[indexPath.section];
    NSArray *dataArray = [dict.allValues firstObject];
    record = (AUXMessageContentModel *)[dataArray objectAtIndex:indexPath.row];

    return record.rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *time = self.timeAry[section];
    AUXMessageManagerHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!headerView) {
        headerView = [[AUXMessageManagerHeaderView alloc]initWithReuseIdentifier:@"headerView"];
    }
    headerView.backColor = self.tableView.backgroundColor;
    headerView.titleLabel.text = time;
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXMessageManagerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageDetailCell" forIndexPath:indexPath];
    
    AUXMessageContentModel *record;
    
    NSDictionary *dict = self.remoteListArray[indexPath.section];
    NSArray *dataArray = [dict.allValues firstObject];
    record = (AUXMessageContentModel *)[dataArray objectAtIndex:indexPath.row];
    
    cell.messageInfoModel = record;
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.remoteListArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXMessageContentModel *record;
    
    NSDictionary *dict = self.remoteListArray[indexPath.section];
    NSArray *dataArray = [dict.allValues firstObject];
    record = (AUXMessageContentModel *)[dataArray objectAtIndex:indexPath.row];

    [AUXNotificationTools analyseMessageModel:record completion:^(AUXMessageContentModel *messageInfoModel, BOOL opURLSuccess) {
        if (messageInfoModel && !opURLSuccess) {
            
            if ([messageInfoModel.sourceValue isEqualToString:kAUXMsgcenter] && !AUXWhtherNullString(messageInfoModel.linkedUrl)) {
                AUXMessageLinkViewController *messageLinkVC = [AUXMessageLinkViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                messageLinkVC.loadUrl = messageInfoModel.linkedUrl;
                [self.navigationController pushViewController:messageLinkVC animated:YES];
            } else {
                [[AUXTouchRemoteOrShareLink sharedInstance] touchRemoteNotificationWithInfo:nil remoteNotificationModel:(AUXRemoteNotificationModel *)messageInfoModel];
            }
            
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 46;
    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark getters

- (NSMutableArray *)timeAry {
    if (!_timeAry) {
        _timeAry = [NSMutableArray array];
    }
    return _timeAry;
}

- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"mine_img_nomessage"];
        _noDataView.titleLabel.text = @"暂无消息";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight);
        [self.view addSubview:_noDataView];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end
