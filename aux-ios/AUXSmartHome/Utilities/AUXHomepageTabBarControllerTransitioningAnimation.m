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

#import "AUXHomepageTabBarControllerTransitioningAnimation.h"

#import "AUXHomepageTabBarController.h"
#import "AUXDeviceListViewController.h"
#import "AUXUserCenterViewController.h"

@implementation AUXHomepageTabBarControllerTransitioningAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    NSTimeInterval delay = 0;
    
    UINavigationController *fromNavigationController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UINavigationController *toNavigationController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromNavigationController.view;
    UIView *toView = toNavigationController.view;
    
    UIView *containView = transitionContext.containerView;
    containView.backgroundColor = [UIColor whiteColor];
    
    [containView addSubview:toView];
    
    toView.alpha = 0;
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toView.alpha = 1;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        [transitionContext completeTransition:finished];
    }];
}

@end
