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

#import <Foundation/Foundation.h>
#import "AUXBaseViewController.h"
#import "AUXArchiveTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXVersionTool : NSObject

+ (instancetype)sharedInstance;

+ (void)getAppStoreVersionWithComplete:(void (^)(NSString * _Nullable, NSString * _Nullable))completion;

- (BOOL)shouldUpdateWithAppStoreVersion:(NSString *)appStoreVersion;

/**
 校验是否显示更新弹框

 @param viewController viewController 推出更新弹框
 */
- (void)whtherShowUpdateAlert:(AUXBaseViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
