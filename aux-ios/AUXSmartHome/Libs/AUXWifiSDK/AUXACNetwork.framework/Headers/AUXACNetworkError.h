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

@class AUXACDevice;
@interface AUXACNetworkError : NSError

- (instancetype _Nonnull)errorWithNetworkCode:(NSInteger)code userInfo:(nullable NSDictionary *)dict device:(nullable AUXACDevice *) device;

- (instancetype _Nonnull)errorWithACFaultCode:(unsigned char)code moduleProtectFault:(BOOL)moduleProtectFault device:(nullable AUXACDevice *) device;

@end
