//
//  AUXSelectGenderView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSelectGenderView.h"
#import "UIView+AUXCornerRadius.h"
@interface AUXSelectGenderView ()
@property (nonatomic,strong)NSString *selectIndex;
@property (nonatomic, copy) FGenderBlcok fGenderBlack;
@property (nonatomic, copy) MGenderBlcok mGenderBlcok;
@end


@implementation AUXSelectGenderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = [UIScreen mainScreen].bounds;
    self.alpha = 0;
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
    self.backView.userInteractionEnabled = YES;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenAction)]];
    
}

- (void)hiddenAction{
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



+ (void)alertViewWithMessage:(NSString *)message mGenderAtcion:(MGenderBlcok)mGenderAtcion fGenderAction:(FGenderBlcok)fGenderAction{
    AUXSelectGenderView *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:11];
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
    alertView.fGenderBlack = fGenderAction;
    alertView.mGenderBlcok = mGenderAtcion;
    
    alertView.selectIndex = message;
    if ([alertView.selectIndex isEqualToString:@"男"]) {
        alertView.mImageView.hidden = NO;
        alertView.fImageView.hidden = YES;
    }else if ([alertView.selectIndex isEqualToString:@"女"]){
        alertView.mImageView.hidden = YES;
        alertView.fImageView.hidden = NO;

    }else{
        alertView.mImageView.hidden = YES;
        alertView.fImageView.hidden = YES;
    }
}


- (IBAction)mGenderButtonAction:(UIButton *)sender {
    
    if (self.mGenderBlcok) {
        self.mGenderBlcok();
    }
    
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)fGenderButtonAction:(UIButton *)sender {
    
    if (self.fGenderBlack) {
        self.fGenderBlack();
    }
    
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}





@end


