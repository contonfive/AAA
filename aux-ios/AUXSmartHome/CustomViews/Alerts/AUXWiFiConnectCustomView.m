//
//  AUXWiFiConnectCustomView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWiFiConnectCustomView.h"

@interface AUXWiFiConnectCustomView ()
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (nonatomic, copy) ConfirmBlcok confirmBlock;

@end

@implementation AUXWiFiConnectCustomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = [UIScreen mainScreen].bounds;
    self.alpha = 0;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAtcion)];
    [self.backView addGestureRecognizer:tap];
    self.backView.userInteractionEnabled = YES;
    
    if (kScreenWidth>=414) {
                self.firstLabel.adjustsFontSizeToFitWidth=YES;
                self.secondLabel.adjustsFontSizeToFitWidth= YES;
        
    }
}

+ (void)alertWiFiConnectCustomViewconfirmAtcion:(ConfirmBlcok)confirmAtcion{
    
    AUXWiFiConnectCustomView *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:8];
    alertView.confirmBlock = confirmAtcion;
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
    
}

- (void)hideAtcion {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
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

- (IBAction)cancleButtonAction:(UIButton *)sender {
    
    [self hideAtcion];
}

@end
