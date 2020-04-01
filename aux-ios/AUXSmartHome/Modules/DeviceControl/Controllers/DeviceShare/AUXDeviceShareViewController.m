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

#import "AUXDeviceShareViewController.h"
#import "AUXDeviceShareListViewController.h"
#import "AUXDeviceShareQRCodeViewController.h"

#import "AUXDeviceShareTypeTableViewCell.h"
#import "AUXSubtitleTableViewCell.h"

#import "AUXNetworkManager.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"

@interface AUXDeviceShareViewController () <UITableViewDelegate , UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<AUXDeviceShareInfo *> *deviceShareInfoList;    // 分享列表
@property (copy, nonatomic) NSArray *familyList;
@property (copy, nonatomic) NSArray *friendList;

@property (nonatomic, strong) NSError *error;

@end

@implementation AUXDeviceShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceShareTypeTableViewCell"];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getDeviceShareList];
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
    headerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = @"子用户列表";
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@位子用户", @([self.deviceShareInfoList count])];
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
        AUXDeviceShareListViewController *shareListViewController = [AUXDeviceShareListViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        shareListViewController.deviceInfo = self.deviceInfo;
        shareListViewController.deviceShareInfoList = self.deviceShareInfoList;
        
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

#pragma mark - Actions

/// 分享给家人/朋友
- (void)actionShareDevice:(AUXDeviceShareType)type {
    
    if (self.deviceInfo.virtualDevice) {
        [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
        return ;
    }
    
    [self getDeviceQRContent:self.deviceInfo.deviceId type:type];
}

#pragma mark - 网络请求

/// 获取分享二维码
- (void)getDeviceQRContent:(NSString *)deviceId type:(AUXDeviceShareType)type {
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] getDeviceShareQRContentWithDeviceIdArray:@[deviceId] type:type completion:^(NSString * _Nullable qrContent, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                AUXDeviceShareQRCodeViewController *qrcodeViewController = [AUXDeviceShareQRCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                qrcodeViewController.type = type;
                qrcodeViewController.qrContent = qrContent;
                qrcodeViewController.deviceNames = [NSMutableArray array];
                [qrcodeViewController.deviceNames addObject:self.deviceInfo.alias];
                qrcodeViewController.qrCodeStatus = AUXQRCodeStatusOfShareDevice;
                [self.navigationController pushViewController:qrcodeViewController animated:YES];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"生成二维码失败"];
                break;
        }
    }];
}

#pragma mark 网络请求
/// 获取分享用户列表
- (void)getDeviceShareList {
    
    if (self.deviceInfo.virtualDevice) {
        return;
    }
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] getDeviceShareListWithDeviceId:self.deviceInfo.deviceId completion:^(NSArray<AUXDeviceShareInfo *> * _Nullable deviceShareInfoList, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.deviceShareInfoList = [deviceShareInfoList mutableCopy];
                [self.tableView reloadData];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"获取设备分享信息失败"];
                break;
        }
    }];
}
@end
