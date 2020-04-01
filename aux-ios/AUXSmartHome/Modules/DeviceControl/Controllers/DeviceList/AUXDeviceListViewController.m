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

#import "AUXDeviceListViewController.h"
#import "AUXSubdeviceListViewController.h"
#import "AUXScanCodeViewController.h"
#import "AUXConfigGuideViewController.h"
#import "AUXDeviceControlViewController.h"
#import "AUXAudioControlViewController.h"
#import "AUXControlGuideViewController.h"
#import "AUXGatewaySubDeviceViewController.h"

#import "AUXAddressView.h"
#import "AUXACDeviceGirdCollectionViewCell.h"
#import "AUXGatewayDeviceGirdCollectionViewCell.h"
#import "AUXACDeviceListCollectionViewCell.h"
#import "AUXGatewayDeviceListCollectionViewCell.h"
#import "AUXNoDeviceCollectionViewCell.h"

#import "AUXAMapWeather.h"
#import "AUXScrollViewFlowLayout.h"

#import "AUXDeviceCollectionHeaderView.h"

#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXVersionTool.h"
#import "AUXLocateTool.h"
#import "AUXTouchRemoteOrShareLink.h"

#import "AUXDeviceListViewModel.h"
#import "AUXAdvertisementViewController.h"
#import "AUXAdvertisingCache.h"
#import "AUXRemoteNotificationModel.h"

#import "UIView+AUXCornerRadius.h"
#import "UIColor+AUXCustom.h"
#import "NSDate+AUXCustom.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

#import "AUXAlertCustomView.h"

#import "AUXVersionAlertView.h"

// 用来控制显示引导页是否显示 小于 guideIndex 需要显示引导页
static const NSInteger guideIndex = 1;
@interface AUXDeviceListViewController () <UICollectionViewDelegate, UICollectionViewDataSource ,  AUXDeviceListViewModelDelegate , UIGestureRecognizerDelegate , AUXLocateToolDeletate , AMapSearchDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *deviceCollectionView;
@property (weak, nonatomic) IBOutlet UIView *advertisingBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceCollectionViewBottom;
@property (weak, nonatomic) IBOutlet UIImageView *advertisingImageView;
@property (weak, nonatomic) IBOutlet UIButton *advertisingDeleteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

// 高德地图(用来获取天气)
@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) AMapWeatherSearchRequest *request;

@property (nonatomic, strong, readonly) NSArray<AUXDeviceInfo *> *deviceInfoArray;    // 设备列表 
@property (nonatomic, strong, readonly) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;  // 设备字典 (key为 deviceId)

@property (nonatomic,assign) BOOL deleteAdvertising;

@property (nonatomic,strong) UICollectionViewFlowLayout *gridFlowLayout;
@property (nonatomic,strong) UICollectionViewFlowLayout *listFlowLayout;
@property (nonatomic,strong) UICollectionViewFlowLayout *noDeviceFlowLayout;

@property (nonatomic,strong) AUXDeviceListViewModel *deviceListViewModel;

@property (nonatomic,strong) AUXDeviceCollectionHeaderView *headerView;

@property (nonatomic,strong) AUXLaunchAdModel *currentModel;

@property (nonatomic,weak) AUXDeviceControlViewController *deviceControllerViewController;
@property (nonatomic,strong) NSArray *selectedDeviceinfoArray;

@property (nonatomic,strong) AMapLocalWeatherLive *live;
@end

@implementation AUXDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAMap];
    
    [self addNotifications];
    
    [self setDeviceViewModel];
    
    [self whtherShowAdvertismentView];
    
    [self checkAppVersion];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.backGroundImageView.userInteractionEnabled = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    self.selectedDeviceinfoArray = nil;
    
    [self whtherShowAdvertismentView];
    [self locateTool];
    
    [self whtherShowGuid];
    
    [self whtherSaveCurrentVersion];
    
    [self setDeviceListType];
    
    [self setBackGroundImage];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.whtherRequestDeviceList) {
        [self.deviceListViewModel requestDeviceList];
    }
    
    [self requestCurrentAdvertisin];
    
    [self reloadCollectionView];
    

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.whtherRequestDeviceList = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AUXACNetwork sharedInstance].delegates removeObject:self];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self collectionRegisterCell];
    
    [self reloadCollectionView];
    
    [self addAvertisingView];
}

