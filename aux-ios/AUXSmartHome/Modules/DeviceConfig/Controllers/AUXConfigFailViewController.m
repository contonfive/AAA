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

#import "AUXConfigFailViewController.h"
#import "AUXSoftAPConfigGuideViewController.h"
#import "AUXConfigSucceedViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXPhoneInfo.h"
#import "AUXLocateTool.h"
#import "AUXButton.h"
#import "AUXConfigTipTableViewCell.h"
#import "AUXNetworkManager.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXMoreWebViewViewController.h"
#import "AUXWifiPasswordViewController.h"
#import "AUXSNCodeSearchViewController.h"

#import "AUXSuccessJumpAlert.h"



@interface AUXConfigFailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AUXButton *retryButton;
@property (weak, nonatomic) IBOutlet AUXButton *manuaConfigButton;
@property (nonatomic, strong) NSArray<NSString *> *tipArray;
@property (nonatomic, strong) AUXACDevice *refreshDevice;
@property (nonatomic, strong) AUXDeviceInfo *refreshDeviceInfo;
@property (nonatomic, assign) BOOL refreshing;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic,strong) AUXPhoneInfo *phoneInfo;
@property (weak, nonatomic) IBOutlet UILabel *failTitleLabel;
@end

@implementation AUXConfigFailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerCellWithNibName:@"AUXConfigTipTableViewCell"];
    if (self.configStatus == AUXConfigStatusOfConfigFail) {
        self.failTitleLabel.text = @"配置失败";

        self.tableView.hidden = NO;
        self.detailLabel.hidden = YES;
        self.manuaConfigButton.hidden= NO;
        self.tipArray = @[@"• 请查看路由器Wi-Fi名称: 不允许超过30位，建议不包含空格与中文字符。",
                          @"• 请查看路由器Wi-Fi密码: 建议不超过30位，建议不带空格、不带除字母和数字外的特殊符号，不使用空密码。",
                          @"• 请查看路由器的工作模式，建议不使用访客模式进行配网。",
                          @"详见更多>"];
        self.tableView.scrollEnabled = NO;
    }else if (self.configStatus == AUXConfigStatusOfBindFail) {
        self.tableView.hidden = YES;
        self.detailLabel.hidden = NO;
        self.manuaConfigButton.hidden= YES;

        self.failTitleLabel.text = @"绑定失败";
        [self.retryButton setTitle:@"再次绑定" forState:UIControlStateNormal];
    }
    
    
    if (self.configType == AUXDeviceConfigTypeGizDeviceAirLink) {
        self.manuaConfigButton.hidden = NO;
    } else if (self.configType == AUXDeviceConfigTypeBLDevice || self.configType == AUXDeviceConfigTypeMXDevice) {
        self.manuaConfigButton.hidden = YES;
    }
    
    self.retryButton.layer.masksToBounds = YES;
    self.retryButton.layer.cornerRadius = self.retryButton.bounds.size.height/2;
    self.retryButton.layer.borderColor = [[UIColor colorWithHexString:@"666666"] CGColor];
    self.retryButton.layer.borderWidth = 2;
    _tableView.showsVerticalScrollIndicator = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
    });
    self.customBackAtcion = YES;
}

