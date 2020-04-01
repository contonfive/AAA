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

#import "AUXScanCodeViewController.h"
#import "AUXWifiPasswordViewController.h"
#import "AUXScanHelpViewController.h"
#import "AUXSNCodeSearchViewController.h"
#import "AUXHomepageTabBarController.h"
#import "AUXNetworkManager.h"
#import "AUXConstant.h"
#import "AUXConfiguration.h"
#import "NSString+AUXCustom.h"
#import "AUXControlGuideViewController.h"
#import "AUXArchiveTool.h"
#import <AVFoundation/AVFoundation.h>
#import "SGQRCode.h"
#import "UIColor+AUXCustom.h"
#import "AUXOnlyOneButtonAlertView.h"
#import "AUXAlertCustomView.h"
#import "AUXMobileInformationTool.h"
#import "AUXUserWebViewController.h"
#import "AUXElectronicSpecificationHistoryListModel+CoreDataClass.h"
#import "NSDate+AUXCustom.h"



@interface AUXScanCodeViewController ()<UIGestureRecognizerDelegate>
{
    SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *selectDeviceButton;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic ,strong) UILabel *handleLabel;

///记录开始的缩放比例
@property(nonatomic,assign)CGFloat beginGestureScale;
///最后的缩放比例
@property(nonatomic,assign)CGFloat effectiveScale;
@end

@implementation AUXScanCodeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.scanPurpose = AUXScanPurposeConfiguringDevice;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    /// 二维码开启方法
    [obtain startRunningWithBefore:nil completion:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"common_btn_back_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(backAtcion)];
    if (self.scanPurpose==AUXScanPurposeCompletingDeviceSN) {
        self.title = @"二维码/条码";
        self.helpButton.hidden = YES;
        self.selectDeviceButton.hidden = YES;
        self.handleLabel.hidden = YES;
        
    }else if (self.scanPurpose==AUXScanPurposeCompletingElectronicSpecification || self.scanPurpose==AUXScanPurposeCompletingElectronicSpecificationScan){
        self.title = @"扫码查询";
        self.helpButton.hidden = YES;
        self.selectDeviceButton.hidden = YES;
        self.handleLabel.hidden = YES;
    }else{
        self.helpButton.hidden = NO;
        self.selectDeviceButton.hidden = NO;
        self.title = @"扫码添加设备";
    }
}


- (void)backAtcion{
    [obtain setVideoScale:1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"333333"],NSForegroundColorAttributeName,nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:@"333333"]];
    
    [self.scanView removeTimer];
    [self removeFlashlightBtn];
    [obtain stopRunning];
}

- (void)dealloc {
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    obtain = [SGQRCodeObtain QRCodeObtain];
    [self setupQRCodeScan];
    [self.view addSubview:self.scanView];
    [self.scanView addSubview:self.promptLabel];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.selectDeviceButton];
    [self.scanView addSubview:self.helpButton];
    _effectiveScale = 1;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
}

#pragma mark 手动扫描区域缩放事件
- (void)pinchDetected:(UIPinchGestureRecognizer*)recogniser
{
    self.effectiveScale = self.beginGestureScale * recogniser.scale;
    if (self.effectiveScale < 1.0){
        self.effectiveScale = 1.0;
    }
    [obtain setVideoScale:self.effectiveScale];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

#pragma mark    设置扫描二维码
- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.sampleBufferDelegate = YES;
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    @weakify(self);
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        @strongify(self);
        
        [obtain stopRunning];
        [self dealWithScanContent:result];
    }];
    [obtain setBlockWithQRCodeObtainScanBrightness:^(SGQRCodeObtain *obtain, CGFloat brightness) {
        if (brightness < - 1) {
            [weakSelf.view addSubview:weakSelf.flashlightBtn];
        } else {
            if (weakSelf.isSelectedFlashlightBtn == NO) {
                [weakSelf removeFlashlightBtn];
            }
        }
    }];
}

