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

#import "AUXDeviceShareListViewController.h"

#import "AUXDeviceShareTableViewCell.h"
#import "AUXSingleTitleSectionHeaderView.h"
#import "AUXCurrentNoDataView.h"

#import "AUXAlertCustomView.h"
#import "UITableView+AUXCustom.h"

#import "AUXConstant.h"
#import "AUXDeviceShareInfo.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"
#import "AUXDeviceShareSectionItem.h"

@interface AUXDeviceShareListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<AUXDeviceShareInfo *> *familyShareList;    // 家人分享列表
@property (nonatomic, strong) NSMutableArray<AUXDeviceShareInfo *> *friendShareList;    // 朋友分享列表

@property (nonatomic, strong) NSMutableArray<AUXDeviceShareSectionItem *> *sectionList;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@end

@implementation AUXDeviceShareListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXDeviceShareTableViewCell"];
    [self.tableView registerHeaderFooterViewWithNibName:@"AUXSingleTitleSectionHeaderView"];
    [self updateTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)updateTableView {
    
    // 当前界面中有家人分享列表
    BOOL hasFamilySection = (self.sectionList.count > 0 && self.sectionList.firstObject.type == AUXDeviceShareTypeFamily);
    
    // 当前界面中有朋友分享列表
    BOOL hasFriendSection = (self.sectionList.count > 0 && self.sectionList.lastObject.type == AUXDeviceShareTypeFriend);
    
    if (self.familyShareList.count > 0) {
        AUXDeviceShareSectionItem *item;
        
        if (hasFamilySection) {
            item = self.sectionList.firstObject;
        } else {
            item = [[AUXDeviceShareSectionItem alloc] init];
            item.title = @"家人列表";
            item.type = AUXDeviceShareTypeFamily;
            [self.sectionList addObject:item];
        }
        
        item.rowCount = self.familyShareList.count;
    } else if (hasFamilySection) {
        // 隐藏家人分享列表
        if (self.sectionList.count>0) {
            [self.sectionList removeObjectAtIndex:0];

        }
    }
    
    if (self.friendShareList.count > 0) {
        AUXDeviceShareSectionItem *item;
        
        if (hasFriendSection) {
            item = self.sectionList.lastObject;
        } else {
            item = [[AUXDeviceShareSectionItem alloc] init];
            item.title = @"好友列表";
            item.type = AUXDeviceShareTypeFriend;
            [self.sectionList addObject:item];
        }
        
        item.rowCount = self.friendShareList.count;
    } else if (hasFriendSection) {
        // 隐藏朋友分享列表
        [self.sectionList removeLastObject];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Getters & Setters

- (NSMutableArray<AUXDeviceShareSectionItem *> *)sectionList {
    if (!_sectionList) {
        _sectionList = [[NSMutableArray alloc] init];
    }
    
    return _sectionList;
}

- (NSMutableArray<AUXDeviceShareInfo *> *)familyShareList {
    if (!_familyShareList) {
        _familyShareList = [[NSMutableArray alloc] init];
    }
    
    return _familyShareList;
}

- (NSMutableArray<AUXDeviceShareInfo *> *)friendShareList {
    if (!_friendShareList) {
        _friendShareList = [[NSMutableArray alloc] init];
    }
    
    return _friendShareList;
}

- (void)setDeviceShareInfoList:(NSArray<AUXDeviceShareInfo *> *)deviceShareInfoList {
    _deviceShareInfoList = deviceShareInfoList;
    
    if (_deviceShareInfoList.count > 0) {
        [self.familyShareList removeAllObjects];
        [self.friendShareList removeAllObjects];
        for (AUXDeviceShareInfo *shareInfo in deviceShareInfoList) {
            switch (shareInfo.userTag) {
                case AUXDeviceShareTypeFamily:
                    [self.familyShareList addObject:shareInfo];
                    break;
                    
                case AUXDeviceShareTypeFriend:
                    [self.friendShareList addObject:shareInfo];
                    break;
                    
                default:
                    break;
            }
        }
        
        [self updateTableView];
    }
    
}

- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"mine_share_img_noshare"];
        _noDataView.titleLabel.text = @"暂无子用户";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight);
        [self.view addSubview:_noDataView];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

