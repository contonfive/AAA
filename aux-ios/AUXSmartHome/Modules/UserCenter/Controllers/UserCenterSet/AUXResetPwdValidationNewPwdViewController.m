//
//  AUXResetPwdValidationNewPwdViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXResetPwdValidationNewPwdViewController.h"
#import "AUXArchiveTool.h"
#import "AUXLocalNetworkTool.h"
#import "AUXNetworkManager.h"
#import "AUXHomepageTabBarController.h"
#import "NSError+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "NSString+AUXCustom.h"

@interface AUXResetPwdValidationNewPwdViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passworldTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;//z重置密码完成按钮
@property (weak, nonatomic) IBOutlet UIView *underLine;
@property (weak, nonatomic) IBOutlet UIButton *deleteTextButton;

@end

@implementation AUXResetPwdValidationNewPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passworldTextField.delegate = self;
    self.passworldTextField.returnKeyType = UIReturnKeyDone;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.layer.cornerRadius = 25;
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
    if ([self.Pwd isEqualToString:self.passworldTextField.text]) {
        if (![AUXLocalNetworkTool isReachable]) {
            
            if (@available(iOS 11.0, *)) {
                [self showErrorViewWithMessage:@"当前无网络连接"];
                return;
            } else {
                AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
                if (tool.networkReachability.networkReachabilityStatus == -1) {
                }else{
                    [self showErrorViewWithMessage:@"当前无网络连接"];
                    return;
                }
            }
            
        }
        [self showLoadingHUD];
        [[AUXNetworkManager manager] changePasswordWithPasswordOld:self.oldPwd passwordNew:self.passworldTextField.text completion:^(NSError * _Nonnull error) {
            [self hideLoadingHUD];

            [self handleChangePasswordResult:error];
        }];
    }else{
        if (self.passworldTextField.text.length==0) {
            [self showToastshortWithmessageinCenter:@"请输入密码"];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            [self showToastshortWithmessageinCenter:@"两次输入密码不一致，请重新输入"];
        }
 
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


/// 处理修改秘密操作结果
- (void)handleChangePasswordResult:(NSError *)error {
    switch (error.code) {
        case AUXNetworkErrorNone: {
            
            [self showToastshortWithmessageinCenter:@"修改成功，请重新登录"];
                [self changePasswordSuccessfully];
        }
            break;
            
        case AUXNetworkErrorAccountCacheExpired:
            [self alertAccountCacheExpiredMessage];
            break;
            
        default:
            [self showErrorViewWithError:error defaultMessage:@"修改密码失败"];
            break;
    }
}

- (void)changePasswordSuccessfully {
    [[AUXUser defaultUser] logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:AUXUserDidLogoutNotification object:nil];
    AUXHomepageTabBarController *homepageTabBarController = (AUXHomepageTabBarController *)self.tabBarController;
    
    @weakify(self);
    [homepageTabBarController presentLoginViewControllerAnimated:YES completion:^{
        @strongify(self);
        self.tabBarController.selectedIndex = kAUXTabDeviceSelected;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}



#pragma mark  点击空白收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (textField == self.passworldTextField && textField.isSecureTextEntry) {
//        textField.text = toBeString;
//        return NO;
//    }
//    return YES;
//}



@end
