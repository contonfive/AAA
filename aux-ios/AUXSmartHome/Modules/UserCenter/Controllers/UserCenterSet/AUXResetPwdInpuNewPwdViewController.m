//
//  AUXResetPwdInpuNewPwdViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXResetPwdInpuNewPwdViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXResetPwdValidationNewPwdViewController.h"
#import "NSString+AUXCustom.h"



@interface AUXResetPwdInpuNewPwdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passworldTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;//z重置密码完成按钮
@property (weak, nonatomic) IBOutlet UIView *underLine;
@property (weak, nonatomic) IBOutlet UIButton *deleteTextButton;

@end

@implementation AUXResetPwdInpuNewPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passworldTextField.delegate = self;
    self.passworldTextField.returnKeyType = UIReturnKeyDone;
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
//                                                name:@"UITextFieldTextDidChangeNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.passworldTextField becomeFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextButtonAction:nil];
    return YES;
}

- (IBAction)nextButtonAction:(UIButton *)sender {
    if (self.passworldTextField.text.length < 8) {
        if (self.passworldTextField.text.length==0) {
            [self showToastshortWithmessageinCenter:@"请输入密码"];
        }else{
            [self showToastshortWithmessageinCenter:@"密码不能小于8位"];
        }
    }else{
        AUXResetPwdValidationNewPwdViewController *resetPwdValidationNewPwdViewController = [AUXResetPwdValidationNewPwdViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        resetPwdValidationNewPwdViewController.Pwd = self.passworldTextField.text;
        resetPwdValidationNewPwdViewController.oldPwd = self.oldPwd;
        [self.navigationController pushViewController:resetPwdValidationNewPwdViewController animated:YES];
    }

}

#pragma mark  切换密码明暗文
- (IBAction)lookButtonAction:(UIButton *)sender {
    NSString *tempPwdStr = self.passworldTextField.text;
    self.passworldTextField.text = @""; // 这句代码可以防止切换的时候光标偏移
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 按下去了就是明文
        self.passworldTextField.secureTextEntry = NO;
        self.passworldTextField.text = tempPwdStr;
        [sender setImage:[UIImage imageNamed:@"common_btn_display"] forState:UIControlStateNormal];
    } else {
        // 暗文
        self.passworldTextField.secureTextEntry = YES;
        self.passworldTextField.text = tempPwdStr;
        [sender setImage:[UIImage imageNamed:@"common_btn_hidden"] forState:UIControlStateNormal];
    }
}

#pragma mark  清空输入框按钮
- (IBAction)deleteTextButtonAction:(UIButton *)sender {
    self.passworldTextField.text = @"";
}

#pragma mark - 开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.passworldTextField.text.length==0) {
        self.deleteTextButton.hidden = YES;
    }else{
        self.deleteTextButton.hidden = NO;
    }
    self.underLine.backgroundColor = [UIColor colorWithHexString:@"333333"];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.deleteTextButton.hidden = YES;
    self.underLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@",string);
    if (textField == self.passworldTextField) {
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = toBeString;
        if (self.passworldTextField.text.length==0) {
            self.deleteTextButton.hidden = YES;
        }else{
            self.deleteTextButton.hidden = NO;
        }
        if (string.length>0) {
            if ([string isStringOnlyWithNumberOrLetter]) {
                textField.text = toBeString;
            }else{
                textField.text = toBeString;
                textField.text = [toBeString substringToIndex:toBeString.length-1];
            }
        }
        if (textField.text.length > 18) {
            NSRange range = [textField.text  rangeOfComposedCharacterSequenceAtIndex:18];
            [self showToastshortWithmessageinCenter:@"密码不能超过18位"];
            if (range.length == 1) {
                textField.text = [textField.text  substringToIndex:18];
            }else{
                NSRange range = [textField.text  rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 18)];
                textField.text = [textField.text  substringWithRange:range];
            }
        }
        return NO;
    }
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

#pragma mark  点击空白收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (textField == self.passworldTextField && textField.isSecureTextEntry) {
//        textField.text = toBeString;
//        return NO;
//    }
//    return YES;
//}


@end
