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

#import "AUXSoftAPConfigGuideViewController.h"
#import "AUXWifiPasswordViewController.h"
#import "AUXLocalNetworkTool.h"
#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"
#import "AUXConfiguringViewController.h"
#import "AUXAlertCustomView.h"


@interface AUXSoftAPConfigGuideViewController ()
@property (weak, nonatomic) IBOutlet UILabel *promptLabel2;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end

@implementation AUXSoftAPConfigGuideViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.nextButton.layer.cornerRadius = self.nextButton.bounds.size.height/2;
    self.nextButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    self.nextButton.layer.borderWidth = 2;
    //方式一
    NSRange wifiRange = [self.promptLabel2.text rangeOfString:@"aux-XXXX"];
  
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:self.promptLabel2.text];
    
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:wifiRange];
    self.promptLabel2.attributedText = attributedString1;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSLog(@"我回来了");
    NSString *ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
    if ([[ssid lowercaseString] hasPrefix:@"aux-"]) {
        AUXConfiguringViewController *configuringViewController = [AUXConfiguringViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
        configuringViewController.ssid = self.ssid;
        configuringViewController.password = self.password;
        configuringViewController.configType = AUXDeviceConfigTypeGizDevice;
        configuringViewController.deviceSN = self.deviceSN;
        configuringViewController.deviceModel = self.deviceModel;
        NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
            [viewControllers removeObjectsInRange:NSMakeRange(viewControllers.count - 2, 2)];
            [viewControllers addObject:configuringViewController];
            [self.navigationController setViewControllers:viewControllers animated:YES];
    }else{
        [AUXAlertCustomView alertViewWithMessage:@"当前Wi-Fi并不是aux-XXXX，请重设" confirmAtcion:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } cancleAtcion:^{
        }];
    }
}


#pragma mark  下一步按钮的点击事件
- (IBAction)nextButtonAction:(UIButton *)sender {
    NSLog(@"我要去设置界面了");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}




@end

