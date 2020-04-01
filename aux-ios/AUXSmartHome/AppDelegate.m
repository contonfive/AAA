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

#import "AppDelegate.h"

#import "UIColor+AUXCustom.h"
#import "NSString+AUXCustom.h"

#import "AUXDeviceListViewController.h"

#import "RACEXTScope.h"
#import "AUXConstant.h"

#import "AUXAppDelegateNetWork.h"
#import "AUXTouchRemoteOrShareLink.h"

#import "AUXLocalNetworkTool.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXDeviceDiscoverManager.h"
#import "AUXNotificationTools.h"
#import "AUXLFCGzipUtillity.h"

#import "AUXScenePlaceQueue.h"

#import <GizWifiSDK/GizWifiSDK.h>
#import <iflyMSC/iflyMSC.h>
#import <MagicalRecord/MagicalRecord.h>
#import <CoreData/CoreData.h>
#import <Bugly/Bugly.h>

#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>

#import "JPUSHService.h"
#import "AUXMessageRecord+CoreDataClass.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "WXApi.h"
#import "TencentOpenAPI/QQApiInterface.h"
#import "TencentOpenAPI/TencentOAuth.h"

#import <AMapFoundationKit/AMapFoundationKit.h>



@interface AppDelegate () <JPUSHRegisterDelegate, WXApiDelegate, TencentSessionDelegate>

@property (nonatomic, strong) IFlyDataUploader *dataUploader;
@property (nonatomic, strong) NSData *deviceToken;

@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, copy) void (^tencentLoginHandler)(NSString *openId, NSString *accessToken, NSError *error);
@property (nonatomic, copy) void (^weChatLoginHandler)(int errorCode, NSString *code);
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 GizWifiSDK、AUXACNetwork
    [self setupGizWifiSDK];
    // 初始化科大讯飞语音SDK
    [self setupIFlyMSC];
    // 初始化 core data
    [self setupCoreData];
    //授权本地通知 -- 用来做位置场景的闹钟功能
    [self requestLocalNotificationAuthor];

    
#if DEBUG
    [Bugly startWithAppId:kTestAUXBuglyAppId];
#else
    [Bugly startWithAppId:kAUXBuglyAppId];
#endif
    
   
    
    
    
    [UMConfigure initWithAppkey:@"5ab4aad0f43e484a7a0000e6" channel:@"App Store"];
    [MobClick setScenarioType:E_UM_NORMAL];
    [MobClick setCrashReportEnabled:NO];
    
    [WXApi registerApp:@"wx56da5ea2e7839f40"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1106827098" andDelegate:self];
#pragma clang diagnostic pop
    
    [AMapServices sharedServices].apiKey = @"144434fc158b89d19bb869f47272b0f4";

    [self setRootViewController];
    
    [[AUXAppDelegateNetWork sharedInstance] setUpNetWorkRequest];
    
    //初始化极光推送
    [self setupJPUSHWithOptions:launchOptions];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (![self remoteNotificationToLoginOut:userInfo]) { //推送的内容是退出登录
        // 由remote notification启动，记录推送消息用于跳转
        self.pushLaunchUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    
    [self setWebViewUserAgent];
    [self requestStoreDomain];
    [[AUXScenePlaceQueue sharedInstance] requestOpenPlaceScene];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [AUXACDeviceManager.sharedInstance stopPolling];
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    NSLog(@"%lu",(unsigned long)tabBarController.selectedIndex);
    [MyDefaults setObject:[NSString stringWithFormat:@"%lu",(unsigned long)tabBarController.selectedIndex] forKey:kTabbarIndex];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [AUXACDeviceManager.sharedInstance startPolling];
    
    [[AUXScenePlaceQueue sharedInstance] requestOpenPlaceScene];
    
    NSString *clipboardShareData =  [UIPasteboard generalPasteboard].string;
    
    if (![AUXUser isLogin]) {
        return ;
    } else {
        if (!AUXWhtherNullString(clipboardShareData)) {
            //测试发现,mac和手机使用同一AppleId，在mac上复制的内容会复制到手机的剪贴板上.
            if ([clipboardShareData containsString:@"@aux"]) {
                [[AUXTouchRemoteOrShareLink sharedInstance] handleDidRecvQRcontent:clipboardShareData];
            }
        }
        //延时的目的是为了解决QQ登陆的时候同样使用剪贴板，延时3秒后在置位空，否则QQ第三方登不上
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //保存在系统级别的剪贴板无法擦除，只能使用猥琐方法
            [UIPasteboard generalPasteboard].string = @"";
        });
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([AUXArchiveTool shouldLogoutWhenResume]) {
            [[AUXAppDelegateNetWork sharedInstance] doLoginOutWithMessage:@"你在另一台设备登录使用该账号，本机账号强制退出。"];
        }
        [AUXArchiveTool archiveShouldLogoutWhenResume:NO];
    });
    
    [JPUSHService setBadge:0];
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    if (self.pushLaunchUserInfo) {
        [self analysePushNotificationInfo:self.pushLaunchUserInfo];
    }
    
}