#pragma mark private atcion
- (void)addNotifications {
    // 通知：用户退出登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogoutNotification:) name:AUXUserDidLogoutNotification object:nil];
    //accesstoken 更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenUpdateNotification) name:AUXAccountCacheDidUpdateNotification object:nil];
    //设备解绑
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidUnbindNotification:) name:AUXDeviceDidUnbindNotification object:nil];
}

- (void)setDeviceViewModel {
    
    AUXDeviceListViewModel *deviceViewModel = [[AUXDeviceListViewModel alloc]init];
    deviceViewModel.delegate = self;
    self.deviceListViewModel = deviceViewModel;
}

- (void)collectionRegisterCell {
    
    [self.deviceCollectionView registerNib:[UINib nibWithNibName:@"AUXNoDeviceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXNoDeviceCollectionViewCell"];
    
    [self.deviceCollectionView registerNib:[UINib nibWithNibName:@"AUXGatewayDeviceListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXGatewayDeviceListCollectionViewCell"];
    
    [self.deviceCollectionView registerNib:[UINib nibWithNibName:@"AUXACDeviceListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXACDeviceListCollectionViewCell"];
    
    [self.deviceCollectionView registerNib:[UINib nibWithNibName:@"AUXACDeviceGirdCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXACDeviceGirdCollectionViewCell"];
    
    [self.deviceCollectionView registerNib:[UINib nibWithNibName:@"AUXGatewayDeviceGirdCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AUXGatewayDeviceGirdCollectionViewCell"];

}

- (void)setDeviceListType {
    self.currentDeviceListType = [AUXArchiveTool readDeviceListType];
    [self setCollectionFlowlayout:self.currentDeviceListType];
}

- (void)addAvertisingView {
    CGFloat width = self.advertisingBackView.frame.size.width;
    CGFloat height = self.advertisingBackView.frame.size.height;
    
    if (!self.deleteAdvertising) {
        self.deviceCollectionViewBottom.constant = height + 20;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view layoutIfNeeded];
        });
    }
    
    self.advertisingBackView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advertisingAtcion)];
    [self.advertisingBackView addGestureRecognizer:tap];
    
    self.advertisingBackView.layer.cornerRadius = 6;
    self.advertisingBackView.layer.masksToBounds = YES;
}

