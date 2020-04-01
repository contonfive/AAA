/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXLoginViewController.h"
#import "AUXBindAccountViewController.h"
#import "AUXStoreBaseViewController.h"
#import "AUXStoreViewController.h"
#import "AUXCodeViewController.h"
#import "AUXForgetPassWordViewController.h"
#import "AUXTextField.h"
#import "AUXButton.h"
#import "AUXArchiveTool.h"
#import "AUXUser.h"
#import "AUXLocalNetworkTool.h"
#import "AUXNetworkManager.h"
#import "UIColor+AUXCustom.h"
#import "UIView+AUXCustom.h"
#import <JPUSHService.h>
#import "Appdelegate.h"
#import "WechatAuthSDK.h"
#import "NSString+AUXCustom.h"
#import "AUXUseProtocolViewController.h"

@interface AUXLoginViewController () <QMUINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet AUXTextField *phoneTextField;      // 手机号
@property (weak, nonatomic) IBOutlet AUXTextField *passwordTextField;   // 密码
@property (weak, nonatomic) IBOutlet AUXButton *loginButton;    // 登录
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;    // 忘记密码
@property (weak, nonatomic) IBOutlet UIButton *loginTabButton;
@property (weak, nonatomic) IBOutlet UIButton *registTabButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLineLabel;//登录下面的label
@property (weak, nonatomic) IBOutlet UIView *loginBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneUnderLine;
@property (weak, nonatomic) IBOutlet UILabel *pwdUnderLine;
@property (weak, nonatomic) IBOutlet UIButton *deleteTextButton;//清空输入框
@property (nonatomic,assign) CGFloat navHeight;
@end

@implementation AUXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_btn_back_black"] style:UIBarButtonItemStyleDone target:self action:@selector(backAtcion)];
    self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([[AUXArchiveTool getArchiveAccount] isPhoneNumber]) {
        self.phoneTextField.text = [AUXArchiveTool getArchiveAccount];
    }
    //设置登录按钮的圆角
    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height/2;
    self.phoneTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType =UIReturnKeyJoin;
    //设置登录注册下面小线条的圆角
    self.loginLineLabel.layer.masksToBounds = YES;
    self.loginLineLabel.layer.cornerRadius= 1.5;
    self.navHeight = 0;
    if (self.navigationController.viewControllers.count>1) {
        self.navHeight =64;
    }else{
        self.navHeight = 0;
    }
    self.loginTabButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    self.registTabButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.loginTabButton.frame = CGRectMake(40, self.navHeight+10, 60, 40);
    self.registTabButton.frame = CGRectMake(124, self.navHeight+21, 40, 25);
    self.loginLineLabel.frame = CGRectMake(42, self.navHeight+52, 30, 3);
 
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.extendedLayoutIncludesOpaqueBars = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phoneChanged:)
                                                name:@"UITextFieldTextDidChangeNotification" object:self.phoneTextField];
}

#pragma mark  点击空白处收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark  设置状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)setupBackBarButtonItem {
    self.customBackAtcion = YES;
}

#pragma mark - Actions

