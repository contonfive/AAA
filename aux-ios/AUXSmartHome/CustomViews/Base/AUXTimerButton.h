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

@interface AUXTimerButton : UIButton

@property(nonatomic, assign) IBInspectable int disableTime;
@property(nonatomic, copy) IBInspectable NSString *coolDownText;

- (void)startCoolDown;

@end