- (void)removeAdvertisingmentView {
    self.deleteAdvertising = YES;
    [self.advertisingBackView removeFromSuperview];
    [UIView animateWithDuration:1.0 animations:^{
        self.deviceCollectionViewBottom.constant = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view layoutIfNeeded];
        });
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setBackGroundImage {
    NSString *backImageName = [MyDefaults objectForKey:kSelectHomepageBackImageName];
    if (backImageName.length!=0) {
        self.backGroundImageView.image = [[UIImage imageNamed:backImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        self.backGroundImageView.image = [[UIImage imageNamed:@"index_bg01"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

#pragma mark 判断是否显示更新弹框
- (void)checkAppVersion {
    [AUXVersionTool getAppStoreVersionWithComplete:^(NSString *appStoreVersion, NSString *url) {
        if ([AUXVersionTool.sharedInstance shouldUpdateWithAppStoreVersion:appStoreVersion]) {
            NSLog(@"%@=====%@",[MyDefaults objectForKey:kIgnorAppVersion],APP_VERSION);
            if (![[MyDefaults objectForKey:kIgnorAppVersion] isEqualToString:APP_VERSION]) {
                [AUXVersionAlertView versionAlertViewWithVersion:appStoreVersion cancelBlock:^{
                } confirmBlock:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }];
            }
        }
    }];
}

#pragma mark 是否显示引导页
- (void)whtherShowGuid {
    
    if ([AUXArchiveTool shouldShowGuidPage:guideIndex]) {
        
        AUXAdvertisementViewController *advertisementViewController = [AUXAdvertisementViewController instantiateFromStoryboard:kAUXStoryboardNameHomepage];
        advertisementViewController.hidesBottomBarWhenPushed = YES;

        advertisementViewController.advertismentViewControllerShowBlock = ^{
            [AUXArchiveTool hasShowGuidPage:guideIndex];
        };
        
        [self.navigationController pushViewController:advertisementViewController animated:NO];
    }
}

#pragma mark 版本升级后保存当前版本到本地
- (void)whtherSaveCurrentVersion {
    NSString *versionString = APP_VERSION;
    
    if ([AUXArchiveTool shouldShowAdvertisementForVersion:versionString]) {
        [AUXArchiveTool hasShownAdvertisementForVersion:versionString];
    }
}

#pragma mark 是否显示底部广告
- (void)whtherShowAdvertismentView {
    [AUXAdvertisingCache getCurrentAdvertisinDataCompletion:^(BOOL result, AUXLaunchAdModel *model) {
        
        if (AUXWhtherNullString(model.imageBannerURLString)) {
            [self removeAdvertisingmentView];
            return ;
        }
        
        if (result) {
            self.currentModel = model;
            
            [self.advertisingImageView sd_setImageWithURL:[NSURL URLWithString:self.currentModel.imageBannerURLString] placeholderImage:[UIImage new]];
            
        } else {
            [self removeAdvertisingmentView];
        }
    }];
}

#pragma mark 刷新列表
- (void)reloadCollectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceCollectionView reloadData];
    });
    
    if (self.deviceControllerViewController && self.selectedDeviceinfoArray) {
        [self.deviceControllerViewController reloadDeviceArray:self.selectedDeviceinfoArray];
    }
}

/// 如果用户未登录，则跳转登录
- (BOOL)gotoLoginViewController {
    
    if (![AUXUser isLogin]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
        return YES;
    }
    
    return NO;
}

#pragma mark 通过高德地图获取天气
- (void)locateTool {
    
    [AUXLocateTool defaultTool].delegate = self;
    
    [[AUXLocateTool defaultTool] requestLocation];

}

- (void)setAMap {
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

- (void)locateToolDidUpdateLocation:(AUXLocateTool *)locateTool {
    
    [self requestWeather:locateTool.city];
}

- (void)requestWeather:(NSString *)city {
    self.request.city = city;
    [self.search AMapWeatherSearch:self.request];
}

- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response {
    //解析response获取天气信息，具体解析见 Demo
    AMapLocalWeatherLive *live = [response.lives firstObject];
    
    if (live) {
        self.live = live;
        [self reloadCollectionView];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

#pragma mark - 点击微信分享的内容绑定设备
- (void)acceptDeviceShareWithQRContent:(NSString *)qrContent {
    
    [[AUXNetworkManager manager] acceptDeviceShareWithClipbordShareData:qrContent completion:^(NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self.deviceListViewModel requestDeviceList];
                [self showSuccess:@"绑定设备成功" completion:nil];
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:{
                NSString *faultMessage = [AUXNetworkManager getErrorMessageWithCode:error.code];
                if (!faultMessage) {
                    faultMessage = @"绑定设备失败";
                }
                
                [self alertWithMessage:faultMessage confirmTitle:@"重试" confirmBlock:^{
                    [self acceptDeviceShareWithQRContent:qrContent];
                } cancelTitle:kAUXLocalizedString(@"Cancle") cancelBlock:nil];
            }
                break;
        }
    }];
    
}

#pragma mark 根据widget点击的设备进入设备控制页面
- (void)pushToDeviceControllerWithDeviceId:(NSString *)deviceID orDeviceMac:(NSString *)deviceMac {
    
    if (AUXWhtherNullString(deviceID) && AUXWhtherNullString(deviceMac)) {
        return ;
    }
    
    if (self.deviceInfoArray.count > 0) {
        [self.deviceInfoArray enumerateObjectsUsingBlock:^(AUXDeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([deviceID isEqualToString:obj.deviceId] || [deviceMac isEqualToString:obj.mac]) {
                
                obj.addressArray = @[kAUXACDeviceAddress];
                AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                self.deviceControllerViewController = deviceControllerViewController;
                deviceControllerViewController.controlType = AUXDeviceControlTypeDevice;
                deviceControllerViewController.deviceInfoArray = @[obj];
                self.selectedDeviceinfoArray = @[obj];
                [self pushViewController:deviceControllerViewController];
                
                return ;
            }
        }];
    } else {
        
        [self showFailure:kAUXLocalizedString(@"DeviceNotReadyPleaseWait") completion:^{
            [self pushToDeviceControllerWithDeviceId:deviceID orDeviceMac:deviceMac];
        }];
    }
}

#pragma mark - Actions

- (IBAction)deleteAdvertisingAtcion:(id)sender {
    [self removeAdvertisingmentView];
}

- (void)advertisingAtcion {
    //暂时设置为 虚拟体验入口
//    AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
//    [self pushViewController:deviceControllerViewController];
    
    if (!self.currentModel.isCanClick) {
        return ;
    }
    
    NSTimeInterval nowTimeInterval = [NSDate cNowTimestamp].longLongValue * 1000;
    NSTimeInterval startTimeInterval = self.currentModel.clickStartTime;
    NSTimeInterval endTimeInterval = self.currentModel.clickEndTime;
    
    if (nowTimeInterval < startTimeInterval || nowTimeInterval >= endTimeInterval || startTimeInterval >= endTimeInterval) {
        return ;
    }
    
    NSDictionary *dict = [self.currentModel yy_modelToJSONObject];
    
    AUXRemoteNotificationModel *contentModel = [[AUXRemoteNotificationModel alloc]init];
    [contentModel yy_modelSetWithDictionary:dict];
    
    [[AUXTouchRemoteOrShareLink sharedInstance] touchAdvertisingWithRemoteNotificationModel:contentModel];
}

- (void)pushViewController:(UIViewController *)viewController {
    if (!viewController) {
        return ;
    }
    
    viewController.hidesBottomBarWhenPushed = YES;
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers addObject:viewController];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark   语音控制
- (IBAction)actionVoiceControl:(id)sender {
    
    if ([self gotoLoginViewController]) {
        return;
    }

    AUXAudioControlViewController *audioControlViewController = [AUXAudioControlViewController instantiateFromStoryboard:kAUXStoryboardNameAudio];
    [self pushViewController:audioControlViewController];
}

- (IBAction)addDevice:(id)sender {
    [self actionAddDevice];
}

/// 添加设备
- (void)actionAddDevice {
    
    // 如果用户未登录，则跳转登录
    if ([self gotoLoginViewController]) {
        return;
    }

        AUXScanCodeViewController *scanCodeViewController = [AUXScanCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
        [self pushViewController:scanCodeViewController];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.deviceInfoArray.count == 0 ? 1 : self.deviceInfoArray.count;
}

//设置sectionHeader | sectionFoot
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        [self.headerView whtherAllowLocalRight];
        
        self.headerView.live = self.live;
        
        return self.headerView;
    } else {
        return nil;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.deviceInfoArray.count > 0) {
        
        NSInteger item = indexPath.item;
        AUXDeviceCollectionViewCell *cell;
        
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray[item];
        
        // 单元机设备
        if (deviceInfo.suitType == AUXDeviceSuitTypeAC) {
            if (self.currentDeviceListType == AUXDeviceListTypeOfGrid) {
                cell = [self collectionView:collectionView acGridCellForItemAtIndexPath:indexPath];
            } else {
                cell = [self collectionView:collectionView acListCellForItemAtIndexPath:indexPath];
            }
        } else {
            if (self.currentDeviceListType == AUXDeviceListTypeOfGrid) {
                cell = [self collectionView:collectionView gatewayGridCellForItemAtIndexPath:indexPath];
            } else {
                cell = [self collectionView:collectionView gatewayListCellForItemAtIndexPath:indexPath];
            }
        }
        
        if (self.currentDeviceListType == AUXDeviceListTypeOfGrid) {
            cell.layer.masksToBounds = YES;
            cell.layer.cornerRadius = 3;
        } else {
            cell.layer.masksToBounds = YES;
            cell.layer.cornerRadius = 5;
        }
        
        cell.layer.borderColor = [UIColor colorWithHexString:@"EEEEEE"].CGColor;
        cell.layer.borderWidth = 1;
        
        if (deviceInfo) {
            cell.deviceInfo = deviceInfo;
        }
        
        @weakify(self);
        cell.sendControlError = ^(NSString *errorText) {
            @strongify(self);
            [self showErrorViewWithMessage:errorText];
            
            [self hideLoadingHUDWithText];
        };
        
        cell.showLoadingBlock = ^{
            @strongify(self);
            [self show];
        };
        
        cell.hideLoadingBlock = ^{
            @strongify(self);
            [self hidden];
        };
        
        cell.accountCacheExpiredBlock = ^{
            
        };
        
        return cell;
    } else {
        AUXNoDeviceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXNoDeviceCollectionViewCell" forIndexPath:indexPath];
        
        cell.layer.borderColor = [UIColor colorWithHexString:@"EAEAEA"].CGColor;
        cell.layer.borderWidth = 1;
        
        cell.addDeviceBlock = ^{
            [self actionAddDevice];
        };
        
        return cell;
    }
    
}

// 单元机设备 - 列表效果
- (AUXDeviceCollectionViewCell *)collectionView:(UICollectionView *)collectionView acListCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXACDeviceListCollectionViewCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXACDeviceListCollectionViewCell" forIndexPath:indexPath];
    deviceCell.currentDeviceListType = self.currentDeviceListType;
    return deviceCell;
}

