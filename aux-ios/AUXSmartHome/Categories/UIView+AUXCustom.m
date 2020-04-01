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

#import "UIView+AUXCustom.h"

@implementation UIView (AUXCustom)

- (CGPoint)originInView:(UIView *)view {
    CGPoint origin = self.frame.origin;
    
    if (view) {
        UIView *superView = self.superview;
        while (superView) {
            origin.x += CGRectGetMinX(superView.frame);
            origin.y += CGRectGetMinY(superView.frame);
            
            if ([superView isEqual:view]) {
                return origin;
            }
            
            superView = superView.superview;
        }
    }
    
    return origin;
}

- (CGRect)frameInView:(UIView *)view {
    CGRect frame = self.frame;
    
    if (view) {
        frame.origin = [self originInView:view];
    }
    
    return frame;
}

- (void)rotate360WithDuration:(CGFloat)duration repeatCount:(CGFloat)repeatCount timingMode:(AUXRotateTimingMode)timingMode rotateDirection:(AUXRotateTimingDirection)direction {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    
    NSMutableArray *values = [[NSMutableArray alloc ] init];
    if (direction == AUXRotateTimingDirectionClockwise) {
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0, 0, 1)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0, 0, 1)]];
    } else {
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(-3.13, 0, 0, 1)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(-6.26, 0, 0, 1)]];
    }
    
    animation.values = values;
    animation.cumulative = YES;
    animation.duration = duration;
    animation.repeatCount = repeatCount;
    animation.removedOnCompletion = NO;
    
    if (timingMode == AUXRotateTimingModeEaseInEaseOut) {
        NSMutableArray *timingFunctions = [[NSMutableArray alloc ] init];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.timingFunctions = timingFunctions;
    }
    
    [self.layer addAnimation:animation forKey:@"transform"];
}

- (void)rotate360EndlessLoopWithDuration:(CGFloat)duration rotateDirection:(AUXRotateTimingDirection)direction {
    [self rotate360WithDuration:duration repeatCount:MAXFLOAT timingMode:AUXRotateTimingModeLinear rotateDirection:direction];
}

- (void)stopRotating {
    [self.layer removeAllAnimations];
}

@end
