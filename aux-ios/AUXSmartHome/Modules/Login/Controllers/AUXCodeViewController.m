//
//  AUXCodeViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXCodeViewController.h"
#import "CodeInputView.h"
#import "AUXNetworkManager.h"
#import "AUXResetpassWorldViewController.h"
#import "AUXLocalNetworkTool.h"

@interface AUXCodeViewController ()
@property(nonatomic,strong)CodeInputView * codeView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (nonatomic, strong) NSTimer *countdownTimer;      // 发送验证码倒计时
@property (nonatomic, assign) NSInteger currentCountdown;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *getCodeButton;
@property(nonatomic,copy)NSString *code;
@property (weak, nonatomic) IBOutlet UIView *codeBackView;

@end

@implementation AUXCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeButton.userInteractionEnabled = NO;
    self.phoneLabel.text = [NSString stringWithFormat:@"已发送至%@,",self.phoneNumber];
    if ([self.getCodeType isEqualToString:@"binding"]) {
        [self requestRegisterCheckPhone:self.phoneNumber];
    }else{
        if (!self.getCodefailure) {
            [self setTime];
        }else{
            [self setButtonHiddenState:YES];
        }
    }
    if (self.successful) {
         [self setTime];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.codeView) {
        [self.codeView removeFromSuperview];
        self.codeView = nil;
    }
    [self.codeBackView addSubview:self.codeView];
}

#pragma mark  设置验证码输入框
- (CodeInputView *)codeView {
    if (!_codeView) {
        @weakify(self)
        _codeView = [[CodeInputView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80) inputType:6 selectCodeBlock:^(NSString * code) {
            @strongify(self)
            if (code.length == 6) {
                self.code = code;
                NSLog(@"code === %@",self.code);
                if ([self.getCodeType isEqualToString:@"binding"]) {
                    [self bindingAccount];
                }else{
                    AUXResetpassWorldViewController *forgetPassWordVC = [AUXResetpassWorldViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
                    forgetPassWordVC.setPwdType = self.getCodeType;
                    forgetPassWordVC.phone = self.phoneNumber;
                    forgetPassWordVC.code = self.code;
                    forgetPassWordVC.homepageTabBarController = self.homepageTabBarController;
                    [self.navigationController pushViewController:forgetPassWordVC animated:YES];
                }
            }
        }];
    }
    return _codeView;
}

#pragma mark 发送验证码
- (void)requestRegisterCheckPhone:(NSString *)phone {
    if ([self.getCodeType isEqualToString:@"regist"]) {
        [[AUXNetworkManager manager] registryPhone:phone completion:^(NSString * _Nonnull code, NSError * _Nonnull error) {
            if (error.code == AUXNetworkErrorNone) {
                [self setTime];
                [self showToastshortWithmessageinCenter:@"验证码发送成功，请注意查收"];
            } else {
                [self showToastshortWithmessageinCenter:error.userInfo[NSLocalizedDescriptionKey]];
                [self.getCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
                [self setButtonHiddenState:YES];
                [self.countdownTimer invalidate];
                self.countdownTimer = nil;
            }
        }];
    }else  if ([self.getCodeType isEqualToString:@"forget"]){
        [[AUXNetworkManager manager] forgetPwdPhone:phone completion:^(NSString * _Nonnull code, NSError * _Nonnull error) {
            if (error.code == AUXNetworkErrorNone) {
                [self showToastshortWithmessageinCenter:@"验证码发送成功，请注意查收"];
                [self setTime];
            } else {
                [self showToastshortWithmessageinCenter:error.userInfo[NSLocalizedDescriptionKey]];
                [self.getCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
                [self setButtonHiddenState:YES];
                [self.countdownTimer invalidate];
                self.countdownTimer = nil;
            }
        }];
    }else{
        [[AUXNetworkManager manager] thirdBindAccountSMSCode:phone completion:^(NSError * _Nonnull error) {
            if (error.code == AUXNetworkErrorNone) {
                [self showToastshortWithmessageinCenter:@"验证码发送成功，请注意查收"];
                [self setTime];
            } else {
                [self showToastshortWithmessageinCenter:error.userInfo[NSLocalizedDescriptionKey]];
                [self.getCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
                [self setButtonHiddenState:YES];
                [self.countdownTimer invalidate];
                self.countdownTimer = nil;
            }
        }];
    }
}

#pragma mark  获取验证码 开始倒计时。60s后才可再次获取验证码
- (IBAction)getCodeButtonAction:(UIButton *)sender {
    [self requestRegisterCheckPhone:self.phoneNumber];
}


#pragma mark  设置计时器
-(void)setTime{
    [self setButtonHiddenState:NO];
    [self.timeButton setTitle:@"（60)" forState:UIControlStateNormal];
    self.currentCountdown = 59;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countingDown) userInfo:nil repeats:YES];
}

#pragma mark  计时器调用方法
- (void)countingDown {
    if (self.currentCountdown > 0) {
        [self.timeButton setTitle:[NSString stringWithFormat:@"（%@）", @(self.currentCountdown--)] forState:UIControlStateNormal];
    } else {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.getCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
        [self setButtonHiddenState:YES];
    }
}

#pragma mark  设置按钮是否显示
-(void)setButtonHiddenState:(BOOL)state{
    self.getCodeButton.hidden = !state;
    self.timeLabel.hidden = state;
    self.timeButton.hidden = state;
}


-(void)bindingAccount{
    @weakify(self)
    [self showLoadingHUD];
    [[AUXNetworkManager manager] bindAccountWithUid:[AUXUser defaultUser].uid phone:self.phoneNumber smsCode:self.code completion:^(NSError * _Nonnull error) {
        @strongify(self)
        [self hideLoadingHUD];
        if (error.code == AUXNetworkErrorNone) {
            [self bindSuccessfully];
            [AUXUser defaultUser].phone = self.phoneNumber;
            [AUXUser archiveUser];
            [self showToastshortWithmessageinCenter:@"绑定成功"];
        } else {
            [self showToastshortWitherror:error];
            if (error.code != AUXNetworkErrorInvalidCode2) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

#pragma mark  绑定成功开始跳转
- (void)bindSuccessfully{
    if (self.bindAccountType == AUXBindAccountTypeOfLogin) {
        if (self.homepageTabBarController) {
            self.homepageTabBarController.selectedIndex = kAUXTabDeviceSelected;
            [self.homepageTabBarController dismissViewControllerAnimated:YES completion:nil];
        }
    } else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


//- (void)viewDidDisappear:(BOOL)animated{
//    [self.countdownTimer invalidate];
//    self.countdownTimer = nil;
//}

@end