// 单元机设备 - 宫格效果
- (AUXDeviceCollectionViewCell *)collectionView:(UICollectionView *)collectionView acGridCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUXACDeviceGirdCollectionViewCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXACDeviceGirdCollectionViewCell" forIndexPath:indexPath];
    deviceCell.currentDeviceListType = self.currentDeviceListType;
    return deviceCell;
}

// 多联机设备 - 列表效果
- (AUXDeviceCollectionViewCell *)collectionView:(UICollectionView *)collectionView gatewayListCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUXGatewayDeviceListCollectionViewCell *gatewayCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXGatewayDeviceListCollectionViewCell" forIndexPath:indexPath];
    gatewayCell.currentDeviceListType = self.currentDeviceListType;
    return gatewayCell;
}

// 多联机设备 - 宫格效果
- (AUXDeviceCollectionViewCell *)collectionView:(UICollectionView *)collectionView gatewayGridCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUXGatewayDeviceGirdCollectionViewCell *gatewayCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AUXGatewayDeviceGirdCollectionViewCell" forIndexPath:indexPath];
    gatewayCell.currentDeviceListType = self.currentDeviceListType;
    return gatewayCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.deviceInfoArray.count <= 0) {
        return ;
    }
    
    self.selectedDeviceinfoArray = nil;
    
    NSInteger item = indexPath.item;
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[item];
    AUXACDevice *device = self.deviceDictionary[deviceInfo.deviceId];
    deviceInfo.device = device;
    
    switch (deviceInfo.suitType) {
        case AUXDeviceSuitTypeAC: { // 单元机
            
            deviceInfo.addressArray = @[kAUXACDeviceAddress];
            
            self.currentDeviceId = deviceInfo.deviceId;
            AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
            self.deviceControllerViewController = deviceControllerViewController;
            deviceControllerViewController.controlType = AUXDeviceControlTypeDevice;
            deviceControllerViewController.deviceInfoArray = @[deviceInfo];
            self.selectedDeviceinfoArray = @[deviceInfo];
            [self pushViewController:deviceControllerViewController];
        }
            break;
            
        default: {  // 多联机
            // 设备离线，跳往控制页，展示离线
            if (!device || device.controlDic.allKeys.count == 0) {
                
                AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
                deviceControllerViewController.deviceInfoArray = @[deviceInfo];
                deviceControllerViewController.controlType = AUXDeviceControlTypeGateway;
                [self pushViewController:deviceControllerViewController];
                
                return;
            }
            
            AUXGatewaySubDeviceViewController *subdeviceListViewController = [AUXGatewaySubDeviceViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
            subdeviceListViewController.deviceInfo = deviceInfo;
            [self pushViewController:subdeviceListViewController];
        }
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.deviceInfoArray.count > 0) {
        if (self.currentDeviceListType  == AUXDeviceListTypeOfList) {
            return self.listFlowLayout.itemSize;
        } else {
            return self.gridFlowLayout.itemSize;
        }
    } else {
        return self.noDeviceFlowLayout.itemSize;
    }
}

