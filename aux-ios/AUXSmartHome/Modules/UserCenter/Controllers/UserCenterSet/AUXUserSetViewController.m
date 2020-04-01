//
//  AUXUserSetViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXUserSetViewController.h"
#import "AUXHomepageTabBarController.h"
#import "AUXAboutViewController.h"
#import "AUXOTAViewController.h"
#import "AUXPushLimitViewController.h"
#import "AUXUserWebViewController.h"

#import "AUXSetTableViewCell.h"

#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXUser.h"
#import "UIColor+AUXCustom.h"
#import "AUXAppVersionModel.h"
#import "AUXVersionTool.h"
#import "AUXResetPwdFirstViewController.h"
#import "AUXShowDisplayViewController.h"
#import "AUXTheTesterViewController.h"

#import "AUXAlertCustomView.h"

#import "AUXHomePageWallpaperViewController.h"



@interface AUXUserSetViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *itemArray;
@property (nonatomic,strong) NSArray *detailArray;

@property (nonatomic,strong) AUXAppVersionModel *appVersionModel;
@end

@implementation AUXUserSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"AUXSetTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSetTableViewCell"];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self checkWhtherUpdate];
    
    BOOL istheTester = [[MyDefaults objectForKey:kIsTheTester] integerValue];
    BOOL isbool = [self.itemArray containsObject: @{@"title": @"测试人员选项"}];
    if (istheTester) {
        if (!isbool) {
            [self.itemArray addObject:@{@"title": @"测试人员选项"}];
        }
    }else{
        if (isbool) {
            [self.itemArray removeObject:@{@"title": @"测试人员选项"}];
        }
    }
    [self.tableView reloadData];
}

- (void)initSubviews {
    [super initSubviews];
    if (!AUXWhtherNullString([AUXUser defaultUser].openid) || !AUXWhtherNullString([AUXUser defaultUser].qqid)) {
        [self.itemArray removeObjectAtIndex:0];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
        [_itemArray addObject:@{@"title": @"修改密码"}];
        [_itemArray addObject:@{@"title": @"消息免打扰"}];
        [_itemArray addObject:@{@"title": @"设置展示方式"}];
        [_itemArray addObject:@{@"title": @"首页壁纸"}];
        [_itemArray addObject:@{@"title": @"关于奥克斯A+"}];
        

    }
    return _itemArray;
}

/**
 检测是否有新版本
 */
- (void)checkWhtherUpdate {

    // 判断是否需要显示广告页, 不需要显示广告页则检查更新
    NSString *versionString = APP_VERSION;
    if (![AUXArchiveTool shouldShowAdvertisementForVersion:versionString]) {
        // 检查appstore版本
        [AUXVersionTool getAppStoreVersionWithComplete:^(NSString *appStoreVersion, NSString *url) {
            if ([AUXVersionTool.sharedInstance shouldUpdateWithAppStoreVersion:appStoreVersion]) {
                self.appVersionModel.whtherNeedUpdate = YES;
                self.appVersionModel.version = appStoreVersion;
                self.appVersionModel.updateVersionUrl = url;
            } else {
                self.appVersionModel.whtherNeedUpdate = NO;
                self.appVersionModel.version = nil;
            }
            [self.tableView reloadData];
        }];
    }
}


#pragma mark getters
- (AUXAppVersionModel *)appVersionModel {
    if (!_appVersionModel) {
        _appVersionModel = [[AUXAppVersionModel alloc]init];
        _appVersionModel.whtherNeedUpdate = NO;
    }
    return _appVersionModel;
}



- (void)logoutByServer {
    [self showLoadingHUD];
    [[AUXNetworkManager manager] userLogoutWithcompletion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone:
            case AUXNetworkErrorAccountCacheExpired:
                [self logoutSuccessfully];
                break;
                
            default: {
                [self showErrorViewWithError:error defaultMessage:@"退出登录失败"];
            }
                break;
        }
    }];
}

- (void)logoutSuccessfully {
    [[AUXUser defaultUser] logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:AUXUserDidLogoutNotification object:nil];
    [self presentLoginViewController];
}