/// 程序即将推出
- (void)applicationWillTerminate:(UIApplication *)application {
    
    [MagicalRecord cleanUp];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.deviceToken = deviceToken;
    [AUXUser defaultUser].deviceToken = deviceToken;
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"remote notifications device token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    self.deviceToken = nil;
    [AUXUser defaultUser].deviceToken = nil;
    NSLog(@"remote notifications error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self remoteNotificationToLoginOut:userInfo];
    
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[AUXScenePlaceQueue sharedInstance] requestOpenPlaceScene];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleApplicationOpenUrl:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleApplicationOpenUrl:url];
}

- (BOOL)handleApplicationOpenUrl:(NSURL *)url {
    if ([url.absoluteString hasPrefix:@"wx56da5ea2e7839f40"]) {
        return [WXApi handleOpenURL:url delegate:self];
    } else if ([url.absoluteString hasPrefix:@"tencent1106827098"]) {
        return [TencentOAuth HandleOpenURL:url];
    } else if ([url.absoluteString hasPrefix:@"AUXTodayExtension"]) {
        
        if ([url.absoluteString hasSuffix:@"shouldLogin"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
        } else if ([url.absoluteString hasSuffix:@"addDevice"]) {
            [[AUXTouchRemoteOrShareLink sharedInstance] pushToWidgetViewController];
        } else if ([url.absoluteString hasSuffix:@"deviceList"]) {
//            [[AUXTouchRemoteOrShareLink sharedInstance] pushToDeviceListViewController];
        } else if ([url.absoluteString containsString:@"deviceController"]) {
            NSString *deviceId = url.query;
            [[AUXTouchRemoteOrShareLink sharedInstance] pushToDeviceControllerWithDeviceID:deviceId];
        }

        return YES;
    }
    return NO;
}

#pragma mark 极光推送的透传消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
     NSLog(@"%@" , notification);
}

#pragma mark 设置webView的UserAgent
- (void)setWebViewUserAgent {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUserAgent = [userAgent stringByAppendingString:@"auxair_app"];//自定义需要拼接的字符串
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

#pragma mark 设置页面配置
- (void)setRootViewController {
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.selectedIndex = kAUXTabDeviceSelected;
    UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
    AUXDeviceListViewController *deviceListViewController = navigationController.viewControllers.firstObject;
        deviceListViewController.whtherRequestDeviceList = NO;
}

#pragma mark 获取商城配置文件
- (void)requestStoreDomain {
    [[AUXNetworkManager manager] getStoreConfigurationModelWithCompletion:^(AUXStoreDomainModel * _Nonnull storeModel, NSError * _Nonnull error) {
        
    }];
}

#pragma mark 授权本地通知
- (void)requestLocalNotificationAuthor {
    // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    // 授权通知
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];

}

#pragma mark 初始化 GizWifiSDK、AUXACNetwork
- (void)setupGizWifiSDK {
    [AUXACNetwork sharedInstance];
}