- (void)hideLoadingHUDWithText {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hidden];
    });
}

#pragma mark AUXDeviceListViewModelDelegate
- (void)viewModelDelegateOfGetDeviceListStatus:(NSError *)error {
    [self reloadCollectionView];
}

- (void)viewModelDelegateOfRefrashDeviceStatus {
    [self reloadCollectionView];
}

- (void)viewModelDelegateOfShowLoading {
    [self show];
    kAUXWindowView.userInteractionEnabled = NO;
}

- (void)viewModelDelegateOfHideLoading {
    [self hidden];
    kAUXWindowView.userInteractionEnabled = YES;
}

- (void)viewModelDelegateOfError:(NSError *)error {
    if (![self.navigationController.visibleViewController isEqual:self]) {
        return;
    }
    if (self.tabBarController.selectedIndex != kAUXTabDeviceSelected) {
        return;
    }

    [self showErrorViewWithError:error defaultMessage:@"获取设备列表失败"];
}

- (void)viewModelDelegateOfMessage:(NSString *)message  {
    [self showToastshortWithmessageinCenter:message];
}


- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}


#pragma mark - 网络请求
- (void)requestCurrentAdvertisin {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AUXNetworkManager manager] getCurrentAdvertisingDataCompletion:^(AUXLaunchAdModel * _Nonnull model, NSError * _Nonnull error) {
            if (error.code == 200) {
                [AUXAdvertisingCache editAdvertisingData:model];
            }
        }];
    });
}

