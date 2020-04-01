//
//  AUXUserCenterAfterSaleViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/27.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXUserCenterAfterSaleViewController.h"
#import "AUXAfterSaleViewController.h"
#import "AUXWorkOrderViewController.h"
#import "AUXVIPViewController.h"
#import "AUXAfterSaleWebViewController.h"

#import "AUXSubtitleTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXAlertCustomView.h"

#import "AUXSoapManager.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXUserCenterAfterSaleViewController ()<UITableViewDataSource , UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,assign) NSInteger selectIndex;
@end

@implementation AUXUserCenterAfterSaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[
                       @{@"title" : @"报装" , @"image" : @"mine_service_icon_install"} ,
                       @{@"title" : @"报修" , @"image" : @"mine_service_icon_repair"} ,
                       @{@"title" : @"工单查询" , @"image" : @"mine_service_icon_list"} ,
                       @{@"title" : @"金卡激活" , @"image" : @"mine_service_icon_card"} ,
                       @{@"title" : @"服务声明" , @"image" : @"mine_service_icon_statement"}];
    }
    return _dataArray;
}

#pragma mark UITableViewDelegate , UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *dict = self.dataArray[indexPath.row];
    cell.titleLabel.text = dict[@"title"];
    cell.iconImageView.image = [UIImage imageNamed:dict[@"image"]];
    cell.subtitleLabel.hidden = YES;
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == 4) {
        cell.bottomView.hidden = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.iconImageView.hidden = NO;
        cell.titleLabelLeading.constant = 52;
        [cell layoutIfNeeded];
    });
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:
        case 1:
        case 2:
        case 3:{
            [self requestAfterSaleCreateUser:indexPath.row];
        }
            break;
        case 4: {
            AUXAfterSaleWebViewController *webViewControlle = [AUXAfterSaleWebViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
            webViewControlle.webType = AUXAfterSaleWebTypeOfChargePolicy;
            [self pushViewController:webViewControlle];
        }
            break;
        default:
            break;
    }
}

- (void)pushToAfterSaleModel:(NSInteger)index {
    UIViewController *viewController;
    switch (index) {
        case 0: {
            AUXAfterSaleViewController *AfterSaleViewController = [AUXAfterSaleViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
            AfterSaleViewController.afterSaleType = AUXAfterSaleTypeOfInstallation;
            viewController = AfterSaleViewController;
        }
            break;
        case 1: {
            AUXAfterSaleViewController *AfterSaleViewController = [AUXAfterSaleViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
            AfterSaleViewController.afterSaleType = AUXAfterSaleTypeOfMaintenance;
            viewController = AfterSaleViewController;
        }
            break;
        case 2: {
            AUXWorkOrderViewController *workOrderViewController = [AUXWorkOrderViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
            viewController = workOrderViewController;
        }
            break;
        case 3: {
            AUXVIPViewController *vipViewControlle = [AUXVIPViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
            viewController = vipViewControlle;
        }
            break;
        default:
            break;
    }
    [self pushViewController:viewController];
}

- (void)pushViewController:(UIViewController *)viewController {
    
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 网络请求
- (void)requestAfterSaleCreateUser:(NSInteger)index {
    
    if (![AUXUser isLogin]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
        return ;
    }
    
    self.tableView.userInteractionEnabled = NO;
//    [self showLoadingHUD];
    if ([AUXUser isBindAccount]) {
        [[AUXSoapManager sharedInstance] createUserPhone:[AUXUser defaultUser].phone completion:^(BOOL result, NSString *message) {
            self.tableView.userInteractionEnabled = YES;
            
            if (result) {
                [self pushToAfterSaleModel:index];
            } else {
                if (!message) {
                    message = @"网络请求失败,请稍后再试";
                }
                [self showErrorViewWithMessage:message];
            }
        }];
    } else {
        self.tableView.userInteractionEnabled = YES;
        self.selectIndex = index;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:AUXAfterSaleBindPhone object:nil userInfo:@{AUXAfterSaleBindPhone:@(AUXAfterSaleCheckBindAccountTypeOfFromUser)}]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterBindAccountSuccessNotification) name:AUXAfterSaleBindPhoneFromUerSuccess object:nil];
    }
}

#pragma mark notification
- (void)afterBindAccountSuccessNotification {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectIndex inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
}

@end
