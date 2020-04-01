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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AUXRotateTimingMode) {
    AUXRotateTimingModeEaseInEaseOut,
    AUXRotateTimingModeLinear
};

typedef NS_ENUM(NSInteger, AUXRotateTimingDirection) {
    AUXRotateTimingDirectionClockwise,
    AUXRotateTimingDirectionAntiClockwise
};

@interface UIView (AUXCustom)

- (CGPoint)originInView:(UIView *)view;
- (CGRect)frameInView:(UIView *)view;

- (void)rotate360WithDuration:(CGFloat)duration repeatCount:(CGFloat)repeatCount timingMode:(AUXRotateTimingMode)timingMode rotateDirection:(AUXRotateTimingDirection)direction;
- (void)rotate360EndlessLoopWithDuration:(CGFloat)duration rotateDirection:(AUXRotateTimingDirection)direction;
- (void)stopRotating;

@end