- (void)presentLoginViewController {

    AUXHomepageTabBarController *homepageTabBarController = (AUXHomepageTabBarController *)self.tabBarController;
    @weakify(self);
    [homepageTabBarController presentLoginViewControllerAnimated:YES completion:^{
        @strongify(self);
        self.tabBarController.selectedIndex = kAUXTabDeviceSelected;
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return self.itemArray.count;

    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSetTableViewCell" forIndexPath:indexPath];
    if (indexPath.section ==0) {
        NSDictionary *dict = self.itemArray[indexPath.row];
        cell.titleTextLabel.text = dict[@"title"];
        if ([cell.titleTextLabel.text isEqualToString:@"修改密码"]||[cell.titleTextLabel.text isEqualToString:@"关于奥克斯A+"]||[cell.titleTextLabel.text isEqualToString:@"测试人员选项"]||[cell.titleTextLabel.text isEqualToString:@"首页壁纸"]) {
            cell.detailLabel.hidden = YES;
        }else{
             cell.detailLabel.hidden = NO;
        }
        if ([cell.titleTextLabel.text isEqualToString:@"消息免打扰"]) {
            NSString *start = [MyDefaults objectForKey:kPushMessageStartTime];            
            if (start.length==0) {
                cell.detailLabel.text = @"关闭";
            }else{
                NSString *startHour = [MyDefaults objectForKey:kPushMessageStartTime];
                NSString *endHour = [MyDefaults objectForKey:kPushMessageEndTime];
                if (startHour.length==1) {
                    startHour = [NSString stringWithFormat:@"0%@", [MyDefaults objectForKey:kPushMessageStartTime]];
                }
                if (endHour.length==1) {
                    endHour = [NSString stringWithFormat:@"0%@", [MyDefaults objectForKey:kPushMessageEndTime]];
                }
                 cell.detailLabel.text = [NSString stringWithFormat:@"%@:00-%@:00",startHour,endHour];
            }
        }
        if ([cell.titleTextLabel.text isEqualToString:@"设置展示方式"]) {
            cell.detailLabel.text = [AUXArchiveTool readDeviceListType] == AUXDeviceListTypeOfList ? @"列表" : @"宫格";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == self.itemArray.count-1) {
            cell.uiderLineView.hidden = YES;
        }
    }else{
        cell.titleTextLabel.text = @"退出登录";
        cell.uiderLineView.hidden = YES;
        cell.detailLabel.hidden = YES;

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            AUXSetTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIViewController *viewController;
            if ([cell.titleTextLabel.text isEqualToString:@"修改密码"]) {
                AUXResetPwdFirstViewController *resetPwdFirstViewController = [AUXResetPwdFirstViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                viewController = resetPwdFirstViewController;
            } else if ([cell.titleTextLabel.text isEqualToString:@"消息免打扰"]) {
                AUXPushLimitViewController *remoteTimeViewController = [AUXPushLimitViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                viewController = remoteTimeViewController;
            } else if ([cell.titleTextLabel.text isEqualToString:@"测试人员选项"]) {
                AUXTheTesterViewController*theTesterViewController = [AUXTheTesterViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                viewController = theTesterViewController;
            } else if ([cell.titleTextLabel.text isEqualToString:@"关于奥克斯A+"]) {
                AUXAboutViewController *abountViewController = [AUXAboutViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                abountViewController.appVersionModel = self.appVersionModel;
                viewController = abountViewController;
            } else if ([cell.titleTextLabel.text isEqualToString:@"设置展示方式"]) {
                AUXShowDisplayViewController *showDisplayViewController = [AUXShowDisplayViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                viewController = showDisplayViewController;
            } else if ([cell.titleTextLabel.text isEqualToString:@"首页壁纸"]) {
                AUXHomePageWallpaperViewController *homePageWallpaperViewController = [AUXHomePageWallpaperViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                viewController = homePageWallpaperViewController;
            }
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
    }else{
        if (indexPath.row==0) {
            
            [AUXAlertCustomView alertViewWithMessage:@"确定要退出登录吗?" confirmAtcion:^{
                [self logoutByServer];
            } cancleAtcion:^{
            }];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}


@end
