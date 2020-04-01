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

#import "AUXUserCenterDeviceShareViewController.h"
#import "AUXUserCenterDeviceShareSublistViewController.h"
#import "AUXChooseDeviceViewController.h"

#import "AUXSubtitleTableViewCell.h"
#import "AUXDeviceShareTypeTableViewCell.h"

#import "AUXNetworkManager.h"
#import "AUXLocalNetworkTool.h"
#import "AUXSharingUser.h"
#import "UITableView+AUXCustom.h"

@interface AUXUserCenterDeviceShareViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray <AUXSharingUser *> *familyList;
@property (copy, nonatomic) NSArray <AUXSharingUser *> *friendList;

@property (nonatomic, strong) NSError *error;

@end

@implementation AUXUserCenterDeviceShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceShareTypeTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchSharingInfo];
}

#pragma mark 网络请求
- (void)fetchSharingInfo {
    [self showLoadingHUD];
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self)
        dispatch_semaphore_t semaphore_0 = dispatch_semaphore_create(0);
        dispatch_semaphore_t semaphore_1 = dispatch_semaphore_create(0);
        @weakify(self)
        [[AUXNetworkManager manager] familySharingDeviceListWithCompletion:^(NSArray * _Nullable array, NSError * _Nonnull error) {
            @strongify(self)
            if (error.code == 200) {
                self.familyList = array;
            } else {
                self.error = error;
            }
            dispatch_semaphore_signal(semaphore_0);
        }];
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
            } else {
                self.error = error;
            }
            dispatch_semaphore_signal(semaphore_1);
        }];
        dispatch_semaphore_wait(semaphore_0, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
        dispatch_semaphore_wait(semaphore_1, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self hideLoadingHUD];
            if (!self.error) {
                [self.tableView reloadData];
            } else {
                if (self.error.code == AUXNetworkErrorAccountCacheExpired) {
                    [self alertAccountCacheExpiredMessage];
                } else {
                    [self showErrorViewWithMessage:@"获取列表失败"];
                }
            }
        });
    });
}

#pragma mark UITableViewDelegate , UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return  60;
    } else {
        return 136;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = @"子用户列表";
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@位子用户", @([self.familyList count] + [self.friendList count])];
        cell.indicatorImageView.hidden = NO;
        return cell;
    } else {
        AUXDeviceShareTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceShareTypeTableViewCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            cell.type = AUXDeviceShareTypeFamily;
            cell.bottomView.hidden = NO;
        } else {
            cell.type = AUXDeviceShareTypeFriend;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        AUXUserCenterDeviceShareSublistViewController *shareListViewController = [AUXUserCenterDeviceShareSublistViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        [self.navigationController pushViewController:shareListViewController animated:YES];
    } else {
        AUXDeviceShareType type;
        
        if (indexPath.row == 0) {
            type = AUXDeviceShareTypeFamily;
        } else {
            type = AUXDeviceShareTypeFriend;
        }
        [self actionShareDevice:type];
    }
}

/// 分享给家人/朋友
- (void)actionShareDevice:(AUXDeviceShareType)type {
    NSLog(@"%@" , [AUXUser defaultUser].deviceArray);
    
    if ([AUXUser defaultUser].deviceArray.count == 0) {
        [self showFailure:@"无可共享设备" completion:nil];
        return ;
    }
    
    AUXChooseDeviceViewController *chooseDeviceViewController = [AUXChooseDeviceViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    chooseDeviceViewController.purpose = AUXChooseDevicePurposeShareDevice;
    chooseDeviceViewController.deviceShareType = type;
    [self.navigationController pushViewController:chooseDeviceViewController animated:YES];
}

@end
