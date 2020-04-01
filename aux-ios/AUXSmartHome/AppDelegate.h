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

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "AUXMessageContentModel.h"
#import "AUXLoginViewController.h"

@protocol AUXWXRequestHandleDelegate <NSObject>

@optional
- (void)handleDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) NSDictionary *pushLaunchUserInfo;
@property (nonatomic,strong) AUXMessageContentModel *contentModel;

@property (nonatomic,weak) id<AUXWXRequestHandleDelegate> wxdelegate;

@property (nonatomic,strong) AUXLoginViewController *loginViewController;

/**
 用在 baseViewController 中，放在这里因为不同的控制器调用 baseViewController 时，self 不同
 */
@property (nonatomic,assign) BOOL showingExpireMessage;
@property (nonatomic,assign) BOOL showingErrorView;

- (void)tencentLoginWithHandler:(void (^)(NSString *openId, NSString *accessToken, NSError *error))handler;

- (void)weChatLoginWithHandler:(void (^)(int errorCode, NSString *code))handler;



@end