#pragma mark  相册按钮点击事件
- (IBAction)rightBarButtonItenAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    if (![self isopencameraAndphotoalbum]) {
        [self alertWithMessage:@"非常抱歉，同意相机权限才能正常使用相册功能" confirmTitle:@"去设置" confirmBlock:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        } cancelTitle:@"取消" cancelBlock:nil];
        return;
        return;
    }
    
    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        [weakSelf.view addSubview:weakSelf.scanView];
    }];
    @weakify(self);
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        @strongify(self);
        [obtain stopRunning];
        [self dealWithScanContent:result];
    }];
}

#pragma mark  懒加载扫描按钮
- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.8 * self.view.frame.size.height)];
        _scanView.cornerColor = [UIColor colorWithHexString:@"3A9AFF"];
    }
    return _scanView;
}

#pragma mark  移除扫描界面
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

#pragma mark  懒加载创建提示label
- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.62 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        
        NSString *phoneType = [AUXMobileInformationTool deviceType];
        if ([phoneType isEqualToString:@"iPhone X"]||[phoneType isEqualToString:@"iPhone XR"]||[phoneType isEqualToString:@"iPhone XS"]||[phoneType isEqualToString:@"iPhone XS Max"]) {
            promptLabelY = 0.6 * self.view.frame.size.height;
        }else{
            promptLabelY = 0.62 * self.view.frame.size.height;
        }
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor colorWithHexString:@"3A9AFF"] colorWithAlphaComponent:0.6];
        if (self.scanPurpose==AUXScanPurposeCompletingDeviceSN) {
            _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
        }else{
            _promptLabel.text = @"请将机型二维码/条码放入框内, 即可自动扫描";
        }

    }
    return _promptLabel;
}


#pragma mark  懒加载创建下面的view
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanView.frame))];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

#pragma mark - - - 闪光灯按钮
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat flashlightBtnW = 180;
        CGFloat flashlightBtnH = 30;
        CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
        CGFloat flashlightBtnY = 0.53 * self.view.frame.size.height;
        
        
        NSString *phoneType = [AUXMobileInformationTool deviceType];
        if ([phoneType isEqualToString:@"iPhone X"]||[phoneType isEqualToString:@"iPhone XR"]||[phoneType isEqualToString:@"iPhone XS"]||[phoneType isEqualToString:@"iPhone XS Max"]) {
            flashlightBtnY = 0.5 * self.view.frame.size.height;
            
        }else{
            flashlightBtnY = 0.53 * self.view.frame.size.height;
        }
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
        [_flashlightBtn setImage:[UIImage imageNamed:@"scan_icon_light"] forState:UIControlStateNormal];
        [_flashlightBtn setTitle:@"轻触开灯" forState:UIControlStateNormal];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
        _flashlightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _flashlightBtn;
}

#pragma mark - - - 闪光灯按钮
- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [obtain openFlashlight];
        [_flashlightBtn setTitle:@"轻触关灯" forState:UIControlStateNormal];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [_flashlightBtn setTitle:@"轻触开灯" forState:UIControlStateNormal];
        [self removeFlashlightBtn];
    }
}

#pragma mark - - - 移除灯光按钮
- (void)removeFlashlightBtn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->obtain closeFlashlight];
        self.isSelectedFlashlightBtn = NO;
        self.flashlightBtn.selected = NO;
        [self.flashlightBtn removeFromSuperview];
    });
}