- (void)backAtcion {
    [super backAtcion];
    
    [self.view endEditing:YES];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  登录注册切换按钮
- (IBAction)loginTabAction:(UIButton *)sender {
      @weakify(self)
    [UIView animateWithDuration:0.25 animations:^{
          @strongify(self)
        self.loginTabButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
        self.registTabButton.titleLabel.font = [UIFont systemFontOfSize:18];
        self.loginTabButton.frame = CGRectMake(40, self.navHeight+10, 60, 40);
        self.registTabButton.frame = CGRectMake(124, self.navHeight+21, 40, 25);
        self.loginLineLabel.frame = CGRectMake(42, self.navHeight+52, 30, 3);
        sender.selected = YES;
        self.registTabButton.selected = NO;
        self.nextButton.hidden = YES;
        self.loginBackgroundView.hidden = NO;
         self.phoneTextField.text = [AUXArchiveTool getArchiveAccount];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark  登录注册切换按钮
- (IBAction)registTabAction:(UIButton *)sender {
    @weakify(self)
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self)
        self.registTabButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
        self.loginTabButton.titleLabel.font = [UIFont systemFontOfSize:18];
        self.loginTabButton.frame = CGRectMake(40, self.navHeight+21, 40, 25);
        self.registTabButton.frame = CGRectMake(104, self.navHeight+10, 60, 40);
        self.loginLineLabel.frame = CGRectMake(106, self.navHeight+52, 30, 3);
        sender.selected = YES;
        self.loginTabButton.selected = NO;
        self.nextButton.hidden = NO;
        self.loginBackgroundView.hidden = YES;
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        AUXUseProtocolViewController *useProtocolViewController = [AUXUseProtocolViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
        [self.navigationController pushViewController:useProtocolViewController animated:YES];
        useProtocolViewController.exitBlock = ^{
            @strongify(self)
            NSString *phone = self.phoneTextField.text;
            [AUXArchiveTool archiveUserAccount:phone];
            [self loginTabAction:self.loginTabButton];
        };
        useProtocolViewController.backBlock = ^{
            NSString *phone = self.phoneTextField.text;
            [AUXArchiveTool archiveUserAccount:phone];
            @strongify(self)
            [self loginTabAction:self.loginTabButton];
        };
    }];
}


#pragma mark  登录按钮点击事件
- (IBAction)actionLogin:(id)sender {
    [self.view endEditing:YES];
    NSString *phone = [self.phoneTextField.text qmui_trim];
    NSString *password = self.passwordTextField.text;
    if (!AUXCheckPhoneNumber(self.phoneTextField.text)) {
        [self showToastshortWithmessageinCenter:@"请输入正确的手机号"];
        return;
    }
    if ([phone length] == 0) {
        [self showToastshortWithmessageinCenter:@"请输入手机号"];
        return;
    }
    if ([password length] == 0) {
        [self showToastshortWithmessageinCenter:@"请输入密码"];
        
        return;
    }
    if ([password length] < 8) {
        [self showToastshortWithmessageinCenter:@"密码不能小于8位"];
        return;
    }
    
    AUXLocalNetworkTool  *tool = [AUXLocalNetworkTool defaultTool];
    if (![AUXLocalNetworkTool isReachable]) {
        
        if (@available(iOS 11.0, *)) {
            [self showToastshortWithmessageinCenter:@"当前无网络连接"];
            return;
        } else {
            if (tool.networkReachability.networkReachabilityStatus == -1) {
            }else{
                [self showToastshortWithmessageinCenter:@"当前无网络连接"];
                return;
            }
        }
    }
    [self showLoadingHUD];
    @weakify(self);
    [[AUXNetworkManager manager] userLoginWithAccount:phone password:password completion:^(AUXUser * _Nullable user, NSError * _Nonnull error) {
        @strongify(self);
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXUserDidLoginNotification object:nil];
                NSString *phone = self.phoneTextField.text;
                [AUXArchiveTool archiveUserAccount:phone];
                
                [self loginSuccessfully];
                [self showToastshortWithmessageinCenter:@"登录成功"];
            }
                break;
            default:
                
                [self showToastshortWitherror:error];
                break;
        }
    }];
}

