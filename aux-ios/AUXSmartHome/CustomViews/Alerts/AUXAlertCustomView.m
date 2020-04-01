//
//  AUXAlertCustomView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/12.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAlertCustomView.h"

@interface AUXAlertCustomView ()

@property (nonatomic, copy) ConfirmBlcok confirmBlock;
@property (nonatomic, copy) CancleBlcok cancleBlock;

@end

@implementation AUXAlertCustomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.frame = [UIScreen mainScreen].bounds;
    self.alpha = 0;
        self.alertView.layer.masksToBounds = YES;
        self.alertView.layer.cornerRadius = 10;
    self.backView.userInteractionEnabled = YES;
}

+ (AUXAlertCustomView *)alertViewWithMessage:(NSString *)message confirmAtcion:(ConfirmBlcok)confirmAtcion cancleAtcion:(CancleBlcok)cancleAtcion {
    AUXAlertCustomView *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:6];
    alertView.alertMessageLabel.text = message;
    alertView.alertMessageLabel.numberOfLines = 0;
    alertView.alertMessageLabel.font = [UIFont systemFontOfSize:16];
    
    CGSize actualsize =[message boundingRectWithSize:CGSizeMake(kScreenWidth-84, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName,nil] context:nil].size;
    if (actualsize.height >20) {
        alertView.alertMessageLabel.textAlignment =  NSTextAlignmentLeft;
    }else{
        alertView.alertMessageLabel.textAlignment =  NSTextAlignmentCenter;

    }
    
    alertView.confirmBlock = confirmAtcion;
    alertView.cancleBlock = cancleAtcion;
 
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    
    alertView.alpha = 0;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        alertView.alpha = 1;
    }];
    
    return alertView;
    
}

- (void)setOnlyShowSureBtn:(BOOL)onlyShowSureBtn {
    _onlyShowSureBtn = onlyShowSureBtn;
    if (_onlyShowSureBtn) {
        self.verticallyView.hidden = YES;
        self.cancleBtn.hidden = YES;
        self.sureBtn.hidden = YES;
        self.expireBtn.hidden = NO;
    }
}

- (void)setConfirmTitle:(NSString *)confirmTitle {
    _confirmTitle = confirmTitle;
    
    if (!AUXWhtherNullString(_confirmTitle)) {
        [self.sureBtn setTitle:_confirmTitle forState:UIControlStateNormal];
    }
}

- (void)setCancleTitle:(NSString *)cancleTitle {
    _cancleTitle = cancleTitle;
    if (!AUXWhtherNullString(_cancleTitle)) {
        [self.cancleBtn setTitle:_cancleTitle forState:UIControlStateNormal];
    }
}

- (void)hideAtcion {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)expireAtcion:(id)sender {
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

- (IBAction)sureAtcion:(id)sender {
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

- (IBAction)cancleAtcion:(id)sender {
    self.alpha = 1;
    [UIView animateWithDuration:kAlertAnimationTime animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.cancleBlock) {
            self.cancleBlock();
        }
    }];
}

@end
