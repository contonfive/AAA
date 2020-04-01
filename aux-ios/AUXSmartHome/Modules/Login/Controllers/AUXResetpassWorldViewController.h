//
//  AUXResetpassWorldViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXHomepageTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXResetpassWorldViewController : AUXBaseViewController
@property(nonatomic,copy)NSString *setPwdType;
@property(nonatomic,copy)NSString *phone;
@property(nonatomic,copy)NSString *code;
// 点击 tabBar “我的” 跳转到登录界面，登录成功之后切换到 “我的”
@property (nonatomic, weak) AUXHomepageTabBarController *homepageTabBarController;
@property (nonatomic,assign) AUXPushToLoginViewControllerType fromType;

@end

NS_ASSUME_NONNULL_END