#pragma mark  懒加载创建帮助按钮
-(UIButton *)helpButton{
    if (!_helpButton) {
        _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat helpButtonY = 0.60 * self.view.frame.size.height+55*SCALEH;
        CGFloat helpButtonW = self.view.frame.size.width-80*SCALEH;
        CGFloat helpButtonX = 0.5 * (self.view.frame.size.width - helpButtonW);
        _helpButton.frame = CGRectMake(helpButtonX, helpButtonY, helpButtonW, 20*SCALEH);
        _helpButton.titleLabel.font = [UIFont systemFontOfSize:FontSize(14)];
        _helpButton.titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        [_helpButton setImage:[UIImage imageNamed:@"scan_icon_sn"] forState:UIControlStateNormal];
        [_helpButton setTitle:@" 机型二维码在哪里？" forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(helpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _helpButton;
}

#pragma mark  帮助按钮的点击事
-(void)helpButtonAction{
    AUXScanHelpViewController *helpViewController = [AUXScanHelpViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    [self.navigationController pushViewController:helpViewController animated:YES];
}

#pragma mark  懒加载创建手动选择按钮
-(UIButton *)selectDeviceButton{
    if (!_selectDeviceButton) {
        CGFloat selectDeviceButtonY = 0.65 * self.view.frame.size.height+130*SCALEH;
        CGFloat selectDeviceButtonW = 44*SCALEH;
        CGFloat selectDeviceButtonX = 0.5 * (self.view.frame.size.width - selectDeviceButtonW);
        _selectDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectDeviceButton.frame = CGRectMake(selectDeviceButtonX, selectDeviceButtonY,selectDeviceButtonW,selectDeviceButtonW);
        [_selectDeviceButton setImage:[UIImage imageNamed:@"scan_icon_hand"] forState:UIControlStateNormal];
        [_selectDeviceButton addTarget:self action:@selector(selectDeviceButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.handleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _selectDeviceButton.frame.origin.y+54*SCALEH, kScreenWidth, 20)];
        self.handleLabel.text = @"手动选择型号";
        self.handleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        self.handleLabel.font = [UIFont systemFontOfSize:FontSize(14)];
        self.handleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.handleLabel];
    }
    return _selectDeviceButton;
}

#pragma mark  手动选择按钮点击事件
-(void)selectDeviceButtonAction{
    AUXSNCodeSearchViewController *searchViewControoler = [AUXSNCodeSearchViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    [self.navigationController pushViewController:searchViewControoler animated:YES];
}


#pragma mark - 扫描内容解析
- (void)dealWithScanContent:(NSString *)content {
    if (!content || content.length == 0) {
        
        [self showErrorViewWithMessage:@"暂未识别有效信息"];
        [self->obtain startRunningWithBefore:nil completion:nil];
        
        return;
    }
    
    switch (self.scanPurpose) {
        case AUXScanPurposeCompletingDeviceSN: {
            
            NSString *result = nil;
            
            if ([content containsString:@"http"] && [content containsString:@"&sn="]) {
                NSArray *deviceSnArray = [content componentsSeparatedByString:@"&sn="];
                result = deviceSnArray.lastObject;
            } else {
                result = content;
            }
            
            if ([self deviceSnRight:result]) {
                if (self.didScanCodeBlock) {
                    self.didScanCodeBlock(result);
                }
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self->obtain startRunningWithBefore:nil completion:nil];
                [self showToastshortWithmessageinCenter:@"请扫描正确的SN码"];
            }
            
        }
            break;
        case AUXScanPurposeCompletingElectronicSpecification:
        case AUXScanPurposeCompletingElectronicSpecificationScan:{
            //这里是扫描电子说明书的结果
            if ([self isNumberWithStr:content]||([content containsString:@"auxgroup.com"] && [content containsString:@"&sn="] && [content containsString:@"model_type="])||([content containsString:@"el.bbqk.com"]&&[content containsString:@"html"])) {
               [self getElectronicSpecificationWithStr:content];
            }else{
                [self->obtain startRunningWithBefore:nil completion:nil];
                [self showToastshortWithmessageinCenter:@"无效二维码"];
            }
        }
            break;
        case AUXScanPurposeConfiguringDevice:
        default: {
            // 分享的二维码内容是base64加密的
            NSString *base64DecodedString = [content base64DecodedString];
            
            // 如果扫码内容以 "QR_AUX:" 开头，则判定为别人分享的二维码。
            if (base64DecodedString && [base64DecodedString hasPrefix:kAUXQRCodePrefix]) {
                [self acceptDeviceShareWithQRContent:content];
            } else {
                
                content = [content stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
                
                NSString *result = nil;
                
                if ([content containsString:@"http"] && [content containsString:@"&sn="]) {
                    NSArray *deviceSnArray = [content componentsSeparatedByString:@"&sn="];
                    result = deviceSnArray.lastObject;
                } else {
                    result = content;
                }
                
                if ([self deviceSnRight:result]) {
                    [self getDeviceModelWithSN:result];
                } else {
                    [AUXOnlyOneButtonAlertView alertViewtitle:@"请扫描正确的二维码" buttonTitle:@"重试" confirm:^{
                        [self->obtain startRunningWithBefore:nil completion:nil];
                    }];
                }
            }
        }
            break;
    }
}

- (BOOL)isNumberWithStr:(NSString*)str{
    NSString *regularExpression = @"^[0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpression];
    return [predicate evaluateWithObject:str];
}

- (BOOL)deviceSnRight:(NSString *)sn {
    
    NSString *regularExpression = @"^[A-Za-z0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpression];
    return [predicate evaluateWithObject:sn];
}

#pragma mark 获取设备型号  （根据扫描的SN码获取设备型号以及信息）
- (void)getDeviceModelWithSN:(NSString *)deviceSN {
    //stringByTrimmingCharactersInSet  可以去除字符串的前后空格（注意只是前后哦）或是里面的特殊符号
    deviceSN = [deviceSN stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if ([AUXConfiguration sharedInstance].deviceModelDictionary[deviceSN]) {//
        AUXDeviceModel *deviceModel = [AUXConfiguration sharedInstance].deviceModelDictionary[deviceSN];
        [self pushConfigGuideViewControllerWithModel:deviceModel deviceSN:deviceSN];
    } else {
        [self showLoadingHUD];
        [[AUXNetworkManager manager] getDeviceModelWithSN:deviceSN completion:^(AUXDeviceModel * _Nullable deviceModel, NSError * _Nonnull error) {
            [self hideLoadingHUD];
            switch (error.code) {
                case AUXNetworkErrorNone:
                    [self pushConfigGuideViewControllerWithModel:deviceModel deviceSN:deviceSN];
                    break;
                case AUXNetworkErrorAccountCacheExpired:
                    [self alertAccountCacheExpiredMessage];
                    break;
                case AUXNetworkErrorADoesNotsupport:
                {
                    [AUXOnlyOneButtonAlertView alertViewtitle:error.userInfo[NSLocalizedDescriptionKey] buttonTitle:@"重试" confirm:^{
                        [self->obtain startRunningWithBefore:nil completion:nil];
                    }];
                }
                    
                    break;
                default: {
                    [self showToastshortWitherror:error];
                    [self->obtain startRunningWithBefore:nil completion:nil];
                }
                    break;
            }
        }];
    }
}

#pragma mark 扫描别人分享的二维码绑定设备
- (void)acceptDeviceShareWithQRContent:(NSString *)qrContent {
      @weakify(self);
    [[AUXNetworkManager manager] acceptDeviceShareWithQRContent:qrContent completion:^(NSError * _Nonnull error) {
          @strongify(self);
        switch (error.code) {
            case AUXNetworkErrorNone:{
                [self showSuccess:@"绑定设备成功" completion:^{
                  
                    [self popToDeviceListViewController];
                }];
            }
                break;
            case AUXNetworkErrorAccountCacheExpired:{
                [self alertAccountCacheExpiredMessage];
                
            }
                break;
            case AUXNetworkErrorShareAlreadyAccepted:{
                [AUXOnlyOneButtonAlertView alertViewtitle:@"不能重复分享" buttonTitle:@"重试" confirm:^{
                    [self->obtain startRunningWithBefore:nil completion:nil];
                }];
            }
                break;
            default:{
                NSString *message;
                if (error) {
                    message = [AUXNetworkManager getErrorMessageWithCode:error.code];
                }
                if (!message && error.userInfo[NSLocalizedDescriptionKey]) {
                    message = error.userInfo[NSLocalizedDescriptionKey];
                }
                [AUXOnlyOneButtonAlertView alertViewtitle:message buttonTitle:@"重试" confirm:^{
                    [self->obtain startRunningWithBefore:nil completion:nil];
                }];
            }
                break;
        }
    }];
}

#pragma mark   跳转到配置指引界面
- (void)pushConfigGuideViewControllerWithModel:(AUXDeviceModel *)deviceModel deviceSN:(NSString *)deviceSN {
    AUXDeviceConfigType configType = (deviceModel.deviceType == 0 ? AUXDeviceConfigTypeBLDevice : AUXDeviceConfigTypeGizDeviceAirLink);
    AUXWifiPasswordViewController *wifiPasswordViewController = [AUXWifiPasswordViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    wifiPasswordViewController.configType = configType;
    wifiPasswordViewController.deviceSN = deviceSN;
    wifiPasswordViewController.deviceModel = deviceModel;
    wifiPasswordViewController.isfromScan = YES;
    [self.navigationController pushViewController:wifiPasswordViewController animated:YES];
}

- (void)popToDeviceListViewController {
    if (self.tabBarController.selectedIndex == kAUXTabDeviceSelected) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        AUXHomepageTabBarController *homepageTabBarController = (AUXHomepageTabBarController *)self.tabBarController;
        [homepageTabBarController setSelectedIndex:kAUXTabDeviceSelected animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - QMUINavigationControllerDelegate

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}


- (void)getElectronicSpecificationWithStr:(NSString*)tagStr{
    NSDictionary *dic = @{@"tag":tagStr};
    @weakify(self);
    [self showLoadingHUD];
    [[AUXNetworkManager manager] getOneElectronicUrlByparameters:dic completion:^(NSDictionary * _Nonnull resultDic, NSError * _Nonnull error) {
        @strongify(self);
        [self hideLoadingHUD];
        if (error.code == -1009) {
            [self showToastshortWithmessageinCenter:error.localizedDescription];
            return ;
        }
        if ([resultDic[@"code"] integerValue]==AUXNetworkErrorNone && error==nil) {
            [self pushViewControllerWithUrlStr:resultDic[@"data"][@"instruction"]];
            NSArray *modelArray = [AUXElectronicSpecificationHistoryListModel MR_findAll];
            AUXElectronicSpecificationHistoryListModel *mode1 = [AUXElectronicSpecificationHistoryListModel MR_findFirstByAttribute:@"deviceType" withValue:resultDic[@"data"][@"deviceType"]];
            if (![modelArray containsObject:mode1]) {
                AUXElectronicSpecificationHistoryListModel *electronicSpecificationHistoryListModel = [AUXElectronicSpecificationHistoryListModel MR_createEntity];
                electronicSpecificationHistoryListModel.deviceType = resultDic[@"data"][@"deviceType"];
                electronicSpecificationHistoryListModel.date = [NSDate cNowTimestamp];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }else{
                // 获取一个上下文对象
                NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
                // 在当前上下文环境中创建一个新的Employee对象
                mode1.date  =  [NSDate cNowTimestamp];
                // 保存修改到当前上下文中
                [defaultContext MR_saveToPersistentStoreAndWait];
            }
        }else{
             [self->obtain startRunningWithBefore:nil completion:nil];
            [self showToastshortWithmessageinCenter:resultDic[@"message"]];
        }
    }];
}

- (void)pushViewControllerWithUrlStr:(NSString*)urlstr{
    AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    userWebViewController.isformElectronicSpecification = YES;
    userWebViewController.isformElectronicSpecificationScan = YES;
    NSString *newStr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    userWebViewController.loadUrl = newStr;
    [self.navigationController pushViewController:userWebViewController animated:YES];
}
@end





