//
//  AUXResetpassWorldViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//
/**
 这个界面是 注册的输入密码 和 忘记密码的输入密码  共用一个VC
 */

#import "AUXResetpassWorldViewController.h"
#import "AUXLoginViewController.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXLocalNetworkTool.h"
#import "UIColor+AUXCustom.h"
#import "NSString+AUXCustom.h"



@interface AUXResetpassWorldViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passworldTextField;
@property (weak, nonatomic) IBOutlet UIButton *completeBUtton;//z重置密码完成按钮
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UIView *underLine;
@property (weak, nonatomic) IBOutlet UIButton *deleteTextButton;
@end

@implementation AUXResetpassWorldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passworldTextField.delegate = self;
    self.completeBUtton.layer.masksToBounds = YES;
    self.completeBUtton.layer.cornerRadius = self.completeBUtton.frame.size.height/2;
    if ([self.setPwdType isEqualToString:@"forget"]) {
        //设置完成按钮的圆角
        [self.completeBUtton setTitle:@"完成" forState:UIControlStateNormal];
        self.titleTextLabel.text = @"重置密码";
    }else{
        //设置注册按钮的圆角
        [self.completeBUtton setTitle:@"注册" forState:UIControlStateNormal];
        self.titleTextLabel.text = @"设置密码";
    }
}

#pragma mark  完成按钮点击事件
- (IBAction)completeButtonAction:(id)sender {
    [self.view endEditing:YES];
    if ([self.passworldTextField.text length] == 0) {
        [self showToastshortWithmessageinCenter:@"请输入密码"];
        return;
    }
    if ([self.passworldTextField.text length] < 8) {
        [self showToastshortWithmessageinCenter:@"密码不能少于8位"];
        return;
    }
    if ([self.setPwdType isEqualToString:@"forget"]) {
        [[AUXNetworkManager manager] resetPasswordWithAccount:self.phone password:self.passworldTextField.text code:self.code completion:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
            [self handleResetPasswordResult:error];
        }];
    }else{
        [[AUXNetworkManager manager] registerWithAccount:self.phone password:self.passworldTextField.text code:self.code completion:^(AUXUser * _Nullable user, NSError * _Nonnull error) {
            [self handleRegisterResult:user error:error];
        }];
    }
    
}
#pragma mark  点击空白处收回键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark  重置密码回调
- (void)handleResetPasswordResult:(NSError *)error {
    switch (error.code) {
        case AUXNetworkErrorNone: {
            [self showToastshortWithmessageinCenter:@"修改成功，请重新登录"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case AUXNetworkErrorInvalidCode:
        case AUXNetworkErrorExpiredCode2:
        case AUXNetworkErrorInvalidCode2:{
            [self showToastshortWithmessageinCenter:@"验证码错误"];
            [self.navigationController popViewControllerAnimated:YES];
        }
             break;
        case AUXNetworkErrorInvalidPassword:{
            [self showToastshortWitherror:error];
        }
             break;
        default:
            [self hideLoadingHUD];
            [self showToastshortWitherror:error];
            break;
    }
}

#pragma mark  注册回调
- (void)handleRegisterResult:(AUXUser *)user error:(NSError *)error {
    switch (error.code) {
        case AUXNetworkErrorNone: {
            NSString *phone = self.phone;
            [AUXArchiveTool archiveUserAccount:phone];
            
            [self registerSuccessfully];
            }
            break;
        case AUXNetworkErrorInvalidCode:
        case AUXNetworkErrorExpiredCode2:
        case AUXNetworkErrorInvalidCode2:{
            [self showToastshortWithmessageinCenter:@"验证码错误"];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case AUXNetworkErrorInvalidPassword:{
            [self showToastshortWitherror:error];
        }
            break;
        default:
            [self hideLoadingHUD];
            [self showToastshortWitherror:error];
            break;
    }
}

#pragma mark   注册成功 跳转到我的界面
- (void)registerSuccessfully {
    if (self.homepageTabBarController) {
        self.homepageTabBarController.selectedIndex = kAUXTabUserSelected;
        [self.homepageTabBarController dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
            [viewControllers removeObjectsInRange:NSMakeRange(viewControllers.count - 2, 2)];
            [self.navigationController setViewControllers:viewControllers animated:YES];
     
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



- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end


