//
//  AUXUserCenterDeviceShareSublistViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/5.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXUserCenterDeviceShareSublistViewController.h"
#import "AUXUserCenterDeviceSharePersonViewController.h"

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

@interface AUXUserCenterDeviceShareSublistViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<AUXDeviceShareSectionItem *> *sectionList;
@property (nonatomic, strong) NSError *error;

@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@property (copy, nonatomic) NSArray <AUXSharingUser *> *familyShareList;
@property (copy, nonatomic) NSArray <AUXSharingUser *> *friendShareList;
@end

@implementation AUXUserCenterDeviceShareSublistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXDeviceShareTableViewCell"];
    [self.tableView registerHeaderFooterViewWithNibName:@"AUXSingleTitleSectionHeaderView"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchSharingInfo];
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
    AUXSharingUser *userInfo;
    
    AUXDeviceShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceShareTableViewCell" forIndexPath:indexPath];
    
    cell.delectImageView.hidden = YES;
    cell.bottomView.hidden = NO;
    switch (item.type) {
        case AUXDeviceShareTypeFamily: {    // 家人
            userInfo = self.familyShareList[indexPath.row];
            
            if (indexPath.row == self.familyShareList.count - 1) {
                cell.bottomView.hidden = YES;
            }
        }
            break;
            
        case AUXDeviceShareTypeFriend: {    // 朋友
            userInfo = self.friendShareList[indexPath.row];
            cell.type = AUXDeviceShareTypeFriend;
            if (indexPath.row == self.friendShareList.count - 1) {
                cell.bottomView.hidden = YES;
            }
        }
            break;
            
        default:
            break;
    }
    
    // 用户昵称
    cell.titleLabel.text = userInfo.username;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%d台设备" , userInfo.shareTotal];
    cell.showIndicatorImageView = YES;
    
    cell.bottomView.hidden = NO;
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceShareSectionItem *item = self.sectionList[indexPath.section];
    AUXSharingUser *userInfo;
    NSString *userType;
    switch (item.type) {
        case AUXDeviceShareTypeFamily:
            userInfo = [self.familyShareList objectAtIndex:indexPath.row];
            break;
        case AUXDeviceShareTypeFriend:
            userInfo = [self.friendShareList objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    if (!userInfo) {
        return;
    }
    
    userType = [NSString stringWithFormat:@"%d", (int)item.type];
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            @weakify(self);
            
            [AUXAlertCustomView alertViewWithMessage:@"删除用户后会自动解除分享给该用户的所有设备，是否确认删除？" confirmAtcion:^{
                @strongify(self);
            
                [self deleteDeviceShareWith:userInfo userType:userType];
            } cancleAtcion:^{
                @strongify(self);
                [self.tableView setEditing:NO animated:YES];
            }];

            break;
        }
        default:
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AUXDeviceShareSectionItem *item = self.sectionList[indexPath.section];
    AUXSharingUser *userInfo;
    switch (item.type) {
        case AUXDeviceShareTypeFamily:
            userInfo = [self.familyShareList objectAtIndex:indexPath.row];
            break;
        case AUXDeviceShareTypeFriend:
            userInfo = [self.friendShareList objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    if (userInfo) {
        AUXUserCenterDeviceSharePersonViewController *homeCenterPersonViewController = [AUXUserCenterDeviceSharePersonViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        homeCenterPersonViewController.userUid = userInfo.uid;
        homeCenterPersonViewController.userName = userInfo.username;
        homeCenterPersonViewController.userType = [NSString stringWithFormat:@"%ld", (long)item.type];
        homeCenterPersonViewController.batchNo = userInfo.qrBatch;
        [self.navigationController pushViewController:homeCenterPersonViewController animated:YES];
    }
    
}


#pragma mark 网络请求
- (void)fetchSharingInfo {
    [self showLoadingHUD];
    @weakify(self)
    [[AUXNetworkManager manager] familySharingDeviceListWithCompletion:^(NSArray * _Nullable array, NSError * _Nonnull error) {
        @strongify(self)
        if (error.code == 200) {
            self.familyShareList = array;
            
            [self requestFriendsList];
            
        } else {
            
            [self hideLoadingHUD];
            self.error = error;
        }
        
        if (self.error) {
            if (self.error.code == AUXNetworkErrorAccountCacheExpired) {
                [self alertAccountCacheExpiredMessage];
            } else {
                [self showErrorViewWithMessage:@"获取列表失败"];
            }
        }
    }];

}

- (void)requestFriendsList {
    @weakify(self);
    [[AUXNetworkManager manager] friendSharingDeviceListWithCompletion:^(NSArray * _Nullable array, NSError * _Nonnull error) {
        @strongify(self)
        [self hideLoadingHUD];
        if (error.code == 200) {
            NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:array];
            for (int i = 0; i < mutableArray.count; i++) {
                AUXSharingUser *userInfo = [mutableArray objectAtIndex:i];
                if (userInfo && userInfo.expiredAt <= current) {
                    [mutableArray removeObjectAtIndex:i];
                    i--;
                }
            }
            self.friendShareList = mutableArray;
            
            [self updateTableView];
            
        } else {
            self.error = error;
        }
        
        if (self.error) {
            if (self.error.code == AUXNetworkErrorAccountCacheExpired) {
                [self alertAccountCacheExpiredMessage];
            } else {
                [self showErrorViewWithMessage:@"获取列表失败"];
            }
        }
    }];
}

- (void)deleteDeviceShareWith:(AUXSharingUser *)userInfo userType:(NSString *)userType {
    [self showLoadingHUD];
    @weakify(self);
    [[AUXNetworkManager manager] userSharingDeviceDeleteWithUid:userInfo.uid userType:userType batchNo:userInfo.qrBatch deviceId:nil completion:^(NSError * _Nonnull error) {
        @strongify(self)
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:{
                [self showSuccess:@"解除分享成功" completion:^{
                    [self fetchSharingInfo];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithMessage:@"解除分享失败"];
                break;
        }
    }];
}

#pragma mark - Getters & Setters

- (NSMutableArray<AUXDeviceShareSectionItem *> *)sectionList {
    if (!_sectionList) {
        _sectionList = [[NSMutableArray alloc] init];
    }
    
    return _sectionList;
}

- (void)setFamilyShareList:(NSArray<AUXSharingUser *> *)familyShareList {
    _familyShareList = familyShareList;
}

- (void)setFriendShareList:(NSArray<AUXSharingUser *> *)friendShareList {
    _friendShareList = friendShareList;
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

@end
