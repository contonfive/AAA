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

@interface AUXBindAccountViewController : AUXBaseViewController

@property (nonatomic, weak) AUXHomepageTabBarController *homepageTabBarController;

@property (nonatomic,assign) AUXBindAccountType bindAccountType;

@property (nonatomic, copy) NSString *src;
@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *accessToken;

@property (nonatomic, assign) BOOL isRegist;

@end
