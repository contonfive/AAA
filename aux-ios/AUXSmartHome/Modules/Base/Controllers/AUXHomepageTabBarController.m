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

#import "AUXHomepageTabBarController.h"
#import "AUXDeviceListViewController.h"
#import "AUXUserCenterViewController.h"
#import "AUXLoginViewController.h"
#import "AUXMessageLinkViewController.h"
#import "AUXStoreDetailViewController.h"
#import "AUXBindAccountViewController.h"
#import "AUXUserWebViewController.h"

#import "AUXBaseNavigationController.h"

#import "AUXHomepageTabBarControllerTransitioningAnimation.h"

#import "AUXUser.h"
#import "AUXRemoteNotificationModel.h"
#import "AUXArchiveTool.h"

#import "UIColor+AUXCustom.h"
#import "NSDate+AUXCustom.h"

@interface AUXHomepageTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, assign) BOOL shouldShowTransitioningAnimation;

@property (nonatomic,assign) AUXAfterSaleCheckBindAccountType checkBindAccount;

@property (nonatomic,assign) BOOL hasShouldCacheDidExpireAlert;
@end

@implementation AUXHomepageTabBarController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor colorWithHexString:@"4E78A9"];
}


//#pragma mark --- tabbar点击事件
//-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
//{


//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.shouldShowTransitioningAnimation = YES;
    self.hasShouldCacheDidExpireAlert = NO;
    
    for (UITabBarItem *item in self.tabBar.items) {
        UIImage *image = item.image;
        UIImage *selectedImage = item.selectedImage;
        
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        item.image = image;
        item.selectedImage = selectedImage;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountCacheDidExpireNotification:) name:AUXAccountCacheDidExpireNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteToLocalNoLoginNotification:) name:AUXRemoteNotificationToLocalNoLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterSaleBindPhoneNotification:) name:AUXAfterSaleBindPhone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeBindPhoneNotification:) name:AUXStoreBindPhone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentWebNotification:) name:AUXWebUrlNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    self.shouldShowTransitioningAnimation = animated;
    self.selectedIndex = selectedIndex;
}

/// 跳转到登录界面
- (void)presentLoginViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    AUXLoginViewController *loginViewController = [AUXLoginViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
    
    AUXBaseNavigationController *navigationController = [[AUXBaseNavigationController alloc] initWithRootViewController:loginViewController];
    
    loginViewController.homepageTabBarController = self;
    [loginViewController setupBackBarButtonItem];
    
    [self presentViewController:navigationController animated:animated completion:completion];
}


/// 跳转到网页详情页面
- (void)presentMessageLinkViewControllerWithContentModel:(AUXRemoteNotificationModel *)contentModel animated:(BOOL)animated completion:(void (^)(void))completion {
    
    AUXMessageLinkViewController *messageLinkViewController = [AUXMessageLinkViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    messageLinkViewController.loadUrl = contentModel.sourceValue;
    
    AUXBaseNavigationController *navigationController = [[AUXBaseNavigationController alloc] initWithRootViewController:messageLinkViewController];
    [self presentViewController:navigationController animated:animated completion:completion];
}

- (void)presentBindAccountViewControllerAfterSaleWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    
    AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
    
    bindAccountViewController.homepageTabBarController = self;
    bindAccountViewController.bindAccountType = AUXBindAccountTypeOfAfterSale;
    [bindAccountViewController setupBackBarButtonItem];
    
    AUXBaseNavigationController *navigationController = [[AUXBaseNavigationController alloc] initWithRootViewController:bindAccountViewController];
    [self presentViewController:navigationController animated:animated completion:completion];
}

- (void)presentBindAccountViewControllerStoreWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    
    AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
    
    bindAccountViewController.homepageTabBarController = self;
    bindAccountViewController.bindAccountType = AUXBindAccountTypeOfStore;
    [bindAccountViewController setupBackBarButtonItem];
    
    AUXBaseNavigationController *navigationController = [[AUXBaseNavigationController alloc] initWithRootViewController:bindAccountViewController];
    [self presentViewController:navigationController animated:animated completion:completion];
}

