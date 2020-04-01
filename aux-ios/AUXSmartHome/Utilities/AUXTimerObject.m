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

#import "AUXTimerObject.h"

@interface AUXTimerObject ()

@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;

@end

@implementation AUXTimerObject

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)isRepeats {
    
    AUXTimerObject *objc=[[AUXTimerObject alloc]init];
    objc.target = target;
    objc.selector = sel;
    
    return [NSTimer scheduledTimerWithTimeInterval:timeInterval target:objc selector:@selector(timeAction:) userInfo:userInfo repeats:isRepeats];
}

- (void)timeAction:(id)info {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // sel是否存在由调用者检查确认
    [self.target performSelector:self.selector withObject:info];
#pragma clang diagnostic pop
}

@end
