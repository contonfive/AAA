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

#import "AUXBaseViewController.h"
#import "AUXHomepageTabBarController.h"

/**
 登录
 */
@interface AUXLoginViewController : AUXBaseViewController

// 点击 tabBar “我的” 跳转到登录界面，登录成功之后切换到 “我的”
@property (nonatomic, weak) AUXHomepageTabBarController *homepageTabBarController;

/**
 创建导航栏返回按钮。
 
 @note 当 present 登录界面的时候才调用该方法。
 */
- (void)setupBackBarButtonItem;


@property (nonatomic,assign) AUXPushToLoginViewControllerType fromType;
@property (nonatomic, copy) void (^loginSuccessBlock)(void);

@end