#pragma mark Notifications
/// 用户退出成功
- (void)userDidLogoutNotification:(NSNotification *)notification {
    [self reloadCollectionView];
}

- (void)accessTokenUpdateNotification {
    [self.deviceListViewModel requestDeviceList];
}

/// 设备解绑
- (void)deviceDidUnbindNotification:(NSNotification *)notification {
    
    AUXDeviceInfo *deviceInfo = (AUXDeviceInfo *)notification.object;
    [self removeDeviceInfo:deviceInfo];
}

/// 移除设备
- (void)removeDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    if (deviceInfo) {
        AUXUser *user = [AUXUser defaultUser];
        
        NSMutableArray<AUXDeviceInfo *> *deviceInfoArray = user.deviceInfoArray;
        NSMutableDictionary<NSString *, AUXACDevice *> *deviceDictionary = user.deviceDictionary;
        
        AUXACDevice *device = deviceDictionary[deviceInfo.deviceId];
        
        [device.delegates removeAllObjects];
        [[AUXACNetwork sharedInstance] unsubscribeDevice:device withType:device.deviceType];
        
       
        if ([deviceInfoArray containsObject:deviceInfo]) {
             [deviceInfoArray removeObject:deviceInfo];
            [deviceDictionary removeObjectForKey:deviceInfo.deviceId];
        }
        
        NSMutableArray *componentSelectedDevices = [[AUXArchiveTool readDataByNSFileManager] mutableCopy];
        BOOL result = NO;
        for (NSString *deviceId in componentSelectedDevices) {
            if ([deviceId isEqualToString:deviceInfo.deviceId]) {
                result = YES;
            }
        }
        if (result) {
            if ([componentSelectedDevices containsObject:deviceInfo.deviceId]) {
                [componentSelectedDevices removeObject:deviceInfo.deviceId];
                [AUXArchiveTool saveDataByNSFileManager:componentSelectedDevices];
            }
        }
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    if (!self.deviceListViewModel) {
        [self setDeviceViewModel];
    }
    
    if (self.whtherRequestDeviceList) {
        [self.deviceListViewModel requestDeviceList];
    }
}

#pragma mark - Getters

