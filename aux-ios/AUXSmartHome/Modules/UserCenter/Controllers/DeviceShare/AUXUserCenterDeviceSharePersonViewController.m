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

#import "AUXUserCenterDeviceSharePersonViewController.h"

#import "AUXDeviceShareTableViewCell.h"
#import "AUXNetworkManager.h"
#import "AUXLocalNetworkTool.h"
#import "AUXAlertCustomView.h"

#import "AUXSharingDevice.h"
#import "AUXDeviceInfo.h"

#import "UITableView+AUXCustom.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXUserCenterDeviceSharePersonViewController () < UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray <AUXSharingUser *> *friendList;
@property (copy, nonatomic) NSMutableArray *airconList;
@property (nonatomic,strong) NSError *error;
@end

@implementation AUXUserCenterDeviceSharePersonViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.userName;
    
    [self.tableView registerCellWithNibName:@"AUXDeviceShareTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchSharingInfo];
    
}

#pragma mark atcion

- (void)deleteSharingWithIndexPath:(NSIndexPath *)indexPath {
    
    if (self.airconList.count <= indexPath.row) {
        return ;
    }
    
    AUXSharingDevice *sharingDeviceInfo = [self.airconList objectAtIndex:indexPath.row];
    
    [AUXAlertCustomView alertViewWithMessage:@"确定要解除分享吗?" confirmAtcion:^{
        [self doDeleteWithDeviceId:sharingDeviceInfo.deviceId];
    } cancleAtcion:^{
        
    }];

}

- (void)doDeleteWithDeviceId:(NSString *)deviceId {
    if (![AUXLocalNetworkTool isReachable]) {
        
        if (@available(iOS 11.0, *)) {
            [self showErrorViewWithMessage:@"网络不可用"];
            return;
        } else {
            AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
            if (tool.networkReachability.networkReachabilityStatus == -1) {
            }else{
                [self showErrorViewWithMessage:@"网络不可用"];
                return;
            }
        }
        
       
    }
    
    [self showLoadingHUD];
    
    @weakify(self)
    [[AUXNetworkManager manager] userSharingDeviceDeleteWithUid:self.userUid userType:self.userType batchNo:self.batchNo deviceId:deviceId completion:^(NSError * _Nonnull error) {
        @strongify(self)
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [self showSuccess:@"解除分享成功" completion:^{
                    [self fetchSharingInfo];
                }];
                
                break;
            }
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self showErrorViewWithMessage:@"解除分享失败"];
                break;
        }
    }];
}

- (void)removeCellAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.airconList];
    if (list.count>=indexPath.row) {
        [list removeObjectAtIndex:indexPath.row];
        self.airconList = list;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark 网络请求
- (void)fetchSharingInfo {
    [self showLoadingHUD];
    
    @weakify(self)
    [[AUXNetworkManager manager] friendSharingDeviceListWithCompletion:^(NSArray * _Nullable array, NSError * _Nonnull error) {
        @strongify(self)
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
            self.friendList = mutableArray;
            
            [self requestUserSharingDeviceList];
            
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

- (void)requestUserSharingDeviceList {
    @weakify(self);
    [[AUXNetworkManager manager] userSharingDeviceListWithUid:self.userUid userType:self.userType batchNo:self.batchNo completion:^(NSArray * _Nullable array, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        @strongify(self)
        if (error.code == 200) {
            self.airconList = [NSMutableArray arrayWithArray:array];
            
            if (self.airconList.count == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
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

#pragma mark - Table view data source & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.airconList) {
        return self.airconList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceShareTableViewCell" forIndexPath:indexPath];
    AUXSharingDevice *sharingDeviceInfo = [self.airconList objectAtIndex:indexPath.row];
    cell.titleLabel.text = sharingDeviceInfo.devAlias;
    for (AUXDeviceInfo *deviceInfo in [AUXUser defaultUser].deviceInfoArray) {
        if ([deviceInfo.deviceId isEqualToString:sharingDeviceInfo.deviceId]) {
            [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:deviceInfo.deviceMainUri] placeholderImage:nil options:SDWebImageRefreshCached];
        }
    }
    
    if (self.friendList.count != 0) {
        AUXSharingUser *currentUserInfo;
        for (AUXSharingUser *userInfo in self.friendList) {
            if ([userInfo.qrBatch isEqualToString:self.batchNo]) {
                currentUserInfo = userInfo;
                break;
            }
        }
        cell.expiredTimerInterval = (NSTimeInterval)currentUserInfo.expiredAt;
        cell.viewController = self;
        cell.indexPath = indexPath;
    }
    
    cell.showIconImageView = YES;
    cell.type = self.userType.integerValue;
    cell.relieveBlock = ^{
        [self deleteSharingWithIndexPath:indexPath];
    };
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.airconList.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

@end