- (void)backAtcion{
    if (self.isfromScan) {
        AUXWifiPasswordViewController *wifiPasswordViewController = nil;
        for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
            if ([tempVc isKindOfClass:[AUXWifiPasswordViewController class]]) {
                wifiPasswordViewController = (AUXWifiPasswordViewController*)tempVc;
                [self.navigationController popToViewController:wifiPasswordViewController animated:YES];
            }
        }
    }else{
        AUXSNCodeSearchViewController *snCodeSearchViewController = nil;
        for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
            if ([tempVc isKindOfClass:[AUXSNCodeSearchViewController class]]) {
                snCodeSearchViewController = (AUXSNCodeSearchViewController*)tempVc;
                [self.navigationController popToViewController:snCodeSearchViewController animated:YES];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden= NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tipArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXConfigTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXConfigTipTableViewCell" forIndexPath:indexPath];
    if (self.tipArray[indexPath.section].length !=0) {
        
        if (indexPath.section==self.tipArray.count-1) {
            cell.tipLabel.text = self.tipArray[indexPath.section];
            cell.tipLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
        }else{
            cell.tipLabel.attributedText = [self createAttributeWithTitle:self.tipArray[indexPath.section] Font:20 Color:[UIColor colorWithHexString:@"666666"] range:NSMakeRange(0, 1)];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==self.tipArray.count-1) {
        AUXMoreWebViewViewController *moreWebViewViewController = [AUXMoreWebViewViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
        [self.navigationController pushViewController:moreWebViewViewController animated:YES];
    }else{
        return;
    }
}

#pragma 重试按钮的点击事件
- (IBAction)actionRetry:(id)sender {
    
    if (self.configStatus == AUXConfigStatusOfBindFail) {
        [self bindDeviceWithACDevice:self.currentDevice];
    } else {
        if (self.isfromScan) {
            AUXWifiPasswordViewController *wifiPasswordViewController = nil;
            for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                if ([tempVc isKindOfClass:[AUXWifiPasswordViewController class]]) {
                    wifiPasswordViewController = (AUXWifiPasswordViewController*)tempVc;
                    [self.navigationController popToViewController:wifiPasswordViewController animated:YES];
                }
            }
        }else{
            AUXSNCodeSearchViewController *snCodeSearchViewController = nil;
            for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                if ([tempVc isKindOfClass:[AUXSNCodeSearchViewController class]]) {
                    snCodeSearchViewController = (AUXSNCodeSearchViewController*)tempVc;
                    [self.navigationController popToViewController:snCodeSearchViewController animated:YES];
                }
            }
        }
    }
}

#pragma mark  尝试手动配置
- (IBAction)manuaConfigButtonAction:(UIButton *)sender {
    AUXSoftAPConfigGuideViewController *softAPConfigGuideViewController = [AUXSoftAPConfigGuideViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    softAPConfigGuideViewController.ssid = self.ssid;
    softAPConfigGuideViewController.password = self.password;
    softAPConfigGuideViewController.deviceSN = self.deviceSN;
    softAPConfigGuideViewController.deviceModel = self.deviceModel;
    softAPConfigGuideViewController.configType = self.configType;
    [self.navigationController pushViewController:softAPConfigGuideViewController animated:YES];
}

#pragma mark 绑定成功跳转成功页面
- (void)succeedConfiguringDevice:(AUXACDevice *)acDevice deviceInfo:(AUXDeviceInfo *)deviceInfo {
    
    AUXConfigSucceedViewController *configSucceedViewController = [AUXConfigSucceedViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];

    configSucceedViewController.configType = self.configType;
    configSucceedViewController.deviceInfo = deviceInfo;

    // 只留下 rootViewController，其他全部移掉
    NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
         [viewControllers removeObjectsInRange:NSMakeRange(1, viewControllers.count - 1)];
        [viewControllers addObject:configSucceedViewController];
        [self.navigationController setViewControllers:viewControllers animated:YES];
   
}

#pragma mark - 上传设备信息
- (void)reportInfowithStatus:(AUXConfigStatus)configStatus error:(NSError *)error{
    self.phoneInfo.config_type = self.configType == AUXDeviceConfigTypeGizDeviceAirLink ? AUXDeviceConfigTypeGizDevice : self.configType;
    if (error) {
        self.phoneInfo.connect_tag = error.userInfo[NSLocalizedDescriptionKey];
    }

    NSDictionary *configInfo = (NSDictionary *)[self.phoneInfo yy_modelToJSONObject];
    NSLog(@"configInfo---%@" , configInfo);
    [[AUXNetworkManager manager] reportConnectSuccessWithInfo:configInfo completion:^(NSError * _Nullable error) {
        // no thing to do here...
    }];
}

- (void)bindFail:(NSError *)error {
    [self showToastshortWithmessageinCenter:@"绑定失败"];
        self.phoneInfo.connect_code = error.code;
        [self reportInfowithStatus:AUXConfigStatusOfBindFail error:error];
}

#pragma mark  网络请求
- (void)bindDeviceWithACDevice:(AUXACDevice *)acDevice {
    [self showLoadingHUD];
    [[AUXACNetwork sharedInstance].delegates addObject:self];
    AUXDeviceInfo *deviceInfo = [[AUXDeviceInfo alloc] initWithACDevice:acDevice model:self.deviceModel deviceSN:self.deviceSN];
    if (self.deviceModel.suitType == AUXDeviceSuitTypeAC) {
        deviceInfo.productKey = @"60c8cbbef8814de2951383f7040aef26";
    } else if (self.deviceModel.suitType == AUXDeviceSuitTypeGateway) {
        deviceInfo.productKey = @"031fd83a03d5403a963fb45d33d85a76";
    }
    CLAuthorizationStatus status = [AUXLocateTool status];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            CLLocationCoordinate2D coordinate = [AUXLocateTool defaultTool].coordinate;
            deviceInfo.longitude = [NSString stringWithFormat:@"%@", @(coordinate.longitude)];
            deviceInfo.latitude = [NSString stringWithFormat:@"%@", @(coordinate.latitude)];
        }
            break;

        default:
            break;
    }

    [[AUXNetworkManager manager] bindDeviceWithDeviceInfo:deviceInfo completion:^(NSString * _Nullable deviceId, NSError * _Nonnull error) {
         [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.phoneInfo.connect_code = 1;
                deviceInfo.deviceId = deviceId;
                if (deviceInfo.source == AUXDeviceSourceBL) {
                    self.refreshing = YES;
                    self.refreshDevice = acDevice;
                    self.refreshDeviceInfo = deviceInfo;
                    AUXUser *user = [AUXUser defaultUser];
                    // 重新发现设备，是否存在相同mac机智云模组设备配网成功
                    [AUXACNetwork.sharedInstance getBoundDevicesWithUid:user.uid token:user.token type:AUXACNetworkDeviceWifiTypeGiz];
                } else {
                    [self succeedConfiguringDevice:acDevice deviceInfo:deviceInfo];
                }

                //设备信息上传--成功的状态
                self.phoneInfo.connect_tag = @"绑定成功";
                [self reportInfowithStatus:AUXConfigStatusOfBindSuccess error:nil];

            }
                break;

            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                [self bindFail:error];
                break;

            default:
                [self bindFail:error];
                break;
        }
    }];
}

