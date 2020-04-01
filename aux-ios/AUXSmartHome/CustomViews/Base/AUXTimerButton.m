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

#import "AUXTimerButton.h"
#import "AUXTimerObject.h"

@interface AUXTimerButton()

@property(nonatomic, retain) NSTimer *timer;
@property(nonatomic, copy) NSString *normalText;
@property(nonatomic, copy) UIColor *normalColor;
@property(nonatomic, assign) int leftTime;
@property(nonatomic, assign) BOOL isCoolingDown;

@end

@implementation AUXTimerButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

//- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
- (void)startCoolDown {
    self.normalColor = self.backgroundColor;
    self.normalText = self.titleLabel.text;
    self.leftTime = self.disableTime;
    self.isCoolingDown = YES;
    [self setEnabled:NO];
    self.timer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:1 target:self selector:@selector(coolDown) userInfo:nil repeats:YES];
    
    NSString *message = [NSString stringWithFormat:self.coolDownText, self.leftTime];
    self.backgroundColor = [UIColor grayColor];
    // void blink
    self.titleLabel.text = message;
    [self setTitle:message forState:UIControlStateNormal];
    
//    [super sendAction:action to:target forEvent:event];
}

- (void)resetCoolDown {
    if (self.isCoolingDown) {
        [self.timer invalidate];
        self.timer = nil;
        self.isCoolingDown = NO;
        [self setEnabled:YES];
        self.backgroundColor = self.normalColor;
        // void blink
        self.titleLabel.text = self.normalText;
        [self setTitle:self.normalText forState:UIControlStateNormal];
    }
}

- (void)coolDown {
    if (self.leftTime > 1) {
        self.leftTime--;
        NSString *message = [NSString stringWithFormat:self.coolDownText, self.leftTime];
        // void blink
        self.titleLabel.text = message;
        [self setTitle:message forState:UIControlStateNormal];
    } else {
        [self resetCoolDown];
    }
}

@end
