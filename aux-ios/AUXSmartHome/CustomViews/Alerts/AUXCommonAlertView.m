//
//  AUXCommonAlertView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/7.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXCommonAlertView.h"
#import "UIView+AUXCornerRadius.h"
#import "NSString+AUXCustom.h"
#import "UIView+Toast.h"

@interface AUXCommonAlertView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic,copy) NSString *changedString;
@property (nonatomic,copy) ConfirmBlock confirmBlock;
@property (nonatomic,copy) CloseBlock closeBlock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewBottom;
@property (nonatomic,assign) float duration;
@property (nonatomic,strong) NSString *spStr;
@end

@implementation AUXCommonAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 10;
    //监听textfield的输入状态
    self.detailTextField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:nil];
}

+ (AUXCommonAlertView *)alertViewWithnameType:(AUXNamingType)nameType nameLabelText:(NSString*)nameLabelText detailLabelText:(NSString *)detailLabelText confirm:(ConfirmBlock)confirmBlock close:(CloseBlock)closeBlock{
    AUXCommonAlertView *alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:13];
    alertView.nameLabel.text = nameLabelText;
    alertView.nameType = nameType;
  
    alertView.confirmBlock = confirmBlock;
    alertView.closeBlock = closeBlock;
    [alertView.detailTextField becomeFirstResponder];
    alertView.frame = [UIScreen mainScreen].bounds;
    [kAUXWindowView addSubview:alertView];
    if (detailLabelText.length==0) {
        alertView.detailTextField.placeholder  = [alertView showMessage3];
    }else{
        alertView.detailTextField.text = detailLabelText;
    }
    return alertView;
}

#pragma mark  :UITextField输入长度
- (void)textFieldEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    if (self.spStr.length !=0) {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:self.spStr withString:@""];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.sureBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.detailTextField.text.length==0) {
        self.detailTextField.placeholder = [self showMessage3];
    }
    if ([string isStringWithEmoji]) {
       self.spStr = string;
    }else{
        if (self.detailTextField.text.length==0) {
            self.detailTextField.placeholder = [self showMessage3];
        }
        self.spStr = @"";
        if (textField == self.detailTextField) {
            if (range.length == 1 && string.length == 0) {
                return YES;
            }else if (self.detailTextField.text.length >= 20) {
                
                [self showToastshortWithmessageinCenter:[self showMessage]];
                self.detailTextField.text = [textField.text substringToIndex:20];
                return NO;
            }
        }
    }
    
    return YES;
}



#pragma mark 通知监听
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    float duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.duration = duration;
    CGRect endRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    self.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        self.alertViewBottom.constant = CGRectGetHeight(endRect);
        self.alpha = 1;
        [self layoutIfNeeded];
    }];
    
}
- (void)hideAtcion {
    
    [self.detailTextField resignFirstResponder];
    [UIView animateWithDuration:self.duration animations:^{
        self.alpha = 0;
        self.alertViewBottom.constant = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self hideAtcion];
    if (self.closeBlock) {
        self.closeBlock();
    }
}
- (IBAction)ensureButtonAction:(UIButton *)sender {
    
    if (self.detailTextField.text.length==0) {
        [self showToastshortWithmessageinCenter:[self showMessage1]];
    }else{
        [self hideAtcion];
        if (self.confirmBlock) {
            self.confirmBlock(self.detailTextField.text);
        }
    }
}


#pragma mark  短Toast弹框 3s 显示在中间
-(void)showToastshortWithmessageinCenter:(NSString *)message
{
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow makeToast:message duration:3.0 position:CSToastPositionCenter style:nil];
}

-(NSString*)showMessage{
    
    NSString *message=@"";
    switch (self.nameType) {
        case AUXNamingTypeUserNickName:
        {
            message = [NSString stringWithFormat:@"昵称不能超过20位"];
        }
            break;
        case AUXNamingTypeUserName:
        {
            message = [NSString stringWithFormat:@"姓名不能超过20位"];
            
        }
            break;
        case AUXNamingTypeSceneName:
        {
            message = [NSString stringWithFormat:@"场景名称不能超过20位"];
            
        }
            break;
        default:
            break;
    }
    
    return message;
}
-(NSString*)showMessage1{
    
    NSString *message=@"";
    switch (self.nameType) {
            
        case AUXNamingTypeUserNickName:
        {
            message = [NSString stringWithFormat:@"请输入昵称"];
        }
            break;
        case AUXNamingTypeUserName:
        {
            message = [NSString stringWithFormat:@"请输入姓名"];
        }
            break;
        case AUXNamingTypeSceneName:
        {
            message = [NSString stringWithFormat:@"请输入场景名称"];
            
        }
            break;
        default:
            break;
    }
    
    return message;
}

-(NSString*)showMessage3{
    
    NSString *message=@"";
    switch (self.nameType) {
            
        case AUXNamingTypeUserNickName:
        {
            message = [NSString stringWithFormat:@"请输入昵称"];
        }
            break;
        case AUXNamingTypeUserName:
        {
            message = [NSString stringWithFormat:@"请输入姓名"];
        }
            break;
        case AUXNamingTypeSceneName:
        {
            message = [NSString stringWithFormat:@"请输入场景名称"];
            
        }
            break;
        default:
            break;
    }
    
    return message;
}


@end

