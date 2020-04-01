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

#import "AUXWifiPasswordViewController.h"
#import "AUXConfigGuideViewController.h"
#import "AUXRouterDescriptionViewController.h"
#import "AUXTextField.h"
#import "AUXButton.h"
#import "AUXLocalNetworkTool.h"
#import "AUXArchiveTool.h"
#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"
#import "AUXWiFiConnectCustomView.h"
#import "AUXWiFiEnsureCustomView.h"
#import "AUXAlertCustomView.h"
#import "AUXCacheWiFiPwdTool.h"



@interface AUXWifiPasswordViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *wifiSsidTextField;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTextField;
@property (weak, nonatomic) IBOutlet AUXButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *unSupport5GButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteTextButton;//清空输入框
@end

@implementation AUXWifiPasswordViewController


-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    self.deleteTextButton.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.configType != AUXDeviceConfigTypeGizDevice) {
        self.ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
    }
    [self updateWiFiAndPassword];
    self.wifiSsidTextField.userInteractionEnabled = NO;
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.layer.cornerRadius = self.nextButton.bounds.size.height/2;
    self.nextButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    self.nextButton.layer.borderWidth = 2;
    self.wifiPasswordTextField.delegate = self;
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)];
    label.backgroundColor = [UIColor clearColor];
    self.wifiPasswordTextField.leftViewMode =UITextFieldViewModeAlways;
    self.wifiPasswordTextField.leftView = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.configType != AUXDeviceConfigTypeGizDevice) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        @weakify(self);
        [AUXLocalNetworkTool defaultTool].networkStatusChangeBlock = ^(AFNetworkReachabilityStatus status) {
            @strongify(self);
            self.ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
            [self updateWiFiAndPassword];
            
        };
        self.ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
        [self updateWiFiAndPassword];
    }
    if ([self.ssid length] == 0) {
        [AUXWiFiConnectCustomView alertWiFiConnectCustomViewconfirmAtcion:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [AUXLocalNetworkTool defaultTool].networkStatusChangeBlock = nil;
}

- (void)updateWiFiAndPassword {
    self.wifiSsidTextField.text = self.ssid;
    if ([self.ssid length] > 0) {
        
        AUXCacheWiFiPwdTool *wifipwdTool = [AUXCacheWiFiPwdTool shareAUXAUXCacheWiFiPwdTool];
        NSArray *ssidArray = [wifipwdTool.dataDic allKeys];
        BOOL iscontent = [ssidArray containsObject:self.ssid];
        if (iscontent) {
            self.wifiPasswordTextField.text = [wifipwdTool.dataDic objectForKey:self.ssid];
        }else{
            self.wifiPasswordTextField.text = @"";
        }
        NSLog(@"%@",self.wifiPasswordTextField.text);
    } else {
        self.wifiPasswordTextField.text = @"";
    }
}

#pragma mark - Notifications
- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
    [self updateWiFiAndPassword];
}


#pragma mark 不支持5G按钮的点击事件
- (IBAction)atcionUnSupport5G:(id)sender {
    AUXRouterDescriptionViewController *routerDescriptionViewController = [AUXRouterDescriptionViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    [self.navigationController pushViewController:routerDescriptionViewController animated:YES];
}
- (IBAction)changeWiFiButtonAction:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

}


#pragma mark  下一步按钮的点击事件
- (IBAction)actionNextStep:(id)sender {
    
    NSString *ssid = self.wifiSsidTextField.text;
    NSString *password = self.wifiPasswordTextField.text;
    if ([ssid length] == 0) {
        [AUXWiFiConnectCustomView alertWiFiConnectCustomViewconfirmAtcion:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        return;
    }
    if (AUXWhtherNullString(password)) {
        password = @"";
    }
    AUXCacheWiFiPwdTool *wifypwdTool = [AUXCacheWiFiPwdTool shareAUXAUXCacheWiFiPwdTool];
    
    
    [wifypwdTool.dataDic setValue:self.wifiPasswordTextField.text forKey:self.ssid];
    
    
    NSLog(@"%@",wifypwdTool.dataDic);
    
    if (password.length == 0) {
        [AUXAlertCustomView alertViewWithMessage:@"请确认您的路由器未设置密码?" confirmAtcion:^{
            [self pushConfiguringViewControllerWithSSID:ssid password:password];
        } cancleAtcion:^{
             return;
        }];   
    }else{
            [self pushConfiguringViewControllerWithSSID:ssid password:password];
    }
}

- (void)pushConfiguringViewControllerWithSSID:(NSString *)ssid password:(NSString *)password {
    [AUXArchiveTool archiveSSID:ssid password:@""];
    self.password = password;
    AUXConfigGuideViewController *configViewController = [AUXConfigGuideViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    configViewController.configType = self.configType;
    configViewController.deviceSN = self.deviceSN;
    configViewController.deviceModel = self.deviceModel;
    configViewController.ssid = self.ssid;
    configViewController.password = self.password;
    configViewController.isfromScan = self.isfromScan;
    [self.navigationController pushViewController:configViewController animated:YES];
}

#pragma mark  清空输入框按钮的点击事件
- (IBAction)deleteButtonAction:(UIButton *)sender {
    self.wifiPasswordTextField.text = @"";
}

#pragma mark  查看密码的点击事件
- (IBAction)lookButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 按下去了就是明文
        NSString *tempPwdStr = self.wifiPasswordTextField.text;
        self.wifiPasswordTextField.text = @""; // 这句代码可以防止切换的时候光标偏移
        self.wifiPasswordTextField.secureTextEntry = NO;
        self.wifiPasswordTextField.text = tempPwdStr;
        [sender setImage:[UIImage imageNamed:@"common_btn_display"] forState:UIControlStateNormal];
    } else {
        // 暗文
        NSString *tempPwdStr = self.wifiPasswordTextField.text;
        self.wifiPasswordTextField.text = @"";
        self.wifiPasswordTextField.secureTextEntry = YES;
        self.wifiPasswordTextField.text = tempPwdStr;
        [sender setImage:[UIImage imageNamed:@"common_btn_hidden"] forState:UIControlStateNormal];
    }
}

#pragma mark - 开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.deleteTextButton.hidden = NO;
}

#pragma mark - 结束编辑
-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.deleteTextButton.hidden = YES;

}

#pragma mark  点击空白收回键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
     [self.view endEditing:YES];
    [self actionNextStep:nil];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.wifiPasswordTextField && textField.isSecureTextEntry) {
        textField.text = toBeString;
        return NO;
    }
    return YES;
}




@end
