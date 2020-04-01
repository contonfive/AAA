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

#import "AUXFaultListViewController.h"
#import "AUXAfterSaleViewController.h"

#import "AUXSingleTitleSectionHeaderView.h"
#import "AUXFaultTableViewCell.h"
#import "AUXFaultButtonTableViewCell.h"

#import "AUXTableViewSectionItem.h"

#import "UIColor+AUXCustom.h"
#import "UITableView+AUXCustom.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXConfiguration.h"
#import "AUXSoapManager.h"

@interface AUXFaultListSectionItem : AUXTableViewSectionItem

@property (nonatomic, assign) NSInteger type;

@end

@implementation AUXFaultListSectionItem

@end


@interface AUXFaultListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<AUXFaultListSectionItem *> *sectionArray;

// 按照目前服务器的设置，现在只会显示一条故障信息
@property (nonatomic, strong) NSArray<AUXFaultInfo *> *faultInfoList;
// 按照目前服务器的设置，现在只会显示一条滤网信息
@property (nonatomic, strong) NSArray<AUXFaultInfo *> *filterInfoList;

@property (nonatomic,strong) AUXFaultButtonTableViewCell *filterCell;
@end

@implementation AUXFaultListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerHeaderFooterViewWithNibName:@"AUXSingleTitleSectionHeaderView"];
    
    self.sectionArray = [[NSMutableArray alloc] init];
    
    if (self.faultError) {
        AUXFaultInfo *faultInfo = [[AUXFaultInfo alloc] init];
        faultInfo.faultCode = self.faultError.code;
        faultInfo.faultName = self.faultError.userInfo.allValues.firstObject;
        faultInfo.faultReason = faultInfo.faultName;
        faultInfo.mac = self.deviceInfo.mac;
        
        self.faultInfoList = @[faultInfo];
        
        AUXFaultListSectionItem *sectionItem = [[AUXFaultListSectionItem alloc] init];
        sectionItem.title = @"故障信息";
        sectionItem.rowCount = self.faultInfoList.count;
        sectionItem.type = 0;
        [self.sectionArray addObject:sectionItem];
    }
    
    if (self.filterInfo) {
        self.filterInfo.mac = self.deviceInfo.mac;
        
        self.filterInfoList = @[self.filterInfo];
        
        AUXFaultListSectionItem *sectionItem = [[AUXFaultListSectionItem alloc] init];
        sectionItem.title = @"滤网信息";
        sectionItem.rowCount = self.filterInfoList.count;
        sectionItem.type = 1;
        [self.sectionArray addObject:sectionItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)pushToAfterSaleViewController {
    AUXFaultInfo *faultInfo = self.faultInfoList.firstObject;
    NSString *faultName = faultInfo.faultName;
    
    AUXAfterSaleViewController *afterSaleViewController = [AUXAfterSaleViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    afterSaleViewController.fromDeviceControl = YES;
    afterSaleViewController.afterSaleType = AUXAfterSaleTypeOfMaintenance;
    afterSaleViewController.faultName = faultName;
    [self.navigationController pushViewController:afterSaleViewController animated:YES];
}

- (void)actionReportFault {
    [self reportFaultByServer];
    
    [self requestAfterSaleCreateUser];
    
}

- (void)actionUpdateFilterStatus {
    
    @weakify(self);
    [self alertWithMessage:@"确定已清洗滤网了吗?" confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
        @strongify(self);
        [self updateFilterStatusByServer];
    } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:nil];
}

- (void)actionCallCustomerService {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4008268268"]];
}

#pragma mark 通知监听方法
- (void)afterBindAccountSuccessNotification {
    
    [self pushToAfterSaleViewController];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AUXFaultListSectionItem *sectionItem = self.sectionArray[section];
    return sectionItem.rowCount + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return AUXSingleTitleSectionHeaderView.properHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    AUXFaultListSectionItem *sectionItem = self.sectionArray[indexPath.section];
    
    if (indexPath.row == sectionItem.rowCount) {
        height = AUXFaultButtonTableViewCell.properHeight;
    } else {
        height = -1;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUXFaultTableViewCell.properHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AUXSingleTitleSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AUXSingleTitleSectionHeaderView"];
    
    AUXFaultListSectionItem *sectionItem = self.sectionArray[section];
    
    headerView.titleLabel.text = sectionItem.title;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    AUXFaultListSectionItem *sectionItem = self.sectionArray[indexPath.section];
    
    switch (sectionItem.type) {
        case 0:
            cell = [self tableView:tableView cellForFaultAtIndexPath:indexPath];
            break;
            
        default:
            cell = [self tableView:tableView cellForFilterAtIndexPath:indexPath];
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForFaultAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    AUXFaultListSectionItem *sectionItem = self.sectionArray[indexPath.section];
    
    if (indexPath.row == sectionItem.rowCount) {
        AUXFaultButtonTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
        cell = buttonCell;
        
        buttonCell.buttonTitle = @"一键报修";
        [buttonCell.actionButton setImage:[UIImage imageNamed:@"device_icon_repair"] forState:UIControlStateNormal];
        
        @weakify(self);
        buttonCell.buttonClickedBlock = ^{
            @strongify(self);
            [self actionReportFault];
        };
    } else {
        AUXFaultTableViewCell *faultCell = [tableView dequeueReusableCellWithIdentifier:@"faultCell" forIndexPath:indexPath];
        cell = faultCell;
        
        AUXFaultInfo *faultInfo = self.faultInfoList[indexPath.row];
        
        faultCell.titleLabel.text = faultInfo.faultName;
        
        if (faultInfo.occurrenceTime && faultInfo.occurrenceTime.length > 0) {
            faultCell.hideTimeLabel = NO;
            faultCell.timeLabel.text = faultInfo.occurrenceTime;
        } else {
            faultCell.hideTimeLabel = YES;
        }
        
        faultCell.iconImageView.image = [UIImage imageNamed:@"device_icon_warn"];
        
        faultCell.bottomView.hidden = NO;
    }
    
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForFilterAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    AUXFaultListSectionItem *sectionItem = self.sectionArray[indexPath.section];
    
    if (indexPath.row == sectionItem.rowCount) {
        AUXFaultButtonTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
        cell = buttonCell;
        
        buttonCell.buttonTitle = @"已清洗";
        [buttonCell.actionButton setImage:[UIImage imageNamed:@"device_icon_wash"] forState:UIControlStateNormal];
        
        @weakify(self);
        buttonCell.buttonClickedBlock = ^{
            @strongify(self);
            [self actionUpdateFilterStatus];
        };
    } else {
        AUXFaultTableViewCell *faultCell = [tableView dequeueReusableCellWithIdentifier:@"faultCell" forIndexPath:indexPath];
        cell = faultCell;
        
        faultCell.titleLabel.text = @"需要清洗滤网";
        faultCell.iconImageView.image = [UIImage imageNamed:@"device_icon_needclean"];
        faultCell.hideTimeLabel = YES;
        faultCell.bottomView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - 网络请求

/// 一键报修
- (void)reportFaultByServer {
    
    AUXFaultInfo *faultInfo = self.faultInfoList.firstObject;
    
    [[AUXNetworkManager manager] reportFaultWithMac:self.deviceInfo.mac deviceSN:self.deviceInfo.sn faultType:faultInfo.faultName completion:^(NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
//                [self showErrorViewWithError:error defaultMessage:nil];
                break;
        }
    }];
}

/// 滤网已清洗
- (void)updateFilterStatusByServer {
    
    //AUXFaultInfo *filterInfo = self.filterInfoList.firstObject;
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] updateFilterStatus:self.deviceInfo.mac completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self.sectionArray removeLastObject];
                [self.tableView reloadData];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self showErrorViewWithError:error defaultMessage:@"更新滤网状态失败"];
                break;
        }
    }];
}

- (void)requestAfterSaleCreateUser {
    
    AUXUser *user = [AUXUser defaultUser];
    if ([AUXUser isBindAccount]) {
        [[AUXSoapManager sharedInstance] createUserPhone:user.phone completion:^(BOOL result, NSString *message) {
            
            if (result) {
                [self pushToAfterSaleViewController];
            } else {
                if (!message) {
                    message = @"网络请求失败,请稍后再试";
                }
                [self showErrorViewWithMessage:message];
            }
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:AUXAfterSaleBindPhone object:nil userInfo:@{AUXAfterSaleBindPhone:@(AUXAfterSaleCheckBindAccountTypeOfFromControl)}]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterBindAccountSuccessNotification) name:AUXAfterSaleBindPhoneFromControlSuccess object:nil];
    }
}

@end
