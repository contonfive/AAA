//
//  AUXOnlyOneButtonAlertView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/17.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXOnlyOneButtonAlertView.h"
#import "UIColor+AUXCustom.h"

@interface AUXOnlyOneButtonAlertView ()
@property (nonatomic,copy) ConfirmBlock confirmBlock;
@end
@implementation AUXOnlyOneButtonAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
}


+ (AUXOnlyOneButtonAlertView *)alertViewtitle:(NSString*)title buttonTitle:(NSString *)buttonTitle  confirm:(ConfirmBlock)confirmBlock {
    AUXOnlyOneButtonAlertView *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:15];
    alertView.titleLabel.text = title;
    
    if (title.length >18) {
        alertView.titleLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        alertView.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    alertView.titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    [alertView.sureButton setTitle:buttonTitle forState:UIControlStateNormal];
    alertView.confirmBlock = confirmBlock;
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    return alertView;
}


- (void)hideAtcion {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (IBAction)sureButtonAction:(UIButton *)sender {
    [self hideAtcion];
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

@end
