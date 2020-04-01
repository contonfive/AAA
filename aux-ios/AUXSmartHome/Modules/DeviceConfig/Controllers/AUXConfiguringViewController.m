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

#import "AUXConfiguringViewController.h"
#import "AUXConfigSucceedViewController.h"
#import "AUXConfigFailViewController.h"
#import "AUXUser.h"
#import "AUXPhoneInfo.h"
#import "AUXNetworkManager.h"
#import "AUXLocateTool.h"
#import "AUXLocalNetworkTool.h"
#import <GizWifiSDK/GizWifiSDK.h>
#import "UIColor+AUXCustom.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AUXWiFiChangeCustomView.h"
@interface AUXConfiguringViewController () <AUXACNetworkProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *circleImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) NSString *currentMac;
@property (nonatomic, strong) NSTimer *configureTimer;
@property (nonatomic, strong) NSTimer *discoverTimer;
@property (nonatomic, assign) NSInteger discoverCount;
@property (nonatomic, strong) AUXACDevice *refreshDevice;
@property (nonatomic, strong) AUXACDevice *baindDevice;
@property (nonatomic, strong) AUXDeviceInfo *refreshDeviceInfo;
@property (nonatomic,strong) AUXPhoneInfo *phoneInfo;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSInteger currentCountdown;
@property (nonatomic, strong)AUXWiFiChangeCustomView *alertView;
@end


@implementation AUXConfiguringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAnimation];
    [[AUXACNetwork sharedInstance].delegates addObject:self];
    // 60s配置超时
    self.configureTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(configureTimeout) userInfo:nil repeats:NO];
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(countingDown) userInfo:nil repeats:YES];
    self.currentCountdown = 1;
    self.numberLabel.attributedText = [self createAttributeWithTitle:self.numberLabel.text Font:60 Color:[UIColor colorWithHexString:@"256BBD"] range:NSMakeRange(0, self.numberLabel.text.length-1)];
    // 开始配置
    AUXACNetworkWifiHardwareType hardwareType = (char) self.deviceModel.hardwareType;
    switch (self.configType) {
        case AUXDeviceConfigTypeBLDevice:   // 旧设备
            [[AUXACNetwork sharedInstance] setDeviceOnboarding:self.ssid password:self.password timeout:60 wifiType:AUXACNetworkDeviceWifiTypeBL hardwareType:AUXACNetworkWifiHardwareTypeBL softAPSSIDPrefix:nil];
            break;

        case AUXDeviceConfigTypeGizDevice:    // 新设备 soft AP 配置
            [[AUXACNetwork sharedInstance] setDeviceOnboarding:self.ssid password:self.password timeout:60 wifiType:AUXACNetworkDeviceWifiTypeGiz hardwareType:hardwareType softAPSSIDPrefix:@"aux-"];
            break;
        case AUXDeviceConfigTypeGizDeviceAirLink:   // 新设备 air link 配置
        default:
            [[AUXACNetwork sharedInstance] setDeviceOnboarding:self.ssid password:self.password timeout:60 wifiType:AUXACNetworkDeviceWifiTypeGiz hardwareType:hardwareType softAPSSIDPrefix:nil];
            break;
    }

    [AUXLocalNetworkTool defaultTool].networkStatusChangeBlock = ^(AFNetworkReachabilityStatus status) {
        NSString *ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
        if ([[ssid lowercaseString] hasPrefix:@"aux-"]) {
        }else{
            if (![self.ssid isEqualToString:[AUXLocalNetworkTool getCurrentWiFiSSID]]) {
                if (ssid.length != 0) {
                    NSString *str  = [AUXLocalNetworkTool getCurrentWiFiSSID];
                    UIViewController *tmpController = [self jsd_getCurrentViewController];
                    if ([tmpController isKindOfClass:[AUXConfiguringViewController class]]) {

                        if (self.alertView == nil) {
                            self.alertView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:10];
                            
                            [self.alertView alertViewWitholdWiFiName:self.ssid newWiFiName:str confirmAtcion:^{
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                            } cancelAction:^{
                                [self setFailViewController:AUXConfigStatusOfConfigFail];
                                [self.configureTimer invalidate];
                                self.configureTimer = nil;
                                [self.countdownTimer invalidate];
                                self.countdownTimer = nil;
                            }];
                        }
                    }
                }
            }else{
                [self setAnimation];
            }
        }
    };
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSString *ssid = [AUXLocalNetworkTool getCurrentWiFiSSID];
    if ([[ssid lowercaseString] hasPrefix:@"aux-"]) {
        [self setAnimation];
    }
     [self setAnimation];
}

#pragma mark  设置动画
-(void)setAnimation{
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basic.duration = 10;
    basic.fromValue = [NSNumber numberWithInt:0];
    basic.toValue = [NSNumber numberWithInt:M_PI * 2];
    [basic setRepeatCount:MAXFLOAT];
    [basic setAutoreverses: NO];
    [basic setCumulative:YES];
    self.circleImageView.layer.speed = 5;
    [self.circleImageView.layer addAnimation:basic forKey:@"basicAnimation"];
}

