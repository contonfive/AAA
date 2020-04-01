//
//  AUXTouchRemoteOrShareLink.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/19.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTouchRemoteOrShareLink.h"
#import "AppDelegate.h"

#import "NSString+AUXCustom.h"

#import "AUXStoreDomainModel.h"

#import "AUXNetworkManager.h"
#import "AUXUserCenterViewController.h"
#import "AUXComponentsViewController.h"
#import "AUXDeviceListViewController.h"
#import "AUXMessageManagerViewController.h"
#import "AUXDeviceControlViewController.h"
#import "AUXBaseViewController.h"
#import "AUXMessageManagerViewController.h"
#import "AUXMessageLinkViewController.h"
#import "AUXSceneViewController.h"
#import "AUXStoreViewController.h"
#import "AUXScanCodeViewController.h"
#import "AUXSceneAddNewViewController.h"
#import "AUXStoreDetailViewController.h"
#import "AUXUserWebViewController.h"

@interface AUXTouchRemoteOrShareLink()
@property (nonatomic,strong) AppDelegate *appDelegate;
@end

@implementation AUXTouchRemoteOrShareLink

+ (instancetype)sharedInstance
{
    static AUXTouchRemoteOrShareLink *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AUXTouchRemoteOrShareLink alloc] init];
        
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    }
    return self;
}

- (BOOL)shouldLogoutWithUserInfo:(NSDictionary *)userInfo {
    int category = [[[userInfo objectForKey:@"aps"] objectForKey:@"category"] intValue];
    NSString *type = [userInfo objectForKey:@"type"];
    if (category != 9 && ![@"exit_app" isEqualToString:type]) {
        return NO;
    }
    return YES;
}

#pragma mark 处理获得的分享数据，并跳转到设备列表
- (void)handleDidRecvQRcontent:(NSString *)clipboardShareData {
    
    [[AUXNetworkManager manager] getDeviceShareWithClipbordShareData:clipboardShareData completion:^(AUXShareDeviceModel * model, NSError * error) {
        
        AUXDeviceListViewController *deviceListVC = [self pushToDeviceListViewController];
        
        if (deviceListVC) {
            if (model) {
                [deviceListVC alertWithMessage:model.deviceDescription confirmTitle:kAUXLocalizedString(@"Sure") confirmBlock:^{
                    
                    [deviceListVC acceptDeviceShareWithQRContent:clipboardShareData];
                    
                } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:nil];
            } else {
                [deviceListVC showErrorViewWithError:error defaultMessage:nil];
            }
        } else {
            return ;
        }
    }];
}

#pragma mark 点击广告跳转
- (void)touchAdvertisingWithRemoteNotificationModel:(AUXRemoteNotificationModel *)contentModel {
    
    if ([contentModel.sourceType isEqualToString:kAUXSchema]) {
        NSURL *schemeURL = [NSURL URLWithString:contentModel.sourceValue];
        if ([[UIApplication sharedApplication] canOpenURL:schemeURL]) {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:schemeURL options:@{} completionHandler:^(BOOL success) {
                        if (success) {
                            return ;
                        }
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:schemeURL];
                    return ;
                }
            }
        } else {
            contentModel.tempSourceValue = contentModel.sourceValue;
            contentModel.sourceValue = contentModel.linkedUrl;
        }
    } else if ([contentModel.sourceType isEqualToString:kAUXLocal]) {
            [self touchRemoteNotificationWithInfo:nil remoteNotificationModel:contentModel];
    }
}

