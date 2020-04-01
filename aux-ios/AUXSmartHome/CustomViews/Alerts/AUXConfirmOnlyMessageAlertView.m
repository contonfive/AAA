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

#import "AUXConfirmOnlyMessageAlertView.h"

@interface AUXConfirmOnlyMessageAlertView ()

@end

@implementation AUXConfirmOnlyMessageAlertView

+ (instancetype)messageAlertViewWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock {
    AUXConfirmOnlyMessageAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] firstObject];
    
    alertView.tipLabel.text = message;
    
    [alertView.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    alertView.confirmBlock = confirmBlock;
    
    return alertView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
}

- (IBAction)actionConfirm:(id)sender {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

@end