#pragma mark  计时器配置百分比
-(void)countingDown{
    if (self.currentCountdown < 99) {
        self.currentCountdown += 1;
        self.numberLabel.text = [NSString stringWithFormat:@"%ld%%",(long)self.currentCountdown];
        self.numberLabel.attributedText = [self createAttributeWithTitle:self.numberLabel.text Font:60 Color:[UIColor colorWithHexString:@"256BBD"] range:NSMakeRange(0, self.numberLabel.text.length-1)];
    }else{
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
}

- (void)dealloc {
    [[AUXACNetwork sharedInstance].delegates removeObject:self];
}

#pragma mark   配置失败
- (void)failToConfigureDevice:(NSError *)error {
    // 如果不是模拟器，上传配网信息
    
#if !TARGET_IPHONE_SIMULATOR
    //设备信息上传--错误的状态
    self.phoneInfo.connect_code = -1;
    self.phoneInfo.connect_tag = @"配网失败";
    [self reportInfowithStatus:AUXConfigStatusOfConfigFail error:nil];
#endif
    [self setFailViewController:AUXConfigStatusOfConfigFail];
}

#pragma mark - 上传设备信息
- (void)reportInfowithStatus:(AUXConfigStatus)configStatus error:(NSError *)error{
    self.phoneInfo.config_type = self.configType == AUXDeviceConfigTypeGizDeviceAirLink ? AUXDeviceConfigTypeGizDevice : self.configType;
    if (error) {
        self.phoneInfo.connect_tag = error.userInfo[NSLocalizedDescriptionKey];
    }
    self.phoneInfo.device_type = self.deviceModel.model;
    NSDictionary *configInfo = (NSDictionary *)[self.phoneInfo yy_modelToJSONObject];
    NSLog(@"configInfo---%@" , configInfo);
    if (configStatus != AUXConfigStatusOfBindSuccess) {
        [[AUXNetworkManager manager] reportConnectFaultWithInfo:configInfo completion:^(NSError * _Nullable error) {
        }];
    } else {
        [[AUXNetworkManager manager] reportConnectSuccessWithInfo:configInfo completion:^(NSError * _Nullable error) {
        }];
    }
}


#pragma mark - 跳转到失败页面
- (void)setFailViewController:(AUXConfigStatus)configStatus {
    AUXConfigFailViewController *failViewController = [AUXConfigFailViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    failViewController.configType = self.configType;
    failViewController.configStatus = configStatus;
    failViewController.ssid = self.ssid;
    failViewController.password = self.password;
    failViewController.deviceSN = self.deviceSN;
    failViewController.deviceModel = self.deviceModel;
    failViewController.isfromScan = self.isfromScan;
    if (configStatus == AUXConfigStatusOfBindFail && self.baindDevice) {
        failViewController.currentDevice = self.baindDevice;
    }
    if (self.alertView) {
        [self.alertView hidden];
    }
    NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    [viewControllers addObject:failViewController];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)succeedConfiguringDevice:(AUXACDevice *)acDevice deviceInfo:(AUXDeviceInfo *)deviceInfo error:(NSError *)error{
    
    if (self.alertView) {
        [self.alertView hidden];
    }
    AUXConfigSucceedViewController *configSucceedViewController = [AUXConfigSucceedViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    configSucceedViewController.isfromScan = self.isfromScan;
    configSucceedViewController.configType = self.configType;
    configSucceedViewController.deviceInfo = deviceInfo;
    [self.navigationController pushViewController:configSucceedViewController animated:YES];
}

#pragma mark - 懒加载
- (AUXPhoneInfo *)phoneInfo {
    if (!_phoneInfo) {
        _phoneInfo = [[AUXPhoneInfo alloc]init];
    }
    return _phoneInfo;
}

#pragma mark - Timer method

- (void)configureTimeout {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    NSLog(@"配置界面 配置设备超时");
    self.configureTimer = nil;
    [self failToConfigureDevice:nil];
}

- (void)discoverDeviceTimeout {
    NSLog(@"配置界面 搜索设备超时");
    self.discoverTimer = nil;
    [self failToConfigureDevice:nil];
}

#pragma mark - AUXACNetworkProtocol

#pragma mark  配网请求
- (void)auxACNetworkDidSetDeviceOnboarding:(NSError *)result success:(BOOL)success mac:(NSString *)mac device:(AUXACDevice *)device withType:(AUXACNetworkDeviceWifiType)type {
    if (!self.configureTimer) {
        NSLog(@"配置已超时，忽略回调...");
        return;
    }
    [self.configureTimer invalidate];
    self.configureTimer = nil;

    if (success) {
        if (!mac || mac.length == 0) {
            NSLog(@"mac 为空，当作配置失败");
            [self failToConfigureDevice:result];
            return;
        }
        if ([mac containsString:@":"]) {
            self.currentMac = mac;
            AUXUser *user = [AUXUser defaultUser];
            self.discoverTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(discoverDeviceTimeout) userInfo:nil repeats:NO];
            [[AUXACNetwork sharedInstance] getBoundDevicesWithUid:user.uid token:user.token type:AUXACNetworkDeviceWifiTypeAll];
        } else {
            
            if (device) {
                [self bindDeviceWithACDevice:device];
            } else if (!AUXWhtherNullString(mac)) {
                
                self.currentMac = mac;
                [self bindDeviceWithACDevice:nil];
            }
        }
    } else {
        switch (type) {
            case AUXACNetworkDeviceWifiTypeBL:
                NSLog(@"配置界面 设备配置失败（古北）: %@", result);
                break;
            default:
                NSLog(@"配置界面 设备配置失败（机智云）: %@", result);
                break;
        }
        [self failToConfigureDevice:result];
    }
}

- (void)auxACNetworkDidDiscoveredDeviceList:(NSArray *)deviceList success:(BOOL)success withError:(NSError *)error {
    if (self.refreshing) {
        self.refreshing = NO;
        NSString *newMac = [[[self.refreshDevice getMac] stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
        for (AUXACDevice *device in deviceList) {
            if ([newMac isEqualToString:[device getMac]]) {
                // 发现相同mac机智云设备，用机智云设备替换古北设备
                AUXDeviceInfo *deviceInfo = [[AUXDeviceInfo alloc] initWithACDevice:device model:self.deviceModel deviceSN:self.deviceSN];
                deviceInfo.deviceId = self.refreshDeviceInfo.deviceId;
                [self succeedConfiguringDevice:device deviceInfo:deviceInfo error:error];
                return;
            }
        }
        // 未发现相同mac机智云设备
        [self succeedConfiguringDevice:self.refreshDevice deviceInfo:self.refreshDeviceInfo error:error];
    } else {
        if (!success) {
            NSLog(@"配置界面 搜索设备列表失败: %@", error);
            return;
        }
        
        NSLog(@"配置界面 搜索设备列表: %@", deviceList);
        
        if (!self.discoverTimer) {
            NSLog(@"配置界面 搜索设备列表已超时，抛弃后续操作");
            return;
        }
        
        
        NSString *tempString = [NSString stringWithString:self.currentMac];
        if ([tempString containsString:@":"]) {
            tempString = [tempString stringByReplacingOccurrencesOfString:@":" withString:@""];
        }
        
        AUXACDevice *currentDevice;
        
        for (AUXACDevice *device in deviceList) {
            NSString *mac = [device getMac];
            
            NSLog(@"\t - mac: %@", mac);
            
            if (self.currentMac && mac && [self.currentMac isEqualToString:mac]) {
                currentDevice = device;
                break;
            }
            
            if (tempString && mac && [tempString isEqualToString:mac]) {
                currentDevice = device;
                break;
            }
        }
        
        if (currentDevice) {
            
            [self.discoverTimer invalidate];
            self.discoverTimer = nil;
            
            // 绑定设备 (SaaS)
            [self bindDeviceWithACDevice:currentDevice];
        }
    }
}

#pragma mark - 绑定设备的请求
- (void)bindDeviceWithACDevice:(AUXACDevice *)acDevice {
    
    AUXDeviceInfo *deviceInfo;
    if (acDevice) {
        
       self.baindDevice = acDevice;
       deviceInfo = [[AUXDeviceInfo alloc] initWithACDevice:acDevice model:self.deviceModel deviceSN:self.deviceSN];
    } else {
        deviceInfo = [[AUXDeviceInfo alloc] initWithACDevice:nil model:self.deviceModel deviceSN:self.deviceSN];
        deviceInfo.mac = self.currentMac;
        deviceInfo.terminalId = 1;
    }
    
    //    deviceInfo.passCode = acDevice.passcode;
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
    NSLog(@"deviceInfo--%@" , deviceInfo);
    [[AUXNetworkManager manager] bindDeviceWithDeviceInfo:deviceInfo completion:^(NSString * _Nullable deviceId, NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                deviceInfo.deviceId = deviceId;
                if (deviceInfo.source == AUXDeviceSourceBL) {
                    self.refreshing = YES;
                    self.refreshDevice = acDevice;
                    self.refreshDeviceInfo = deviceInfo;
                    
                    AUXUser *user = [AUXUser defaultUser];
                    // 重新发现设备，是否存在相同mac机智云模组设备配网成功
                    [AUXACNetwork.sharedInstance getBoundDevicesWithUid:user.uid token:user.token type:AUXACNetworkDeviceWifiTypeGiz];
                } else {
                    [self succeedConfiguringDevice:acDevice deviceInfo:deviceInfo error:error];
                }
                self.phoneInfo.connect_code = 1;
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
        };
    }];
}

#pragma mark  绑定设备失败
- (void)bindFail:(NSError *)error {
        [self reportInfowithStatus:AUXConfigStatusOfBindFail error:error];
        [self setFailViewController:AUXConfigStatusOfBindFail];
}

#pragma mark  获取当前控制器
- (UIViewController *)jsd_getCurrentViewController{
    UIViewController* currentViewController = [self jsd_getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                currentViewController = currentViewController.childViewControllers.lastObject;
                return currentViewController;
            } else {
                return currentViewController;
            }
        }
    }
    return currentViewController;
}

- (UIViewController *)jsd_getRootViewController{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}



@end