#pragma mark 点击远程推送跳转到指定原生页面
- (void)touchRemoteNotificationWithInfo:(NSDictionary *)info remoteNotificationModel:(AUXRemoteNotificationModel *)contentModel {
    
    if (info) {
        if ([self shouldLogoutWithUserInfo:info]) {
            self.appDelegate.pushLaunchUserInfo = nil;
            return;
        }
    }
    
    self.appDelegate.pushLaunchUserInfo = nil;
    if ([contentModel.sourceValue hasPrefix:kAUXWebview]) {
        // 跳转到本地 web页面
        NSRange range = [contentModel.sourceValue rangeOfString:kAUXWebviewWithUrl];
        NSString *tempString = contentModel.sourceValue;
        contentModel.sourceValue = [[contentModel.sourceValue substringFromIndex:range.length] decodeString];
        
        if (![AUXUser isLogin]) {
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:AUXRemoteNotificationToLocalNoLogin object:nil userInfo:@{AUXRemoteNotificationToLocalNoLogin:contentModel}]];
        } else {
            [self pushToWebVC:contentModel];
        }
        contentModel.sourceValue = tempString;
    } else if ([contentModel.sourceValue hasPrefix:kAUXEshop]) {
        // 跳转到商城
        NSRange range = [contentModel.sourceValue rangeOfString:kAUXEshopWithUrl];
        NSString *tempString = contentModel.sourceValue;
        contentModel.sourceValue = [[contentModel.sourceValue substringFromIndex:range.length] decodeString];
        [self pushToStoreDetailVC:[[AUXStoreDomainModel sharedInstance] getAuth:contentModel.sourceValue]];
        contentModel.sourceValue = tempString;
    } else if ([contentModel.sourceValue hasPrefix:kAUXMsgcenter]) {
        // 跳转到消息列表页面
        [self pushToSubVCOfUserCenterVC:kAUXMessageManagerViewController];
    }
    
}

#pragma mark 跳转到家庭中心次级页面
- (void)pushToSubVCOfUserCenterVC:(NSString *)stringName {
    AUXBaseViewController *baseVC = [self currentViewController];
    
    if ([baseVC isKindOfClass:NSClassFromString(stringName)]) {
        return ;
    }
    
    UINavigationController *navigationVC = baseVC.navigationController;
    NSMutableArray *viewControllers = [navigationVC.viewControllers mutableCopy];
    if ([stringName isEqualToString:kAUXUserWebViewController]) {
        AUXUserWebViewController *helpVC = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        helpVC.loadUrl = kAUXHelpURL;
        [viewControllers addObject:helpVC];
    } else {
        [viewControllers addObject:[NSClassFromString(stringName) instantiateFromStoryboard:kAUXStoryboardNameUserCenter]];
    }
    
    [navigationVC setViewControllers:viewControllers animated:YES];
}