#pragma mark - Actions

/// 解除分享
- (void)relieveSharingAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceShareSectionItem *item = self.sectionList[indexPath.section];
    AUXDeviceShareInfo *shareInfo;
    
    switch (item.type) {
        case AUXDeviceShareTypeFamily:
            shareInfo = self.familyShareList[indexPath.row];
            break;
            
        case AUXDeviceShareTypeFriend:
            shareInfo = self.friendShareList[indexPath.row];
            break;
            
        default:
            break;
    }
    
    @weakify(self);
    [AUXAlertCustomView alertViewWithMessage:@"确定要解除分享吗？" confirmAtcion:^{
        @strongify(self);
        [self relieveSharingWithShareInfo:shareInfo];
    } cancleAtcion:^{
        
    }];
    
}

- (void)removeCellAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.friendShareList];
    if (list.count > indexPath.row) {
        [list removeObjectAtIndex:indexPath.row];
        self.friendShareList = list;
        [self updateTableView];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.sectionList.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    
    return self.sectionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AUXDeviceShareSectionItem *item = self.sectionList[section];
    return item.rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return AUXSingleTitleSectionHeaderView.properHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    AUXDeviceShareSectionItem *item = self.sectionList[section];
    
    AUXSingleTitleSectionHeaderView *titleHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AUXSingleTitleSectionHeaderView"];
    titleHeaderView.titleLabel.text = [NSString stringWithFormat:@"%@(%ld)" , item.title , item.rowCount];
    
    return titleHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceShareSectionItem *item = self.sectionList[indexPath.section];
    AUXDeviceShareInfo *shareInfo;
    
    AUXDeviceShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceShareTableViewCell" forIndexPath:indexPath];
    
    switch (item.type) {
        case AUXDeviceShareTypeFamily: {    // 家人
            shareInfo = self.familyShareList[indexPath.row];
            cell.type = AUXDeviceShareTypeFamily;
            
            cell.bottomView.hidden = NO;
            if (indexPath.row == self.familyShareList.count - 1) {
                cell.bottomView.hidden = YES;
            }
        }
            break;
            
        case AUXDeviceShareTypeFriend: {    // 朋友
            if (self.friendShareList.count > indexPath.row) {
                shareInfo = self.friendShareList[indexPath.row];
            }
            cell.type = AUXDeviceShareTypeFriend;
            
            // 计算朋友分享失效剩余时间
            NSTimeInterval currentTimeStamp = [NSDate date].timeIntervalSince1970;
            
            if (shareInfo.expiredTime > currentTimeStamp) {
                cell.expiredTimerInterval = shareInfo.expiredTime;
                cell.deviceShareViewController = self;
                cell.indexPath = indexPath;
            } else {
                cell.subtitleLabel.text = @"已失效";
            }
            
            cell.bottomView.hidden = NO;
            if (indexPath.row == self.friendShareList.count - 1) {
                cell.bottomView.hidden = YES;
            }
        }
            break;
            
        default:
            break;
    }
    
    // 用户昵称
    cell.titleLabel.text = shareInfo.username;
    
    @weakify(self);
    cell.relieveBlock = ^{
        @strongify(self);
        [self relieveSharingAtIndexPath:indexPath];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - 网络请求

/// 解除分享
- (void)relieveSharingWithShareInfo:(AUXDeviceShareInfo *)shareInfo {
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] deleteDeviceShareWithShareId:shareInfo.shareId completion:^(NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceDidDeleteShareNotification object:shareInfo];
                
                switch (shareInfo.userTag) {
                    case AUXDeviceShareTypeFamily:
                       
                        if ([self.familyShareList containsObject:shareInfo]) {
                             [self.familyShareList removeObject:shareInfo];
                        }
                        break;
                        
                    case AUXDeviceShareTypeFriend:
                        if ([self.friendShareList containsObject:shareInfo]) {
                             [self.friendShareList removeObject:shareInfo];
                        }
                       
                        break;
                        
                    default:
                        break;
                }
                
                [self updateTableView];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"解除分享失败"];
                break;
        }
    }];
}


@end