#pragma mark   忘记密码
- (IBAction)actionForgotPassword:(id)sender {
        [self.view endEditing:YES];
        AUXForgetPassWordViewController *forgetPassWordVC = [AUXForgetPassWordViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
        NSString *phone = self.phoneTextField.text;
        forgetPassWordVC.phoneNumber = phone;
        forgetPassWordVC.getCodeType = @"forget";
        [self.navigationController pushViewController:forgetPassWordVC animated:YES];
}

#pragma mark  注册--下一步
- (IBAction)nextButtonAction:(UIButton *)sender {
    NSString *phone = [self.phoneTextField.text qmui_trim];
    if (!AUXCheckPhoneNumber(self.phoneTextField.text)) {
        [self showToastshortWithmessageinCenter:@"请输入正确的手机号"];
        return;
    }
    if ([phone length] == 0) {
        [self showToastshortWithmessageinCenter:@"请输入手机号"];
        return;
    }else{
        [self.view endEditing:YES];
        [[AUXNetworkManager manager] registryPhone:phone completion:^(NSString * _Nonnull code, NSError * _Nonnull error) {
            switch (error.code) {
                case AUXNetworkErrorNone:{
                    AUXCodeViewController *codeViewController = [AUXCodeViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
                    codeViewController.phoneNumber = phone;
                    codeViewController.successful = YES;
                    codeViewController.getCodeType = @"regist";
                    codeViewController.getCodefailure = YES;
                    codeViewController.homepageTabBarController = self.homepageTabBarController;
                    [self showToastshortWithmessageinCenter:@"验证码发送成功，请注意查收"];
                    
                    [self.navigationController pushViewController:codeViewController animated:YES];
                }
                   break;
                case AUXNetworkErrorInvalidCode1:{
                    AUXCodeViewController *codeViewController = [AUXCodeViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
                    codeViewController.phoneNumber = phone;
                    codeViewController.getCodeType = @"regist";
                    codeViewController.getCodefailure = YES;
                    codeViewController.homepageTabBarController = self.homepageTabBarController;
                    [self showToastshortWithmessageinCenter:error.userInfo[NSLocalizedDescriptionKey]];
                    [self.navigationController pushViewController:codeViewController animated:YES];
                }
                    break;
                default:
                    [self showToastshortWithmessageinCenter:error.userInfo[NSLocalizedDescriptionKey]];
                    break;
            }
        }];
    }
}
#pragma mark  切换密码明暗文
- (IBAction)lookButtonAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 按下去了就是明文
        NSString *tempPwdStr = self.passwordTextField.text;
        self.passwordTextField.text = @""; // 这句代码可以防止切换的时候光标偏移
        self.passwordTextField.secureTextEntry = NO;
        self.passwordTextField.text = tempPwdStr;
        [sender setImage:[UIImage imageNamed:@"common_btn_display"] forState:UIControlStateNormal];
    } else {
        // 暗文
        NSString *tempPwdStr = self.passwordTextField.text;
        self.passwordTextField.text = @"";
        self.passwordTextField.text = tempPwdStr;
        self.passwordTextField.secureTextEntry = YES;
        [sender setImage:[UIImage imageNamed:@"common_btn_hidden"] forState:UIControlStateNormal];
    }
}
#pragma mark  清空输入框按钮
- (IBAction)deleteTextButtonAction:(id)sender {
    self.passwordTextField.text = @"";
}



#pragma mark  微信登录
- (IBAction)weChatLogin:(UIButton *)sender {
    [AUXArchiveTool removeUserAccount];
    AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    delegate.loginViewController = self;
    @weakify(self)
    [delegate weChatLoginWithHandler:^(int errorCode, NSString *code) {
        @strongify(self)
        if (errorCode == WechatAuth_Err_Ok) {
            [self showLoadingHUD];
            @weakify(self)
            [[AUXNetworkManager manager] loginBy3rdWithSrc:@"wechat" code:code token:@"" openId:@"" completion:^(AUXUser * _Nullable user, NSString * _Nullable token, NSString * _Nullable openId, NSError * _Nonnull error) {
                @strongify(self)
                [self hideLoadingHUD];
                [self handler3rdLoginUser:user error:error src:@"wechat" openId:openId token:token];
            }];
        } else {
            [self showToastshortWithmessageinCenter:@"登录失败"];
            
        }
    }];
}

#pragma mark  QQ登录
- (IBAction)qqLogin:(UIButton *)sender {
    [AUXArchiveTool removeUserAccount];
    AppDelegate *delegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    @weakify(self)
    [delegate tencentLoginWithHandler:^(NSString *openId, NSString *accessToken, NSError *error) {
        @strongify(self)
        if (!error) {
            [self showLoadingHUD];
            @weakify(self)
            [[AUXNetworkManager manager] loginBy3rdWithSrc:@"qq" code:@"" token:accessToken openId:openId completion:^(AUXUser * _Nullable user, NSString * _Nullable _token, NSString * _Nullable _openId, NSError * _Nonnull error) {
                @strongify(self)
                [self hideLoadingHUD];
                [self handler3rdLoginUser:user error:error src:@"qq" openId:openId token:accessToken];
            }];
        } else {
            [self showToastshortWithmessageinCenter:@"登录失败"];
        }
    }];
}


#pragma mark  调用三方登录
- (void)handler3rdLoginUser:(AUXUser *)user error:(NSError *)error src:(NSString *)src openId:(NSString *)openId token:(NSString *)accessToken {
    if (error.code == AUXNetworkErrorNone) {
        if (user.needBindInFirstTIme && !user.justRegister) {
            AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
            bindAccountViewController.src = src;
            bindAccountViewController.openId = openId;
            bindAccountViewController.accessToken = accessToken;
            bindAccountViewController.isRegist = YES;
            bindAccountViewController.bindAccountType = AUXBindAccountTypeOfLogin;
            bindAccountViewController.homepageTabBarController = self.homepageTabBarController;
            [self.navigationController pushViewController:bindAccountViewController animated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:AUXUserDidLoginNotification object:nil];
            [self loginSuccessfully];
            [self showToastshortWithmessageinCenter:@"登录成功"];
        }
        
    } else {
        [self showToastshortWithmessageinCenter:@"登录失败"];
        [[AUXUser defaultUser] logout];
    }
}

- (void)loginSuccessfully {
    [self getDeviceList];
    if (self.homepageTabBarController) {
        
        NSInteger tabbarIndex = [[MyDefaults objectForKey:kTabbarIndex] integerValue];
        self.homepageTabBarController.selectedIndex = tabbarIndex;
        [self.homepageTabBarController dismissViewControllerAnimated:YES completion:nil];
        [MyDefaults setObject:@"0" forKey:kTabbarIndex];
    } else if (self.fromType == AUXPushToLoginViewControllerTypeOfFromStore) {
        if (self.loginSuccessBlock) {
            self.loginSuccessBlock();
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// 获取设备列表
- (void)getDeviceList {
    [self hideLoadingHUD];
    if ([AUXUser isLogin]) {
        [[AUXNetworkManager manager] getDeviceListWithCompletion:^(NSArray<AUXDeviceInfo *> * _Nullable deviceInfoList, NSError * _Nonnull error) {
            
            switch (error.code) {
                case AUXNetworkErrorNone:
                    [self dealWithDeviceInfoList:deviceInfoList];
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

/// 处理设备列表
- (void)dealWithDeviceInfoList:(NSArray<AUXDeviceInfo *> *)deviceInfoList {
    if (!deviceInfoList || deviceInfoList.count == 0) {
        return;
    }
    [AUXUser defaultUser].deviceInfoArray = [NSMutableArray arrayWithArray:deviceInfoList];
}

#pragma mark - 开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.phoneTextField]){
        self.phoneUnderLine.backgroundColor = [UIColor colorWithHexString:@"333333"];
        self.pwdUnderLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
    }else{
        if (self.passwordTextField.text.length==0) {
             self.deleteTextButton.hidden = YES;
        }else{
             self.deleteTextButton.hidden = NO;
        }
       
        self.phoneUnderLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
        self.pwdUnderLine.backgroundColor = [UIColor colorWithHexString:@"333333"];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:self.phoneTextField]){
        self.phoneUnderLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];

    }else{
        self.deleteTextButton.hidden = YES;
        self.pwdUnderLine.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.loginTabButton.selected) {
        if ([textField isEqual:self.phoneTextField]) {
            [self.phoneTextField resignFirstResponder];
            [self.passwordTextField becomeFirstResponder];
        } else {
            [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

        if (textField == self.passwordTextField) {
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = toBeString;
            if (self.passwordTextField.text.length==0) {
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



#pragma mark  :UITextField输入长度
-(void)phoneChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    if (textField == self.phoneTextField) {
        NSString *text = textField.text;
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (text.length > 11) {
                [self showToastshortWithmessageinCenter:@"手机号不能超过11位"];
                NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:11];
                if (range.length == 1) {
                    textField.text = [text substringToIndex:11];
                }else{
                    NSRange range = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 11)];
                    textField.text = [text substringWithRange:range];
                }
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}




@end