#pragma mark 推送到商城详情
- (void)pushToStoreDetailVC:(NSString *)detailURL {
    
    AUXBaseViewController *baseVC = [self currentViewController];
    [baseVC.navigationController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    AUXStoreDetailViewController *storeDetailViewController = [AUXStoreDetailViewController instantiateFromStoryboard:kAUXStoryboardNameStore];
    storeDetailViewController.loadURL = detailURL;
    storeDetailViewController.needURL = detailURL;
    [baseVC.navigationController pushViewController:storeDetailViewController animated:YES];
}

#pragma mark 跳转到小组件页面
- (void)pushToWidgetViewController {
    AUXUserCenterViewController *userCenterViewController = [self pushToUserCenterViewController];
    
    UINavigationController *navigationController = userCenterViewController.navigationController;
    if ([[navigationController.viewControllers lastObject] isKindOfClass:[AUXComponentsViewController class]]) {
        return ;
    } else {
        
        [userCenterViewController showComponentViewController];
    }
}
#pragma mark 跳转到web页面
- (void)pushToWebVC:(AUXRemoteNotificationModel *)contentModel {
    AUXUserCenterViewController *userCenterViewController = [self pushToUserCenterViewController];
    
    AUXMessageManagerViewController *messageManagerVC = [AUXMessageManagerViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    
    AUXMessageLinkViewController *messageLinkViewController = [AUXMessageLinkViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    messageLinkViewController.loadUrl = contentModel.sourceValue;
    
    UINavigationController *navigationController = userCenterViewController.navigationController;
    NSMutableArray<AUXBaseViewController *> *viewControllers = [navigationController.viewControllers mutableCopy];
    if ([[viewControllers lastObject] isKindOfClass:[AUXUserCenterViewController class]]) {
        [viewControllers addObjectsFromArray:@[messageManagerVC , messageLinkViewController]];
    } else if ([[viewControllers lastObject] isKindOfClass:[AUXMessageManagerViewController class]]) {
        [viewControllers addObjectsFromArray:@[messageLinkViewController]];
    } else if ([[viewControllers lastObject] isKindOfClass:[AUXMessageLinkViewController class]]) {
        [viewControllers removeLastObject];
        [viewControllers addObjectsFromArray:@[messageLinkViewController]];
    }
    
    [navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark nav栈页面回退到根目录
- (void)returnToRootViewController {
    if ([self.appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
        for (int i = 0; i < tabBarController.viewControllers.count; i++) {

            if ([tabBarController.viewControllers[i] isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = tabBarController.viewControllers[i];
                [navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
}


#pragma mark 跳转到设备列表
- (AUXDeviceListViewController *)pushToDeviceListViewController {
    if ([self.appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        if (![self currentViewControllersWhtherContain:kAUXStoreViewController]) {
            [self returnToRootViewController];
        }
        
        UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
        tabBarController.selectedIndex = kAUXTabDeviceSelected;
        
        UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
        if ([navigationController.viewControllers.firstObject isKindOfClass:[AUXDeviceListViewController class]]) {
            AUXDeviceListViewController *deviceListViewController = navigationController.viewControllers.firstObject;

            return deviceListViewController;
        }
    }
    return nil;
}

#pragma mark 调跳转到场景页面
- (AUXSceneViewController *)pushToSceneListViewController {
    if ([self.appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        if (![self currentViewControllersWhtherContain:kAUXStoreViewController]) {
            [self returnToRootViewController];
        }
        
        UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
        tabBarController.selectedIndex = kAUXTabSceneSelected;
        
        UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
        if ([navigationController.viewControllers.firstObject isKindOfClass:[AUXSceneViewController class]]) {
            AUXSceneViewController *sceneListViewController = navigationController.viewControllers.firstObject;
            
            return sceneListViewController;
        }
    }
    return nil;
}

#pragma mark 跳转到商城
- (AUXStoreViewController *)pushToStoreViewController {
    if ([self.appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        if (![self currentViewControllersWhtherContain:kAUXStoreViewController]) {
            [self returnToRootViewController];
        }
        
        UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
        tabBarController.selectedIndex = kAUXTabStoreSelected;
        
        UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
        if ([navigationController.viewControllers.firstObject isKindOfClass:[AUXStoreViewController class]]) {
            AUXStoreViewController *storeViewController = navigationController.viewControllers.firstObject;
            return storeViewController;
        }
    }
    return nil;
}

#pragma mark 跳转到个人中心
- (AUXUserCenterViewController *)pushToUserCenterViewController {
    if ([self.appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        if (![self currentViewControllersWhtherContain:kAUXUserCenterViewController]) {
            [self returnToRootViewController];
        }
        
        UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
        tabBarController.selectedIndex = kAUXTabUserSelected;
        
        UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
        if ([navigationController.viewControllers.firstObject isKindOfClass:[AUXUserCenterViewController class]]) {
            AUXUserCenterViewController *userCenterViewController = navigationController.viewControllers.firstObject;
            return userCenterViewController;
        }
    }
    return nil;
}

- (AUXBaseViewController *)currentViewController {
    UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
    UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
    AUXBaseViewController *baseViewController = navigationController.viewControllers.lastObject;

    return baseViewController;
}

- (BOOL)currentViewControllersWhtherContain:(NSString *)stringClassVC {
    UITabBarController *tabBarController = (UITabBarController *)self.appDelegate.window.rootViewController;
    UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
    NSArray *viewControllers = navigationController.viewControllers;
    
    for (AUXBaseViewController *VC in viewControllers) {
        if ([VC isKindOfClass:NSClassFromString(stringClassVC)]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark 根据widget传递的deviceID跳转到设备控制页
- (void)pushToDeviceControllerWithDeviceID:(NSString *)deviceID {
    AUXDeviceListViewController *deviceListViewController = [self pushToDeviceListViewController];
    UINavigationController *navigationController = deviceListViewController.navigationController;
    
    if ([[navigationController.viewControllers lastObject] isKindOfClass: [AUXDeviceControlViewController class]]) {
        
        if ([deviceListViewController.currentDeviceId isEqualToString:deviceID]) {
            return ;
        } else {
            AUXDeviceControlViewController *deviceControlViewController = (AUXDeviceControlViewController *)[navigationController.viewControllers lastObject];
            [deviceControlViewController.navigationController popViewControllerAnimated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [deviceListViewController pushToDeviceControllerWithDeviceId:deviceID orDeviceMac:nil];
            });
        }
        
    } else {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [deviceListViewController pushToDeviceControllerWithDeviceId:deviceID orDeviceMac:nil];
        });
    }
    
}

@end
