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

#import "NSError+AUXCustom.h"

static NSString * const kAUXErrorDomain = @"com.auxgroup.smarthome";

@implementation NSError (AUXCustom)

+ (instancetype)errorWithCode:(NSInteger)code message:(NSString *)message {
    return [NSError errorWithDomain:kAUXErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: message}];
}

+ (instancetype)errorForTimeout {
    return [self errorWithCode:-1 message:@"网络请求超时"];
}

@end
