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

@interface AUXTimerObject : NSObject

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)isRepeats;

@end
