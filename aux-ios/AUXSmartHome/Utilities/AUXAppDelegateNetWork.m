//
//  AUXAppDelegateNetWork.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/19.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAppDelegateNetWork.h"

#import "AppDelegate.h"
#import "AUXBaseNavigationController.h"
#import "AUXDeviceListViewController.h"
#import "AUXAlertCustomView.h"
#import "AUXConstant.h"
#import "AUXLocalNetworkTool.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXDeviceDiscoverManager.h"
#import "NSString+AUXCustom.h"
#import "AUXDefinitions.h"

@interface AUXAppDelegateNetWork ()

@end

@implementation AUXAppDelegateNetWork

+ (instancetype)sharedInstance
{
    static AUXAppDelegateNetWork *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AUXAppDelegateNetWork alloc] init];
    });
    return sharedInstance;
}

- (void)setUpNetWorkRequest {
    // 监测网络状态
    [[AUXLocalNetworkTool defaultTool] startMonitoringNetwork];
    
    [[AUXNetworkManager manager] getAccessToken:^(NSError * _Nonnull error) {
        if (error.code == AUXNetworkErrorNone) {
            
            UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            
            UINavigationController *navigationController = tabBarController.viewControllers[0];
            AUXDeviceListViewController *deviceListViewController = navigationController.viewControllers.firstObject;
            deviceListViewController.whtherRequestDeviceList = YES;
            
            if ([AUXUser isLogin]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidUpdateNotification object:nil];
                
            }
        }
    }];
}

- (void)doLoginOutWithMessage:(NSString *)message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        if (![AUXUser isLogin]) {
            return ;
        }
        
        [[AUXUser defaultUser] logout];
        
        UIApplication *applecation = [UIApplication sharedApplication];
        if ([applecation.delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                AUXAlertCustomView *alertView = [AUXAlertCustomView alertViewWithMessage:message confirmAtcion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:AUXUserDidLogoutNotification object:nil];
                } cancleAtcion:nil];
                alertView.onlyShowSureBtn = YES;
                
            });
        }
    });
}

@end