#pragma mark 初始化科大讯飞语音SDK
- (void)setupIFlyMSC {
    NSString *appId = @"appid=59b794b0";
    [IFlySpeechUtility createUtility:appId];
}

#pragma mark 初始化 core data
- (void)setupCoreData {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"AUXModel.sqlite"];
}

#pragma mark 远程推送，退出登录
- (BOOL)remoteNotificationToLoginOut:(NSDictionary *)userInfo {
    
    if (!userInfo) {
        return NO;
    }
    
    if ([[AUXTouchRemoteOrShareLink sharedInstance] shouldLogoutWithUserInfo:userInfo]) {
        
        NSString *message;
        
        if ([[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]]) {
            message = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
        } else {
            message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        }
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [[AUXAppDelegateNetWork sharedInstance] doLoginOutWithMessage:message];
        } else {
            [AUXArchiveTool archiveShouldLogoutWhenResume:YES];
        }
        return YES;
    }
    return NO;
}

#pragma mark 初始化极光推送
- (void)setupJPUSHWithOptions:(NSDictionary *)launchOptions {
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:kAUXJPushAppKey channel:@"App Store" apsForProduction:true];
    
    NSSet *set = [[NSSet alloc]initWithObjects:kAPPPUSH_LEVEL_V1 , nil];
    [JPUSHService setTags:set completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        NSLog(@"set tags code: %ld, iTags: %@, seq: %ld", (long) iResCode, iTags, (long) seq);
    } seq:0];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
//    self.pushLaunchUserInfo = notification.request.content.userInfo;
//    [self analysePushNotificationInfo:self.pushLaunchUserInfo];
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([self remoteNotificationToLoginOut:userInfo]) {
        return ;
    }
    
    self.pushLaunchUserInfo = userInfo;
    [self analysePushNotificationInfo:self.pushLaunchUserInfo];
    completionHandler();
}

- (void)analysePushNotificationInfo:(NSDictionary *)pushLaunchUserInfo {
    [AUXNotificationTools analysePushLaunchUserInfo:pushLaunchUserInfo completion:^(AUXRemoteNotificationModel *messageInfoModel, BOOL opURLSuccess) {
        if (messageInfoModel) {
            self.contentModel = messageInfoModel;
            if (opURLSuccess) {
                self.pushLaunchUserInfo = nil;
            } else {
                
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    [[AUXTouchRemoteOrShareLink sharedInstance] touchRemoteNotificationWithInfo:pushLaunchUserInfo remoteNotificationModel:messageInfoModel];
                }
                
            }
        }
    }];
}

#pragma mark -tencent
- (void)tencentLoginWithHandler:(void (^)(NSString *openId, NSString *accessToken, NSError *error))handler {
    if (handler ==nil) {
        return;
    }
    self.tencentLoginHandler = handler;
    
    [self.tencentOAuth authorize:[NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil] inSafari:NO];
}

- (void)tencentDidLogin {
    self.tencentLoginHandler(self.tencentOAuth.openId, self.tencentOAuth.accessToken, nil);
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSError *error = [[NSError alloc] initWithDomain:@"smarthome.auxgroup.com" code:-1 userInfo:nil];
    self.tencentLoginHandler(@"", @"", error);
}

- (void)tencentDidNotNetWork {
    NSError *error = [[NSError alloc] initWithDomain:@"smarthome.auxgroup.com" code:-1 userInfo:nil];
    self.tencentLoginHandler(@"", @"", error);
}

#pragma mark -weChat

- (void)weChatLoginWithHandler:(void (^)(int errorCode, NSString *code))handler {
    if (handler==nil) {
        return;
    }
    self.weChatLoginHandler = handler;
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope=@"snsapi_userinfo";
    req.state=@"aux_app_user";
    
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    } else {
        [WXApi sendAuthReq:req viewController:self.loginViewController delegate:self];
    }
    
}

- (void)onReq:(BaseReq *)req {
    NSLog(@"req %@", req);
}

-(void) onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp * authResp = (SendAuthResp *)resp;
        self.weChatLoginHandler(authResp.errCode, authResp.code);
    }
}


@end
