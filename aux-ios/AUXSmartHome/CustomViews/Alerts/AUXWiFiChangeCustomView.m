//
//  AUXWiFiChangeCustomView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWiFiChangeCustomView.h"

@interface AUXWiFiChangeCustomView ()
@property (nonatomic, copy) ConfirmBlcok confirmBlock;
@property (nonatomic, copy) CancelBlcok cancelBlock;
@end
@implementation AUXWiFiChangeCustomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = [UIScreen mainScreen].bounds;
    self.alpha = 0;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
    self.backView.userInteractionEnabled = YES;
}

- (void)alertViewWitholdWiFiName:(NSString *)oldwifiname newWiFiName:(NSString *)newWiFiName  confirmAtcion:(ConfirmBlcok)confirmAtcion cancelAction:(CancelBlcok)cancelAction {
    
    self.firstLabel.text = [NSString stringWithFormat:@"当前Wi-Fi为%@，继续进行会导致配网失败。",newWiFiName];
    self.secondLabel.text = [NSString stringWithFormat:@"请连接正确的Wi-Fi：%@",oldwifiname];
    self.confirmBlock = confirmAtcion;
    self.cancelBlock = cancelAction;
    self.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 1;
    }];
}

- (void)hidden{
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.cancelBlock) {
            self.cancelBlock();
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
