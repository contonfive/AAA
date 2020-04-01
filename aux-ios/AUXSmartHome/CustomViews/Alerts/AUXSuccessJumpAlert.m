//
//  AUXSuccessJumpAlert.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSuccessJumpAlert.h"

@interface AUXSuccessJumpAlert ()
@property (nonatomic,copy) ConfirmBlock confirmBlock;
@property (nonatomic,copy) CloseBlock closeBlock;
@end


@implementation AUXSuccessJumpAlert

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
}

+ (AUXSuccessJumpAlert *)alertViewtitle:(NSString*)title firstStr:(NSString*)firstStr secondStr:(NSString *)secondStr confirm:(ConfirmBlock)confirmBlock close:(CloseBlock)closeBlock{
    AUXSuccessJumpAlert *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:14];
    alertView.titleLabel.text = title;
     [alertView.reSetButton setTitle:firstStr forState:UIControlStateNormal];
     [alertView.sureButton setTitle:secondStr forState:UIControlStateNormal];
    
    alertView.confirmBlock = confirmBlock;
    alertView.closeBlock = closeBlock;
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
- (IBAction)reSetButtonAction:(UIButton *)sender {
    [self hideAtcion];
    if (self.closeBlock) {
        self.closeBlock();
    }
}

@end
