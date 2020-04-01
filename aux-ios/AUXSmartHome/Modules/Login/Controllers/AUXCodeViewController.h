//
//  AUXCodeViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXHomepageTabBarController.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXCodeViewController : AUXBaseViewController
@property(nonatomic,copy)NSString *phoneNumber;
@property(nonatomic,copy)NSString *getCodeType;
@property(nonatomic,assign)BOOL getCodefailure;
// 点击 tabBar “我的” 跳转到登录界面，登录成功之后切换到 “我的”
@property (nonatomic, weak) AUXHomepageTabBarController *homepageTabBarController;
@property (nonatomic,assign) AUXBindAccountType bindAccountType;
@property (nonatomic,assign) BOOL successful;

@end

NS_ASSUME_NONNULL_END
