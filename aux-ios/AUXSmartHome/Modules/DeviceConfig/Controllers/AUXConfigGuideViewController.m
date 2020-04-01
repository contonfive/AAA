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

#import "AUXConfigGuideViewController.h"
#import "AUXConfiguringViewController.h"
#import "AUXButton.h"
#import "AUXLocateTool.h"
#import "AUXLocalNetworkTool.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+AUXCustom.h"
#import "AUXWiFiConnectCustomView.h"

@interface AUXConfigGuideViewController () <QMUINavigationControllerDelegate , UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;


@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel1;
@property (weak, nonatomic) IBOutlet AUXButton *nextButton;
@end

@implementation AUXConfigGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nextButton.layer.masksToBounds = YES;
    self.nextButton.layer.cornerRadius = self.nextButton.bounds.size.height/2;
    self.nextButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    self.nextButton.layer.borderWidth = 2;
    _nextButton.userInteractionEnabled = NO;
    _nextButton.alpha = 0.2;
    
    if (self.deviceModel.category == 3) {
        self.firstLabel.text = @"① 打开风管机";
        self.promptLabel.text = @"② 长按A-link侧面按钮8秒";
        self.promptLabel1.hidden = YES;
        self.iconImageView.image = [UIImage imageNamed:@"adddevice_img_configure2"];
    } else if (self.deviceModel.category == 2) {
        self.promptLabel.text = @"② 方式1：快速连续按遥控器上的“健康”键8下，可听到“嘀嘀”声";
        self.promptLabel1.text = @"方式2：在设定温度为16度时，快速连续按线控器上的“温度-”键10下，可听到“嘀嘀”声";
        
        //方式一
        NSRange wayRange1 = [self.promptLabel.text rangeOfString:@"方式1："];
        NSRange healthRange = [self.promptLabel.text rangeOfString:@"“健康”"];
        NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:self.promptLabel.text];
        [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:wayRange1];
        [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:healthRange];
        self.promptLabel.attributedText = attributedString1;
        
        //方式二
        NSRange wayRange2 = [self.promptLabel1.text rangeOfString:@"方式2："];
        NSRange refrigerationRange = [self.promptLabel1.text rangeOfString:@"16度"];
        NSRange temperatureRange = [self.promptLabel1.text rangeOfString:@"“温度-”"];
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:self.promptLabel1.text];
        [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:wayRange2];
        [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:refrigerationRange];
        [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:temperatureRange];
        self.promptLabel1.attributedText = attributedString2;
        
    } else {
        //方式一
        NSRange wayRange1 = [self.promptLabel.text rangeOfString:@"方式1："];
        NSRange healthRange = [self.promptLabel.text rangeOfString:@"“健康”"];
        NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:self.promptLabel.text];
        [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:wayRange1];
        [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:healthRange];
        self.promptLabel.attributedText = attributedString1;
        
        //方式二
        NSRange wayRange2 = [self.promptLabel1.text rangeOfString:@"方式2："];
        NSRange refrigerationRange = [self.promptLabel1.text rangeOfString:@"“制冷”"];
        NSRange temperatureRange = [self.promptLabel1.text rangeOfString:@"“温度+”"];
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:self.promptLabel1.text];
        [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:wayRange2];
        [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:refrigerationRange];
        [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:temperatureRange];
        self.promptLabel1.attributedText = attributedString2;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkNetworkReachability];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden= NO;
    
}


- (BOOL)checkNetworkReachability {
    // 如果手机当前没有连接 Wi-Fi，则提示连接WiFi
    if (![AUXLocalNetworkTool isReachableViaWifi]) {
        if (@available(iOS 11.0, *)) {
            [AUXWiFiConnectCustomView alertWiFiConnectCustomViewconfirmAtcion:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
        } else {
            if ([AUXLocalNetworkTool defaultTool].networkReachability.networkReachabilityStatus == -1) {
                return YES;
            }else{
                [AUXWiFiConnectCustomView alertWiFiConnectCustomViewconfirmAtcion:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
            }
        }
        return NO;
    }
    return YES;
}



#pragma mark  已完成上述步骤按钮的点击事件
- (IBAction)completeButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"common_btn_selected_s"] forState:UIControlStateNormal];
        _nextButton.userInteractionEnabled = YES;
        _nextButton.alpha = 1;
    } else {
        [sender setImage:[UIImage imageNamed:@"common_btn_unselected_round"] forState:UIControlStateNormal];
        _nextButton.userInteractionEnabled = NO;
        _nextButton.alpha = 0.2;
    }
}


#pragma mark - Actions

- (IBAction)actionNextStep:(id)sender {
    if (![self checkNetworkReachability]) {
        return;
    }
    AUXConfiguringViewController *configuringViewController = [AUXConfiguringViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    configuringViewController.ssid = self.ssid;
    configuringViewController.password = self.password;
    configuringViewController.configType = self.configType;
    configuringViewController.deviceSN = self.deviceSN;
    configuringViewController.deviceModel = self.deviceModel;
    configuringViewController.isfromScan = self.isfromScan;
    [self.navigationController pushViewController:configuringViewController animated:YES];
}



@end
