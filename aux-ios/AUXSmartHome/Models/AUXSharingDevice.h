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

@interface AUXSharingDevice : NSObject

@property (nonatomic, copy) NSString *devAlias;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *qrBatch;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *userTag;
@property (nonatomic, copy) NSString *username;

@end