- (AMapWeatherSearchRequest *)request {
    if (!_request) {
        _request = [[AMapWeatherSearchRequest alloc] init];
        _request.type = AMapWeatherTypeLive;
    }
    return _request;
}

- (NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    
    return [AUXUser defaultUser].deviceInfoArray;
}

- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    
    return [AUXUser defaultUser].deviceDictionary;
}

- (AUXDeviceCollectionHeaderView *)headerView {
    if (!_headerView) {
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:0];
        _headerView = [self.deviceCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"deviceCollectionHeaderView" forIndexPath:indexPath];
    }
    return _headerView;
}

- (UICollectionViewFlowLayout *)listFlowLayout {
    if (!_listFlowLayout) {
        _listFlowLayout = (UICollectionViewFlowLayout *)self.deviceCollectionView.collectionViewLayout;
        CGFloat headerScale = 141.0 / 375.0;
        _listFlowLayout.headerReferenceSize = CGSizeMake(kAUXScreenWidth , kAUXScreenWidth * headerScale);
    }
    CGFloat cellWidth = kAUXScreenWidth * (kAUXScreenWidth - 18 * 2) / kAUXScreenWidth;
    CGFloat cellHeight = 110;
    
    _listFlowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
    _listFlowLayout.sectionInset = UIEdgeInsetsMake(0, 18, 0, 18);
    _listFlowLayout.minimumLineSpacing = 16;
    _listFlowLayout.minimumInteritemSpacing = 16;
    
    
    return _listFlowLayout;
}

- (UICollectionViewFlowLayout *)gridFlowLayout {
    if (!_gridFlowLayout) {
                                                                                                                                                                                                                                                                                                                                                            
        _gridFlowLayout = (UICollectionViewFlowLayout *)self.deviceCollectionView.collectionViewLayout;
        CGFloat headerScale = 141.0 / 375.0;
        _gridFlowLayout.headerReferenceSize = CGSizeMake(kAUXScreenWidth , kAUXScreenWidth * headerScale);
    }
    
    _gridFlowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    _gridFlowLayout.minimumLineSpacing = 16;
    _gridFlowLayout.minimumInteritemSpacing = 16;
    
    CGFloat cellWidth = kAUXScreenWidth * (kAUXScreenWidth - 20 * 2 - _gridFlowLayout.minimumLineSpacing) / 2 / kAUXScreenWidth;
    CGFloat cellHeight = 170;
    
    _gridFlowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
    
    return _gridFlowLayout;
}

- (UICollectionViewFlowLayout *)noDeviceFlowLayout {
    if (!_noDeviceFlowLayout) {
        
        _noDeviceFlowLayout = (UICollectionViewFlowLayout *)self.deviceCollectionView.collectionViewLayout;
        CGFloat headerScale = 141.0 / 375.0;
        _noDeviceFlowLayout.headerReferenceSize = CGSizeMake(kAUXScreenWidth , kAUXScreenWidth * headerScale);
    }
    
    CGFloat cellHeight = kAUXScreenHeight * 0.535;
    
    _noDeviceFlowLayout.itemSize = CGSizeMake(kAUXScreenWidth - 40, cellHeight);
    _noDeviceFlowLayout.sectionInset = UIEdgeInsetsMake(15, 20, 0, 20);
    
    return _noDeviceFlowLayout;
}

#pragma mark setter
- (void)setCurrentDeviceListType:(AUXDeviceListType)currentDeviceListType {
    _currentDeviceListType = currentDeviceListType;
    
    [AUXArchiveTool saveDeviceListType:_currentDeviceListType];
}

- (void)setCollectionFlowlayout:(AUXDeviceListType)devicelistType {
    
    if (devicelistType == AUXDeviceListTypeOfList) {
        
        [self.deviceCollectionView setCollectionViewLayout:self.listFlowLayout animated:YES];
        
    } else {
        [self.deviceCollectionView setCollectionViewLayout:self.gridFlowLayout animated:YES];
    }
    
}

- (void)show{
    MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    progressHUD.bezelView.color = [UIColor blackColor];
    progressHUD.contentColor = [UIColor whiteColor];
    [progressHUD showAnimated:YES];
}

- (void)hidden{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


@end