- (void)presentPrivacyStatementViewControllerWithUrl:(NSString *)url completion:(void (^)(void))completion {
    AUXUserWebViewController *webViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.loadUrl = url;
    AUXBaseNavigationController *navigationController = [[AUXBaseNavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:navigationController animated:YES completion:completion];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    BOOL value = YES;
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    // 切换到“我的”界面，如果用户未登录，则跳转登录
    if (index == 3 || index==1) {
        if (![AUXUser isLogin]) {
            value = NO;
            [self presentLoginViewControllerAnimated:YES completion:nil];
        }
    }
    [MyDefaults setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:kTabbarIndex];

    return value;
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    if (![toVC isKindOfClass:[UINavigationController class]]) {
        return nil;
    }
    
    if (!self.shouldShowTransitioningAnimation) {
        self.shouldShowTransitioningAnimation = YES;
        return nil;
    }
    
    UINavigationController *toNavigationController = (UINavigationController *)toVC;
    
    // 切换到“设备”界面，需要自定义切换动画。
    if ([toNavigationController.topViewController isKindOfClass:[AUXDeviceListViewController class]]) {
        return [[AUXHomepageTabBarControllerTransitioningAnimation alloc] init];
    }
    
    return nil;
}

- (void)pushBindAccountViewController {
    AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
    bindAccountViewController.bindAccountType = AUXBindAccountTypeOfUserCenter;
    [self.navigationController pushViewController:bindAccountViewController animated:YES];
}

#pragma mark - Notifications

- (void)accountCacheDidExpireNotification:(NSNotification *)notification {
    if (self.hasShouldCacheDidExpireAlert) {
        return ;
    }
    self.hasShouldCacheDidExpireAlert = YES;
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *viewController = [(UINavigationController *)self.presentedViewController viewControllers].firstObject;
        
        if ([viewController isKindOfClass:[AUXLoginViewController class]]) {
            return;
        }
    }
    
    [[AUXUser defaultUser] logout];
    
    UINavigationController *navigationController = self.selectedViewController;
    
    @weakify(self);
    [self presentLoginViewControllerAnimated:YES completion:^{
        @strongify(self);
        [navigationController popToRootViewControllerAnimated:YES];
        
        [self setSelectedIndex:kAUXTabDeviceSelected animated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXUserDidLogoutNotification object:nil];
        self.hasShouldCacheDidExpireAlert = NO;
    }];
}

- (void)remoteToLocalNoLoginNotification:(NSNotification *)notification {
    
    AUXRemoteNotificationModel *contentModel = notification.userInfo[AUXRemoteNotificationToLocalNoLogin];
    
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *nav = (UINavigationController *)self.presentedViewController;
        
        UIViewController *viewController = [(UINavigationController *)self.presentedViewController viewControllers].firstObject;
        if ([viewController isKindOfClass:[AUXLoginViewController class]]) {
            [nav dismissViewControllerAnimated:YES completion:^{
                [self presentMessageLinkViewControllerWithContentModel:contentModel];
            }];
        }
    } else {
        [self presentMessageLinkViewControllerWithContentModel:contentModel];
    }
}

- (void)afterSaleBindPhoneNotification:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    self.checkBindAccount = [userInfo[AUXAfterSaleBindPhone] integerValue];
    [self presentBindAccountViewControllerAfterSale];
}

- (void)storeBindPhoneNotification:(NSNotification *)notification {
    [self presentBindAccountViewControllerStore];
}

- (void)presentWebNotification:(NSNotification *)notification {
    NSString *url = notification.userInfo[AUXWebUrlNotification];
    [self presentWebViewController:url];
}

#pragma mark 模态导出指定页面
- (void)presentMessageLinkViewControllerWithContentModel:(AUXMessageContentModel *)contentModel {
    UINavigationController *navigationController = self.selectedViewController;
    
    @weakify(self);
    [self presentMessageLinkViewControllerWithContentModel:contentModel animated:YES completion:^{
        @strongify(self);
    }];
}

- (void)presentBindAccountViewControllerAfterSale {
    UINavigationController *navigationController = self.selectedViewController;
    
    @weakify(self);
    [self presentBindAccountViewControllerAfterSaleWithAnimated:YES completion:^{
        @strongify(self);
        if (self.checkBindAccount == AUXAfterSaleCheckBindAccountTypeOfFromUser) {
            [navigationController popToRootViewControllerAnimated:YES];
            [self setSelectedIndex:kAUXTabUserSelected animated:NO];
        }
    }];
}

- (void)presentBindAccountViewControllerStore {
    UINavigationController *navigationController = self.selectedViewController;
    
    @weakify(self);
    
    [self presentBindAccountViewControllerStoreWithAnimated:YES completion:^{
        @strongify(self);
        [navigationController popToRootViewControllerAnimated:YES];
        [self setSelectedIndex:kAUXTabStoreSelected animated:NO];
    }];
}

- (void)presentWebViewController:(NSString *)url {
    [self presentPrivacyStatementViewControllerWithUrl:url completion:^{
        
    }];
}

@end
