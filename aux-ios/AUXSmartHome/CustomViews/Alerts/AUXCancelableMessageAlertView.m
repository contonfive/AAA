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

#import "AUXCancelableMessageAlertView.h"

@interface AUXCancelableMessageAlertView ()


@end

@implementation AUXCancelableMessageAlertView

+ (instancetype)messageAlertViewWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(void))cancelBlock confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock {
    AUXCancelableMessageAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:1];
    
    alertView.tipLabel.text = message;
    
    [alertView.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [alertView.confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    alertView.cancelBlock = cancelBlock;
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

- (IBAction)actionCancel:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end
