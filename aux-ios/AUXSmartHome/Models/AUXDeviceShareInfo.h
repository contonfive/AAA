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

#import "AUXDefinitions.h"

/**
 设备分享信息
 */
@interface AUXDeviceShareInfo : NSObject <YYModel>

@property (nonatomic, strong) NSString *shareId;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, assign) NSTimeInterval expiredTime;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, assign) AUXDeviceShareType userTag;   // 分享用户类型

@end