#pragma mark - AUXACNetworkProtocol
- (void)auxACNetworkDidDiscoveredDeviceList:(NSArray *)deviceList success:(BOOL)success withError:(NSError *)error {
    if (self.refreshing) {
        self.refreshing = NO;
        NSString *newMac = [[[self.refreshDevice getMac] stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
        for (AUXACDevice *device in deviceList) {
            if ([newMac isEqualToString:[device getMac]]) {
                // 发现相同mac机智云设备，用机智云设备替换古北设备
                AUXDeviceInfo *deviceInfo = [[AUXDeviceInfo alloc] initWithACDevice:device model:self.deviceModel deviceSN:self.deviceSN];
//                deviceInfo.passCode = device.passcode;
                deviceInfo.deviceId = self.refreshDeviceInfo.deviceId;
                [self succeedConfiguringDevice:device deviceInfo:deviceInfo];
                return;
            }
        }
        // 未发现相同mac机智云设备
        [self succeedConfiguringDevice:self.refreshDevice deviceInfo:self.refreshDeviceInfo];
    }
}

#pragma mark - 懒加载
- (AUXPhoneInfo *)phoneInfo {
    if (!_phoneInfo) {
        _phoneInfo = [[AUXPhoneInfo alloc]init];
    }
    return _phoneInfo;
}

@end
