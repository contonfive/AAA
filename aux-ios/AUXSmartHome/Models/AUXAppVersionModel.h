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
#import <YYModel/YYModel.h>
@interface AUXAppVersionModel : NSObject
/**
 最新版本名字
 */
@property (nonatomic,copy) NSString *name;
/**
 最新版本号
 */
@property (nonatomic,copy) NSString *version;

/**
 AppStore 更新 version URL
 */
@property (nonatomic,copy) NSString *updateVersionUrl;
/**
 是否需要版本更新
 */
@property (nonatomic,assign) BOOL whtherNeedUpdate;
@end
