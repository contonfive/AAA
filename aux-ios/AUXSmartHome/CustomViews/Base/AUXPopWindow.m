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

#import "AUXPopWindow.h"

#import "RACEXTScope.h"
#import "AUXBaseViewController.h"

@interface AUXPopWindow ()

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) NSLayoutConstraint *backgroundBottomHidden;
@property (nonatomic, retain) NSLayoutConstraint *presentViewBottomVisable;

@end

@implementation AUXPopWindow

+ (instancetype)sharedInstance {
    static AUXPopWindow *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AUXPopWindow alloc] _initSelf];
    });
    return instance;
}

- (id)_initSelf {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.rootViewController = [[AUXBaseViewController alloc] init];
    [self.rootViewController.view setBackgroundColor:[UIColor clearColor]];
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.4;
    
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rootViewController.view addSubview:_backgroundView];
    [[self.rootViewController.view.topAnchor constraintEqualToAnchor:_backgroundView.topAnchor] setActive:YES];
    [[self.rootViewController.view.centerXAnchor constraintEqualToAnchor:_backgroundView.centerXAnchor] setActive:YES];
    [[self.rootViewController.view.widthAnchor constraintEqualToAnchor:_backgroundView.widthAnchor] setActive:YES];
    
    _backgroundBottomHidden = [self.rootViewController.view.bottomAnchor constraintEqualToAnchor:_backgroundView.bottomAnchor];
    [_backgroundBottomHidden setActive:YES];
    
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideWithAnimation)]];
    
    return self;
}

- (void)setPresentView:(UIView *)presentView {
    if (self.presentView) {
        [self.presentView removeFromSuperview];
    }
    _presentView = presentView;
    [self.rootViewController.view addSubview:self.presentView];

    self.presentView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.rootViewController.view.widthAnchor constraintEqualToAnchor:self.presentView.widthAnchor] setActive:YES];
    [[self.rootViewController.view.centerXAnchor constraintEqualToAnchor:self.presentView.centerXAnchor] setActive:YES];
//    [[self.rootViewController.view.heightAnchor constraintEqualToAnchor:self.presentView.heightAnchor multiplier:2] setActive:YES];
    [[self.backgroundView.bottomAnchor constraintEqualToAnchor:self.presentView.topAnchor] setActive:YES];

    self.presentViewBottomVisable = [self.rootViewController.view.bottomAnchor constraintEqualToAnchor:self.presentView.bottomAnchor];
    [self.presentViewBottomVisable setActive:NO];
}

- (void)showWithAnimation {
    @weakify(self);
    [UIView animateWithDuration:1.5f animations:^{
        @strongify(self);
        [self makeKeyAndVisible];
        self.hidden = NO;
        
        [self.backgroundBottomHidden setActive:NO];
        [self.presentViewBottomVisable setActive:YES];
    }];
}

- (void)hideWithAnimation {
    @weakify(self);
    [UIView animateWithDuration:1.5f animations:^{
        @strongify(self);
        [self.backgroundBottomHidden setActive:YES];
        [self.presentViewBottomVisable setActive:NO];
    } completion:^(BOOL finished) {
        [self resignKeyWindow];
        self.hidden = YES;
    }];
}

@end
