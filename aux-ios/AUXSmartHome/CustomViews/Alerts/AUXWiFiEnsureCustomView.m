//
//  AUXWiFiEnsureCustomView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWiFiEnsureCustomView.h"
#import "UIView+AUXCornerRadius.h"

@interface AUXWiFiEnsureCustomView ()
@property (nonatomic, copy) ConfirmBlcok confirmBlock;
@property (nonatomic, copy) ChangeBlcok changeBlock;
@end
@implementation AUXWiFiEnsureCustomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = [UIScreen mainScreen].bounds;
    self.alpha = 0;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
    self.backView.userInteractionEnabled = YES;
}

+ (void)alertViewWithWiFiName:(NSString *)wifiname  pwd:(NSString *)pwd confirmAtcion:(ConfirmBlcok)confirmAtcion changeAction:(ChangeBlcok)changeAction {
    AUXWiFiEnsureCustomView *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:9];
    alertView.wifiNameLabel.text = wifiname;
    alertView.wifiPasswordLabel.text = pwd;
    alertView.confirmBlock = confirmAtcion;
    alertView.changeBlock = changeAction;
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
}

- (IBAction)changeButtonAction:(UIButton *)sender {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.changeBlock) {
            self.changeBlock();
        }
    }];
}
- (IBAction)ensureButtonAction:(UIButton *)sender {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.confirmBlock) {
            self.confirmBlock();
        }
    }];
}

@end
