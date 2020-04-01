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

#import "AUXVersionAlertView.h"
#import "UIColor+AUXCustom.h"


@interface AUXVersionAlertView ()
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@end

@implementation AUXVersionAlertView


- (void)awakeFromNib {
    [super awakeFromNib];
    self.updateButton.layer.masksToBounds = YES;
    self.updateButton.layer.cornerRadius = 22;
    self.updateButton.layer.borderWidth = 1;
    self.updateButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
}


+ (instancetype)versionAlertViewWithVersion:(NSString*)Version cancelBlock:(void (^)(void))cancelBlock confirmBlock:(void (^)(void))confirmBlock {
    AUXVersionAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:2];
    alertView.cancelBlock = cancelBlock;
    alertView.confirmBlock = confirmBlock;
    alertView.titleLabel.text = [NSString stringWithFormat:@"检测到新版本%@",Version];
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    return alertView;
}

- (IBAction)ignoreAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.ignoreButton setImage:[UIImage imageNamed:@"update_icon_selected"] forState:UIControlStateNormal];
        NSString *versionString = APP_VERSION;
        [MyDefaults setObject:versionString forKey:kIgnorAppVersion];
    } else {
        [self.ignoreButton setImage:[UIImage imageNamed:@"update_icon_unselected"] forState:UIControlStateNormal];
        [MyDefaults setObject:@"" forKey:kIgnorAppVersion];

    }
    

}


- (void)hideAtcion {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)cancelAction:(UIButton *)sender {
    [self hideAtcion];
    if (self.cancelBlock) {
         self.cancelBlock();
    }
   
}

- (IBAction)confirmAction:(UIButton *)sender {
     [self hideAtcion];
    if (self.confirmBlock) {
        self.confirmBlock();
    }

}

@end
