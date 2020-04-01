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

#import "AUXDeviceControlViewController.h"
#import "AUXSchedulerListViewController.h"
#import "AUXSleepDIYListViewController.h"
#import "AUXDeviceInfoViewController.h"
#import "AUXLimitElectricityViewController.h"
#import "AUXPeakValleyViewController.h"
#import "AUXSmartPowerViewController.h"
#import "AUXElectricityConsumptionCurveViewController.h"
#import "AUXFaultListViewController.h"

#import "AUXDeviceControlHeaderView.h"
#import "AUXDeviceControlStatusTableViewCell.h"
#import "AUXDeviceControlChildTableViewCell.h"
#import "AUXDeviceControlFunctionListTableViewCell.h"
#import "AUXDeviceControlerSchedulerTableViewCell.h"
#import "AUXDeviceControlElectricityLimitTableViewCell.h"
#import "AUXDeviceFunctionSubtitleTableViewCell.h"
#import "AUXDeviceControlSleepDiyTableViewCell.h"
#import "AUXDeviceControlSmartElectricityTableViewCell.h"

#import "AUXButton.h"
#import "AUXModeAndSpeedView.h"

#import "AUXElectricityConsumptionCurveView.h"
#import "AUXControllGuidView.h"

#import "AUXDeviceFunctionItem.h"
#import "AUXDeviceSectionItem.h"
#import "AUXDeviceStatus.h"
#import "AUXSchedulerModel.h"
#import "AUXDeviceControlTask.h"

#import "UIColor+AUXCustom.h"
#import "UIView+AUXCustom.h"
#import "UIView+MIExtensions.h"
#import "UITableView+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"

#import "AUXDeviceControlViewModel.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "AUXSceneSetCenterControlViewController.h"
#import "AUXSceneCommonModel.h"

#import "AUXSceneAddNewViewController.h"




@interface AUXDeviceControlViewController () <UITableViewDelegate, UITableViewDataSource , AUXDeviceControlViewModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *offlineView;

// 设备开机时，显示的功能列表
@property (nonatomic, strong) NSArray<AUXDeviceFunctionItem *> *onFunctionList;
@property (nonatomic, strong) NSMutableArray<AUXDeviceSectionItem *> *onTableViewSectionItemArray;
// 设备关机时，显示的功能列表
@property (nonatomic, strong) NSArray<AUXDeviceFunctionItem *> *offFunctionList;
@property (nonatomic, strong) NSMutableArray<AUXDeviceSectionItem *> *offTableViewSectionItemArray;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AUXDeviceFunctionItem *> *functionsDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AUXDeviceSectionItem *> *tableViewSectionItemDictionary;

@property (nonatomic, strong) AUXACControl *virtualDeviceControl;   // 设备控制状态 (虚拟体验/集中控制)
@property (nonatomic, assign) BOOL hasControlSecondsBefore; // 控制设备3s内，忽略设备状态上报

// 定时
@property (nonatomic, strong) NSMutableArray<AUXSchedulerModel *> *schedulerList; // 定时列表
@property (nonatomic, strong) AUXSchedulerModel *operatingSchedulerModel;   // 当前操作的定时
@property (nonatomic, strong) NSTimer *switchTimer;

@property (nonatomic, strong) NSString *currentOnSleepDIYId;                    // 开启中的睡眠DIY (旧设备，只能开启一个睡眠DIY)
@property (nonatomic, strong) AUXSleepDIYModel *currentSleepDIYModel;           // 当前操作中的睡眠DIY (旧设备，命令发送中)
@property (nonatomic, assign) BOOL currentSleepDIYOperation;                    // 当前睡眠DIY的操作：开启/关闭
@property (nonatomic, weak) AUXSleepDIYListViewController *sleepDIYListViewController;

// 用电限制
@property (nonatomic, weak) AUXLimitElectricityViewController *limitElectricityViewController;

// 峰谷节电
@property (nonatomic, strong) AUXPeakValleyModel *peakValleyModel;

// 智能用电
@property (nonatomic, strong) AUXSmartPowerModel *smartPowerModel;

/// 用电曲线
@property (nonatomic, weak) AUXElectricityConsumptionCurveView *electricityConsumptionCurveView;
@property (nonatomic, strong) AUXElectricityConsumptionCurveModel *electricityConsumptionCurveModel;    // 用电曲线模型

@property (nonatomic, strong) NSCalendar *calendar;     // 日历，用于查询用电曲线
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) AUXElectricityCurveDateType curveDateType;

@property (nonatomic, strong) MBProgressHUD *transparentProgressHUD;

@property (nonatomic,assign) BroadlinkTimerType hardwaretype;

@property (nonatomic,assign) BOOL offline;
@property (nonatomic,copy) NSString *address;
@property (nonatomic, strong) AUXDeviceStatus *deviceStatus;        // 设备状态 (用于界面更新)
@property (nonatomic, strong) AUXDeviceFeature *deviceFeature;

@property (nonatomic,strong) AUXDeviceControlViewModel *deviceControlViewModel;
// 睡眠DIY  睡眠DIY列表
@property (nonatomic, strong) NSMutableArray<AUXSleepDIYModel *> *sleepDIYList;
@property (nonatomic, strong) NSMutableArray<AUXSleepDIYModel *> *allSleepDIYList;
@property (nonatomic,strong) NSMutableArray<AUXACSleepDIYPoint *>* sleepDIYPoints;

@property (nonatomic,strong) AUXDeviceControlFunctionListTableViewCell *functionListView;
@property (nonatomic,strong) AUXDeviceControlChildTableViewCell *controlChildView;

@property (nonatomic,strong) NSMutableArray<AUXDeviceFunctionItem *> *windArrayList;
@property (nonatomic,strong) NSMutableArray<AUXDeviceFunctionItem *> *allWindArrayList;
@property (nonatomic,strong) NSMutableArray<AUXDeviceFunctionItem *> *modeArrayList;
@property (nonatomic,strong) NSMutableArray<AUXDeviceFunctionItem *> *screenArrayList;

@property (nonatomic,assign) BOOL showingModeWindSpeedSelectView;
@property (nonatomic,strong) AUXModeAndSpeedView *modeAndSpeedView;

@property (nonatomic,assign) BOOL onlyCoolDevice;
@end

@implementation AUXDeviceControlViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.controlType = AUXDeviceControlTypeVirtual;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self addNotifications];
  

    [self whtherOffline];

    if (self.isfromHomepage) {
        self.customBackAtcion = YES;
    }
}

-(void)backAtcion{
    if (self.isfromHomepage) {
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        [commonModel reSetValue];
    [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        
        if ([self.isNewAdd isEqualToString:@"新增场景"]) {
            
            AUXSceneAddNewViewController *sceneAddNewViewController = nil;
            for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                if ([tempVc isKindOfClass:[AUXSceneAddNewViewController class]]) {
                    sceneAddNewViewController = (AUXSceneAddNewViewController*)tempVc;
                    [self.navigationController popToViewController:sceneAddNewViewController animated:YES];
                }
            }            
        }else{
            [self.navigationController popViewControllerAnimated:YES];

        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initViewModel];
    
    if (self.controlType == AUXDeviceControlTypeSceneMultiDevice) {
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        self.title = commonModel.sceneName;
    }
    
    if (self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        self.title = deviceInfo.alias;
        if (deviceInfo.addressArray.count != deviceInfo.device.aliasDic.count) {
            self.navigationItem.rightBarButtonItem = nil;
            self.title = @"集中控制";
        }
    }
    
    if (self.offline) {
        return ;
    }
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    if (deviceInfo) {
        [self.deviceControlViewModel getFaultList];
        [self.deviceControlViewModel getPowerInfo];
    }
    
    [self.deviceControlViewModel getDeviceDataInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self.deviceControlViewModel deviceRemoveDelegate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableReloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)reloadSectionWithSectionItem:(AUXDeviceSectionItem *)sectionItem {
    
    [self tableReloadData];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark 是否需要显示操作引导页
- (void)whtherShowGuideView {
    
    if ([AUXArchiveTool shouldShowConfigSuccessGuidePage]) {
        [AUXArchiveTool setShouldShowConfigSuccessGuidePage:NO];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        AUXControllGuidView *controlGuideView = [[NSBundle mainBundle] loadNibNamed:@"AUXControllGuidView" owner:nil options:nil].firstObject;
        controlGuideView.isControlDetailGuid = YES;
        controlGuideView.frame = self.view.bounds;
        [self.view addSubview:controlGuideView];
        
        controlGuideView.hideBlock = ^{
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        };
    }
}

#pragma mark 界面、数据初始化
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceNameDidChangeNotification:) name:AUXDeviceNameDidChangeNotification object:nil];
}

- (void)initSubviews {
    [super initSubviews];
    [self createTitleLabel];
    self.hardwaretype = BroadlinkTimerTypeMTK;
    
    [self.tableView registerHeaderFooterViewWithNibName:@"AUXDeviceControlHeaderView"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlStatusTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlChildTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlFunctionListTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlerSchedulerTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlElectricityLimitTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceFunctionSubtitleTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlSleepDiyTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXDeviceControlSmartElectricityTableViewCell"];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];

    if (CGRectContainsPoint(self.controlChildView.bounds, point)) {
        return NO;
    }

    return YES;
}

- (void)initViewModel {
    @weakify(self);
    AUXDeviceControlViewModel *viewModel = [[AUXDeviceControlViewModel alloc] initWithDeviceInfoArray:self.deviceInfoArray controlType:self.controlType delegate:self configBlock:^(NSMutableDictionary *dict) {
        @strongify(self);
        if (dict) {
            if (self.controlType != AUXDeviceControlTypeSceneMultiDevice) {
                self.title = dict[@"alis"];
            }
            self.onlyCoolDevice = [dict[@"onlyCoolDevice"] boolValue];
            self.deviceInfoArray = dict[@"deviceInfoArray"];
            self.deviceFeature = dict[@"deviceFeature"];
            self.virtualDeviceControl = dict[@"virtualDeviceControl"];
            self.deviceStatus = dict[@"deviceStatus"];
            self.onFunctionList = dict[@"onFunctionList"];
            self.onTableViewSectionItemArray = dict[@"onTableViewSectionItemArray"];
            self.offFunctionList = dict[@"offFunctionList"];
            self.offTableViewSectionItemArray = dict[@"offTableViewSectionItemArray"];
            self.functionsDictionary = dict[@"functionsDictionary"];
            self.tableViewSectionItemDictionary = dict[@"tableViewSectionItemDictionary"];
            self.windArrayList = [NSMutableArray arrayWithArray:dict[@"windArrayList"]];
            self.modeArrayList = dict[@"modeArrayList"];
            self.allWindArrayList = [NSMutableArray arrayWithArray:dict[@"windArrayList"]];
            
            [self hotDisable];
            
            [self tableReloadData];
            
            [self whtherOffline];
        }
    }];
    
    viewModel.hardwaretypeBlock = ^(int hardwaretype) {
        self.hardwaretype = hardwaretype;
    };
    
    self.deviceControlViewModel = viewModel;
}

- (void)hotDisable {
    for (AUXDeviceFunctionItem *item in self.onFunctionList) {
        if (item.type == AUXDeviceFunctionTypeHot && self.onlyCoolDevice) {
            item.disabled = YES;
        }
    }
}

- (void)whtherOffline {
    
    if (self.controlType == AUXDeviceControlTypeGateway) {
        self.offline = YES;
    } else if (self.controlType == AUXDeviceControlTypeSceneMultiDevice || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        
        NSMutableArray *offlineNameArray = [NSMutableArray array];
        for (AUXDeviceInfo *deviceInfo in self.deviceInfoArray) {
            
            BOOL isOffline = NO;
            AUXACDevice *device = [AUXUser defaultUser].deviceDictionary[deviceInfo.deviceId];
            AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
            if (!device || !deviceControl) {  // SDK未找到对应的设备
                isOffline = YES;
            } else {
                isOffline = (device.wifiState != AUXACNetworkDeviceWifiStateOnline) ? YES : NO;
            }
            
            if (isOffline) {
                [offlineNameArray addObject:deviceInfo.alias];
            }
        }
        if (offlineNameArray.count > 0 && offlineNameArray.count < self.deviceInfoArray.count) {
            NSString *content = @"部分设备已离线";
            [self showErrorViewWithMessage:content];
        }
        
        if (offlineNameArray.count == self.deviceInfoArray.count) {
            self.offline = YES;
        }
        
    } else if (self.controlType == AUXDeviceControlTypeDevice) {
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        AUXACDevice *device = [AUXUser defaultUser].deviceDictionary[deviceInfo.deviceId];
        AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
        if (!device || !deviceControl) {  // SDK未找到对应的设备
            self.offline = YES;
        } else {
            self.offline = (device.wifiState != AUXACNetworkDeviceWifiStateOnline) ? YES : NO;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.offline) {
            self.offlineView.hidden = NO;
            self.tableView.hidden = YES;
        } else {
            self.offlineView.hidden = YES;
            self.tableView.hidden = NO;
        }
        
        if (self.controlType == AUXDeviceControlTypeVirtual) {
            self.offlineView.hidden = YES;
            self.tableView.hidden = NO;
        }
    });
    
}

#pragma mark AUXDeviceControlViewModelDelegate
- (void)devControlVMDelOfPushToVC:(Class)classVC {
    
    if ([NSStringFromClass(classVC) isEqualToString:@"AUXPeakValleyViewController"]) {
        [self pushPeakValleyViewController];
    } else if ([NSStringFromClass(classVC) isEqualToString:@"AUXSmartPowerViewController"]) {
        [self pushSmartPowerViewController];
    }
}

- (void)devControlVMDelOfSDKQueryAUXDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    
    self.deviceStatus = deviceStatus;

    [self hotDisable];
    [self updateUIWithAUXDeviceStatus:deviceStatus];
    
    [self tableReloadData];
}

- (void)devControlVMDelOfSDKQuerySleepDIYPoints:(NSArray<AUXACSleepDIYPoint *> *)sleepDIYPoints {
    self.sleepDIYPoints = [NSMutableArray arrayWithArray:sleepDIYPoints];
    [self updateUIWithSleepDIYPoints:sleepDIYPoints];
    
}

- (void)devControlVMDelOfQuerySleepModels:(NSArray<AUXSleepDIYModel *> *)sleepDIYModels {
    self.sleepDIYList = [NSMutableArray arrayWithArray:sleepDIYModels];
    
    self.allSleepDIYList = [NSMutableArray arrayWithArray:sleepDIYModels];
    
    [self updateTableViewSleepDIYSection];
    
}

- (void)devControlVMDelOfSchedulerInfo:(NSArray<AUXSchedulerModel *> *)schedulerList {
    [self updateUIWithSchedulerList:schedulerList];
}

- (void)devControlVMDelOfElectricityConsumptionCurveInfo:(AUXElectricityConsumptionCurveModel *)electricityConsumptionCurveModel {
    
    self.electricityConsumptionCurveModel = electricityConsumptionCurveModel;
    [self updateElectricityConsumptionCurveView];
}

- (void)devControlVMDelOfPeakValleyInfo:(AUXPeakValleyModel *)peakValleyModel {
    self.peakValleyModel = peakValleyModel;
    [self updateUIWithPeakValley:self.peakValleyModel];
}

- (void)devControlVMDelOfSmartPowerInfo:(AUXSmartPowerModel *)smartPowerModel {
    self.smartPowerModel = smartPowerModel;
    [self updateUIWithSmartPower:self.smartPowerModel];
}

- (void)devControlVMDelOfShowLoading {
    [self showLoadingHUD];
}

- (void)devControlVMDelOfHideLoading {
    [self hideLoadingHUD];
}

- (void)devControlVMDelOfError:(NSError *)error {
    [self showErrorViewWithError:error defaultMessage:nil];
}

- (void)devControlVMDelOfErrorMessage:(NSString *)errorMessage {
    
    [self showErrorViewWithMessage:errorMessage];
}

- (void)devControlVMDelOfAccountCacheExpired {
    [self alertAccountCacheExpiredMessage];
}

#pragma mark - 界面更新
/// 根据设备控制状态更新UI
- (void)updateUIWithAUXDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    
    if (!deviceStatus) {
        return ;
    }
    
    // 更新开关机状态
    [self updateUIWithPowerStatus:deviceStatus.powerOn];
    
    // 单控
    if (self.controlType == AUXDeviceControlTypeDevice || self.controlType == AUXDeviceControlTypeSubdevice) {
        [self updateUIWithSleepDIY:deviceStatus.sleepDIY];
        
        // 更新用电限制的设置
        [self updateUIWithElectricityLimit:deviceStatus.powerLimit percentage:deviceStatus.powerLimitPercent];
    }
}

/// 更新设备开关机状态
- (void)updateUIWithPowerStatus:(BOOL)powerOn{
    
    // 32位系统的手机，传过来的形参 powerOn 不是BOOL类型，会导致多次执行后续的代码
    // 所以这里这样处理。
    BOOL boolPowerOn = (powerOn != 0) ? YES : NO;
    
    if (self.deviceStatus.powerOn == boolPowerOn) {
        return;
    }
    
    self.deviceStatus.powerOn = boolPowerOn;
    
    if (boolPowerOn) { // 设备处于开机状态
        
        if (self.controlChildView) {
            self.controlChildView.deviceStatus = self.deviceStatus;
            
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            
            for (AUXDeviceSectionItem *sectionItem in self.onTableViewSectionItemArray) {
                if ([self.offTableViewSectionItemArray containsObject:sectionItem]) {
                    continue;
                }
                
                [indexSet addIndex:sectionItem.section];
            }
            
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {    // 设备处于关机状态
        
        if (self.controlChildView) {
            self.controlChildView.deviceStatus = self.deviceStatus;
            
            if (self.showingModeWindSpeedSelectView) {
                [self hideModeWindAndScrrenSelectView];
            } else {
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                
                for (AUXDeviceSectionItem *sectionItem in self.onTableViewSectionItemArray) {
                    if ([self.offTableViewSectionItemArray containsObject:sectionItem]) {
                        continue;
                    }
                    
                    [indexSet addIndex:sectionItem.section];
                }
                
                [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

#pragma mark 用电限制
- (void)updateUIWithElectricityLimit:(BOOL)on percentage:(NSInteger)percentage {
    
    self.deviceStatus.powerLimit = on;
    self.deviceStatus.powerLimitPercent = percentage;
    
    AUXDeviceSectionItem *sectionItem = self.tableViewSectionItemDictionary[@(AUXDeviceFunctionTypeLimitElectricity)];
    
    if (!sectionItem) {
        return ;
    }
    
    if (on) {
        sectionItem.rowCount = 1;
    } else {
        sectionItem.rowCount = 0;
    }
    
    if (self.deviceStatus.powerOn) {
        [self reloadSectionWithSectionItem:sectionItem];
    }
    
//    if (self.limitElectricityViewController) {
//        self.limitElectricityViewController.percentage = percentage;
//        [self.limitElectricityViewController setOn:on animated:YES];
//    }
}

#pragma mark 峰谷节点
- (void)updateUIWithPeakValley:(AUXPeakValleyModel *)peakValleyModel {
    AUXDeviceSectionItem *sectionItem = self.tableViewSectionItemDictionary[@(AUXDeviceFunctionTypePeakValley)];
    
    if (peakValleyModel.on) {
        sectionItem.rowCount = 1;
    } else {
        sectionItem.rowCount = 0;
    }
    
    if (self.deviceStatus.powerOn) {
        [self reloadSectionWithSectionItem:sectionItem];
    }
}

#pragma mark 智能用电
- (void)updateUIWithSmartPower:(AUXSmartPowerModel *)smartPowerModel {
    AUXDeviceSectionItem *sectionItem = self.tableViewSectionItemDictionary[@(AUXDeviceFunctionTypeSmartPower)];
    
    if (smartPowerModel.on) {
        sectionItem.rowCount = 1;
    } else {
        sectionItem.rowCount = 0;
    }
    
    if (self.deviceStatus.powerOn) {
        [self reloadSectionWithSectionItem:sectionItem];
    }
}

#pragma mark 定时
/// 更新定时列表
- (void)updateUIWithSchedulerList:(NSArray<AUXSchedulerModel *> *)schedulerList {
    
    AUXDeviceSectionItem *sectionItem = self.tableViewSectionItemDictionary[@(AUXDeviceFunctionTypeScheduler)];
    
    if (schedulerList && schedulerList.count > 0) {
        self.schedulerList = [[NSMutableArray alloc] initWithArray:schedulerList];
        
        NSMutableArray <AUXSchedulerModel *>*removeArray = [NSMutableArray array];
        for (AUXSchedulerModel *schedulerModel in self.schedulerList) {
            if (!schedulerModel.on) {
                [removeArray addObject:schedulerModel];
            }
        }
        [self.schedulerList removeObjectsInArray:removeArray];
        
        sectionItem.rowCount = self.schedulerList.count;
    } else {
        self.schedulerList = nil;
        sectionItem.rowCount = 0;
    }
    
    [self reloadSectionWithSectionItem:sectionItem];

}

#pragma mark 睡眠DIY

/// 更新睡眠DIY (睡眠DIY开启/关闭)
- (void)updateUIWithSleepDIY:(BOOL)sleepDIY {
    
//    if (self.deviceStatus.sleepDIY == sleepDIY) {
//        return;
//    }
    
    self.deviceStatus.sleepDIY = sleepDIY;
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    // 旧设备睡眠DIY的开启状态根据设备上报的状态来显示，新设备根据服务器的来显示。
    if (deviceInfo.virtualDevice || deviceInfo.source == AUXDeviceSourceGizwits) {
        return;
    }
    
    self.sleepDIYList = [NSMutableArray arrayWithArray:self.allSleepDIYList];
    if (deviceInfo.device.bLDevice) {
        [self updateUIWithSleepDIYPoints:self.sleepDIYPoints];
    } else {
        [self updateTableViewSleepDIYSection];
    }
    
    if (self.sleepDIYListViewController) {
        self.sleepDIYListViewController.deviceStatus = self.deviceStatus;
    }
}

/// 更新睡眠DIY (设备上报当前的睡眠DIY节点列表)
- (void)updateUIWithSleepDIYPoints:(NSArray<AUXACSleepDIYPoint *> *)sleepDIYPoints {
    
    if (self.sleepDIYList.count == 0) {
        return ;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    AUXSleepDIYModel *onSleepDIYModel = nil;
    
    for (AUXSleepDIYModel *sleepDIYModel in self.sleepDIYList) {
        if ([sleepDIYModel isEqualToACSleepDIYPointArray:deviceInfo.device.bLDevice.sleepDIYPoints]) {
            onSleepDIYModel = sleepDIYModel;
            break;
        }
    }
    
    NSString *onSleepDIYId = onSleepDIYModel.sleepDiyId;
    
//    NSLog(@"设备上报睡眠DIY节点列表，当前正在开启的睡眠DIY: %@ %@", onSleepDIYModel.name, onSleepDIYId);
    
    // 当 onSleepDIYId 和 self.currentOnSleepDIYId 的值不相等时，才刷新tableView
    if (!onSleepDIYId && !self.currentOnSleepDIYId) {
        return;
    }
    
//    if (onSleepDIYId && self.currentOnSleepDIYId && [onSleepDIYId isEqualToString:self.currentOnSleepDIYId]) {
//        return;
//    }
    
    self.currentOnSleepDIYId = onSleepDIYId;
    
    [self updateTableViewSleepDIYSection];

}

/// 更新睡眠DIY (睡眠DIY列表发生变化)
- (void)updateTableViewSleepDIYSection {

    AUXDeviceSectionItem *sectionItem = self.tableViewSectionItemDictionary[@(AUXDeviceFunctionTypeSleepDIY)];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    NSMutableArray <AUXSleepDIYModel *>*removeArray = [NSMutableArray array];
    NSMutableArray *tmpArray =  self.sleepDIYList.mutableCopy;
    for (AUXSleepDIYModel *sleepDIYModel in tmpArray) {
        
        if (deviceInfo.device.bLDevice) {
            BOOL on = self.deviceStatus.sleepDIY && self.currentOnSleepDIYId && [sleepDIYModel.sleepDiyId isEqualToString:self.currentOnSleepDIYId];
            if (!on) {
                [removeArray addObject:sleepDIYModel];
            }
        } else {
            if (!sleepDIYModel.on) {
                [removeArray addObject:sleepDIYModel];
            }
        }
    }
    self.sleepDIYList = tmpArray.mutableCopy;
    [self.sleepDIYList removeObjectsInArray:removeArray];
    
    if (self.sleepDIYList != nil && self.sleepDIYList.count > 0) {
        sectionItem.rowCount = self.sleepDIYList.count;
    } else {
        sectionItem.rowCount = 0;
    }
    
    [self reloadSectionWithSectionItem:sectionItem];
}

#pragma mark 互斥逻辑
- (BOOL)canTurnOnSleepDIY:(AUXSleepDIYModel *)sleepDIYModel message:(NSString *__autoreleasing *)message {
    // 睡眠功能开启下不能设置睡眠DIY
    if (self.deviceStatus.sleepMode) {
        NSString *errorMessage = @"睡眠功能开启下不能设置睡眠DIY";
        if (message) {
            *message = errorMessage;
        }
        return NO;
    }
    
    switch (self.deviceStatus.mode) {
        case AirConFunctionAuto:
        case AirConFunctionVentilate:
        case AirConFunctionDehumidify: {
            NSString *errorMessage = @"仅制冷，制热模式有效";
            if (message) {
                *message = errorMessage;
            }
            return NO;
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)canTurnOnPeakValley:(NSString *__autoreleasing *)message {
    // 峰谷节电仅制冷制热模式下可用
    
    if (self.deviceStatus.mode != AirConFunctionCool) {
        if (message) {
            *message = @"峰谷节电仅制冷模式下可用";
        }
        return NO;
    }
    
    // 智能用电开启不能开峰谷节电
    if (self.smartPowerModel.on) {
        if (message) {
            *message = @"请先关闭智能用电，再操作";
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)canTurnOnSmartPower:(NSString *__autoreleasing *)message {
    // 智能用电仅制冷制热模式下可用
    
    switch (self.deviceStatus.mode) {
        case AirConFunctionAuto:
        case AirConFunctionVentilate:
        case AirConFunctionDehumidify: {
            if (message) {
                *message = @"智能用电仅制冷、制热模式有效";
            }
            return NO;
        }
            break;
            
        default:
            break;
    }
    
    // 峰谷节电开启不能开智能用电
    
    if (self.peakValleyModel.on) {
        if (message) {
            *message = @"请先关闭峰谷节电，再操作";
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Actions

/// 调节温度
- (void)actionAdjustTemperature:(CGFloat)temperature {
    
    NSString *errorMessage;
    
    if (![self.deviceStatus canAdjustTemperature:&errorMessage]) {
        [self showErrorViewWithMessage:errorMessage];
        self.controlChildView.deviceStatus = self.deviceStatus;
        return;
    }
    
    self.deviceStatus.temperature = temperature;
    [self.deviceControlViewModel controlDeviceWithTemperature:temperature];
}

/// 关闭设备
- (void)actionTurnOffDevice:(id)sender {
    
    // 童锁开启中，不能关机
    if (self.deviceStatus.childLock) {
        [self showErrorViewWithMessage:@"空调处于锁定状态， 解锁之后才能进行相应操作"];
        return;
    }
    
    BOOL powerOn = NO;
    [self.deviceControlViewModel controlDeviceWithPower:powerOn];
}

/// 开启设备
- (void)actionTurnOnDevice {
    BOOL powerOn = YES;
    [self.deviceControlViewModel controlDeviceWithPower:powerOn];
}

/// 选择了开机状态下的某个功能
- (void)actionSelectOnFunctionAtItem:(NSInteger)item {
    AUXDeviceFunctionItem *functionItem = self.onFunctionList[item];
    [self actionSelectFunctionItem:functionItem];
    
}

/// 选择了关闭状态下的某个功能
- (void)actionSelectOffFunctionAtItem:(NSInteger)item {
    AUXDeviceFunctionItem *functionItem = self.offFunctionList[item];
    [self actionSelectFunctionItem:functionItem];
}

- (void)actionSelectFunctionItem:(AUXDeviceFunctionItem *)functionItem {
    
    if (self.deviceStatus.childLock && functionItem.disabled) {
        return ;
    }
    
    switch (functionItem.type) {
        case AUXDeviceFunctionTypePower: { // 开关
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithPower:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeHot: { // 制热
            
            if (self.onlyCoolDevice) {
                [self showErrorViewWithMessage:@"该设备不支持制热"];
                return ;
            }
            
            if (self.deviceStatus.mode == AirConFunctionHeat && self.deviceStatus.powerOn) {
                return ;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithMode:AirConFunctionHeat];
        }
            break;
            
        case AUXDeviceFunctionTypeCold: { // 制冷
            
            if (self.deviceStatus.mode == AirConFunctionCool && self.deviceStatus.powerOn) {
                return ;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithMode:AirConFunctionCool];
        }
            break;
            
        case AUXDeviceFunctionTypeWindSpeed: {   // 风速
            if (self.deviceStatus.sleepDIY) {   // 睡眠DIY开启时，不能调节风速
                [self showErrorViewWithMessage:@"请关闭睡眠DIY后进行操作"];
                return ;
            }
            
            [self showModeWindAndScreenSelectViewWithType:0];
            
        }
            break;
            
        case AUXDeviceFunctionTypeMode: {  // 模式
            [self showModeWindAndScreenSelectViewWithType:1];
        }
            break;

        case AUXDeviceFunctionTypeSwingLeftRight: { // 左右摆风
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithSwingLeftRight:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeSwingUpDown: {    // 上下摆风
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithSwingUpDown:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeDisplay: {    // 屏显
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            [self showModeWindAndScreenSelectViewWithType:3];
        }
            break;
            
        case AUXDeviceFunctionTypeECO: {    // ECO
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            if ( self.deviceStatus.mode != AirConFunctionCool) {
                [self showErrorViewWithMessage:@"ECO仅制冷模式有效"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithECO:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeElectricalHeating: {    // 电加热
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            if ( self.deviceStatus.mode != AirConFunctionHeat) {
                [self showErrorViewWithMessage:@"电加热仅制热模式有效"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithElectricHeating:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeSleep: {    // 睡眠
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            if ( self.deviceStatus.mode == AirConFunctionVentilate) {
                [self showErrorViewWithMessage:@"睡眠功能在送风模式下无效"];
                return;
            }
            
            AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
            
            if (deviceInfo && !deviceInfo.virtualDevice) {
                if (self.deviceStatus.sleepDIY) {
                    [self showErrorViewWithMessage:@"睡眠DIY功能开启下不能设置"];
                    return;
                }
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithSleepMode:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeHealth: {    // 健康
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithHealthy:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeComfortWind: {    // 舒适风
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            if ( self.deviceStatus.mode != AirConFunctionCool) {
                [self showErrorViewWithMessage:@"仅制冷模式有效"];
                return;
            }
            if ( !functionItem.selected && self.deviceStatus.convenientWindSpeed == WindSpeedAuto) {
                [self showErrorViewWithMessage:@"自动风模式下无效"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithComfortWind:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeScheduler: {   // 定时
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            [self pushSchedulerListViewController];
        }
            break;
            
        case AUXDeviceFunctionTypeSleepDIY: {   // 睡眠DIY
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            [self pushSleepDIYListViewController];
        }
            break;
            
        case AUXDeviceFunctionTypeChildLock:        // 童锁
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithChildLock:functionItem.selected];
            break;
            
        case AUXDeviceFunctionTypeElectricityConsumptionCurve:   // 用电曲线
            [self pushElectricityCurveViewController];
            break;
            
        case AUXDeviceFunctionTypeLimitElectricity: {    // 用电限制
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            [self pushLimitElectricityViewController];
        }
            break;
            
        case AUXDeviceFunctionTypePeakValley: {   // 峰谷节电
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
            
            if (deviceInfo.virtualDevice) {
                [self pushPeakValleyViewController];
            } else {
                if (deviceInfo.device.bLDevice) {
                    [self.deviceControlViewModel getPeakValleyBySDK];
                } else {
                    [self.deviceControlViewModel getPeakValleyByServerWithLoading];
                }
            }
        }
            break;
            
        case AUXDeviceFunctionTypeSmartPower: {   // 智能用电
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
            
            if (deviceInfo.virtualDevice || self.smartPowerModel) {
                [self pushSmartPowerViewController];
            } else {
                if (deviceInfo.device.bLDevice) {
                    [self.deviceControlViewModel getSmartPowerBySDK];
                } else {
                    [self.deviceControlViewModel getSmartPowerByServerWithLoading];
                }
            }
        }
            break;
            
        case AUXDeviceFunctionTypeClean: {      // 清洁
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithClean:functionItem.selected];
        }
            break;
            
        case AUXDeviceFunctionTypeMouldProof: {   // 防霉
            if (self.deviceStatus.childLock) {
                [self showErrorViewWithMessage:@"空调处于锁定状态，解锁之后才能进行相应操作"];
                return;
            }
            
            functionItem.selected = !functionItem.selected;
            [self.deviceControlViewModel controlDeviceWithAntiFungus:functionItem.selected];
        }
            break;
            
        default:
            break;
    }
}

/// 切换用电曲线日期类型
- (void)actionChangeDateType:(AUXElectricityCurveDateType)dateType {
//    self.curveDateType = dateType;
    
    AUXDeviceSectionItem *sectionItem = self.tableViewSectionItemDictionary[@(AUXDeviceFunctionTypeElectricityConsumptionCurve)];
    
    switch (dateType) {
        case AUXElectricityCurveDateTypeDay:
            sectionItem.title = @"日用电曲线";
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            sectionItem.title = @"月用电曲线";
            break;
            
        default:
            sectionItem.title = @"年用电曲线";
            break;
    }
    
    self.electricityConsumptionCurveModel.dateType = self.curveDateType;
    [self.electricityConsumptionCurveModel clearAllPointModels];
    
    AUXDeviceControlHeaderView *headerView = (AUXDeviceControlHeaderView *)[self.tableView headerViewForSection:sectionItem.section];
    
    if (headerView) {
        headerView.titleLabel.text = sectionItem.title;
    }
    
    if (self.electricityConsumptionCurveView) {
        [self updateElectricityConsumptionCurveView];
    }
}

/// 旧设备，通过SDK 开启/关闭睡眠DIY
- (void)switchSleepDIYBySDK:(AUXSleepDIYModel *)sleepDIYModel on:(BOOL)on {
    
    self.deviceStatus.sleepDIY = on;
    
    if (on) {
        self.currentOnSleepDIYId = sleepDIYModel.sleepDiyId;
    } else {
        self.currentOnSleepDIYId = nil;
    }
    
    [self tableReloadData];
    
    [self.deviceControlViewModel controlDeviceWithSleepDIY:on sleepDIYModel:sleepDIYModel];
}

#pragma mark 显示(隐藏)模式(风速、屏显)选择界面

/**
 显示模式/风速选择界面

 @param type 1=模式，0=风速 3=屏显
 */
- (void)showModeWindAndScreenSelectViewWithType:(NSInteger)type {
    
    [self updateWindWithMode:self.deviceStatus.mode]; //模式风速互斥
    
    NSArray <AUXDeviceFunctionItem *> *dataArray;
    
    if (type == 1) {
        dataArray = self.modeArrayList;
        
        for (AUXDeviceFunctionItem *item in self.modeArrayList) {
            if ((NSInteger)item.type == self.deviceStatus.mode) {
                item.selected = YES;
            } else {
                item.selected = NO;
            }
        }
        
    } else if (type == 0) {
        dataArray = self.windArrayList;
        
        for (AUXDeviceFunctionItem *item in self.windArrayList) {
            if ((NSInteger)item.type == self.deviceStatus.convenientWindSpeed) {
                item.selected = YES;
            } else {
                item.selected = NO;
            }
        }
    } else if (type == 3) {
        
        
        for (AUXDeviceFunctionItem *item in self.screenArrayList) {
            item.selected = NO;
            
            if (self.deviceStatus.screenOnOff && self.deviceStatus.autoScreen && self.deviceFeature.screenGear == AUXDeviceScreenGearThree) {
                if ([item.title isEqualToString:@"自动"]) {
                    item.selected = YES;
                }
            } else if (self.deviceStatus.screenOnOff && !self.deviceStatus.autoScreen) {
                if ([item.title isEqualToString:@"开启"]) {
                    item.selected = YES;
                }
            } else if (!self.deviceStatus.screenOnOff) {
                if ([item.title isEqualToString:@"关闭"]) {
                    item.selected = YES;
                }
            }
        }
        
        dataArray = self.screenArrayList;
    }
    
    @weakify(self);
    self.modeAndSpeedView = [AUXModeAndSpeedView alertViewWithNameData:dataArray confirm:^(NSInteger index) {
        @strongify(self);
        AUXDeviceFunctionItem *functionItem;
        if (type == 1) {
            
            functionItem = self.modeArrayList[index];
            functionItem.selected = YES;
            [self.deviceControlViewModel controlDeviceWithMode:(NSInteger)functionItem.type];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceSlectedAirConModeNotification object:nil userInfo:@{AUXDeviceSlectedAirConModeNotification : @((NSInteger)functionItem.type)}];
        } else if (type == 0){
            
            functionItem = self.windArrayList[index];
            functionItem.selected = YES;
            [self.deviceControlViewModel controlDeviceWithWindSpeed:(NSInteger)functionItem.type];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AUXDeviceSlectedWindSpeedNotification object:nil userInfo:@{AUXDeviceSlectedWindSpeedNotification : @((NSInteger)functionItem.type)}];;
        } else if (type == 3) {
            
            for (AUXDeviceFunctionItem *item in self.screenArrayList) {
                item.selected = NO;
            }
            
            functionItem = self.screenArrayList[index];
            functionItem.selected = YES;
            if ([functionItem.title isEqualToString:@"关闭"]) {
                [self.deviceControlViewModel controlDeviceWithScreenOnOff:NO autoScreen:NO];
            } else if ([functionItem.title isEqualToString:@"开启"]) {
                [self.deviceControlViewModel controlDeviceWithScreenOnOff:YES autoScreen:NO];
            } else if ([functionItem.title isEqualToString:@"自动"]) {
                [self.deviceControlViewModel controlDeviceWithScreenOnOff:YES autoScreen:YES];
            }
            
        }
    } close:^{
        
    }];
}

/// 隐藏模式/风速/屏显选择界面
- (void)hideModeWindAndScrrenSelectView {
    
    [self.modeAndSpeedView hideModeAndSpeedViewAtcion];
}

#pragma mark 模式和风速互斥逻辑
- (void)updateWindWithMode:(AirConFunction)mode {
    
    NSMutableArray *removeArray = [NSMutableArray array];
    self.windArrayList = [NSMutableArray arrayWithArray:self.allWindArrayList];
    
    if (mode == AirConFunctionAuto || mode == AirConFunctionDehumidify) {
        
        for (AUXDeviceFunctionItem *item in self.allWindArrayList) {
            if (item.type == WindSpeedTurbo) {
                [removeArray addObject:item];
            }
        }
    }
    
    if (mode == AirConFunctionVentilate) {
        for (AUXDeviceFunctionItem *item in self.allWindArrayList) {
            if (item.type == WindSpeedTurbo || item.type == WindSpeedAuto) {
                [removeArray addObject:item];
            }
        }
    }
    
    if (removeArray.count != 0) {
        [self.windArrayList removeObjectsInArray:removeArray];
    } else {
        self.windArrayList = [NSMutableArray arrayWithArray:self.allWindArrayList];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray<AUXDeviceSectionItem *> *sectionItemArray = self.deviceStatus.powerOn ? self.onTableViewSectionItemArray : self.offTableViewSectionItemArray;
    return sectionItemArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger row = 0;
    
    if (section == 0) {
        row = 3;
    } else {
        NSArray<AUXDeviceSectionItem *> *sectionItemArray;
        
        if (self.deviceStatus.powerOn) {
            sectionItemArray = self.onTableViewSectionItemArray;
        } else {
            sectionItemArray = self.offTableViewSectionItemArray;
        }
        
        if (sectionItemArray.count > section - 1) {
            AUXDeviceSectionItem *item = sectionItemArray[section - 1];
            row = item.rowCount;
        }

        
    }
    
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat height = 0.01;
    
    if (section == 0) {
        height = 0.01;
    } else {
        height = AUXDeviceControlHeaderView.properHeight;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0.0;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                height = AUXDeviceControlStatusTableViewCell.properHeight;
                break;
            case 1:
                height = AUXDeviceControlChildTableViewCell.properHeight;
                break;
            case 2:{
                CGFloat col = self.deviceStatus.powerOn ? (self.onFunctionList.count / 4 + (self.onFunctionList.count % 4 == 0 ? 0 : 1)) : (self.offFunctionList.count / 4 + (self.offFunctionList.count % 4 == 0 ? 0 : 1));
                
                CGFloat vMarign = 42;
                height = col * 50 + (col - 1) * vMarign + 26;
                
                height <= 0 ? height = 167 : height;
                
                break;
            }
                
            default:
                break;
        }
    } else {
        NSArray<AUXDeviceSectionItem *> *sectionItemArray;
        
        if (tableView.numberOfSections == self.onTableViewSectionItemArray.count + 1) {
            sectionItemArray = self.onTableViewSectionItemArray;
        } else {
            sectionItemArray = self.offTableViewSectionItemArray;
        }
        
        AUXDeviceSectionItem *item = sectionItemArray[indexPath.section - 1];
        
  
        switch (item.type) {
            case AUXDeviceFunctionTypeScheduler:
                height = AUXDeviceControlerSchedulerTableViewCell.properHeight;
                break;
            case AUXDeviceFunctionTypeElectricityConsumptionCurve:
                height = AUXElectricityConsumptionCurveView.properHeightForCell;
                break;
            case AUXDeviceFunctionTypeLimitElectricity:
                height = AUXDeviceControlElectricityLimitTableViewCell.properHeight;
                break;
            case AUXDeviceFunctionTypePeakValley:
                height = AUXDeviceFunctionSubtitleTableViewCell.properHeight;
                break;
            case AUXDeviceFunctionTypeSleepDIY:
                height = AUXDeviceControlSleepDiyTableViewCell.properHeight;
                break;
            case AUXDeviceFunctionTypeSmartPower:
                height = 60;
                break;
            default:
                height = 100.0;
                break;
        }
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    }
    
    AUXDeviceControlHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AUXDeviceControlHeaderView"];
    
    NSArray<AUXDeviceSectionItem *> *sectionItemArray;
    // 开机状态下
    if (self.deviceStatus.powerOn) {
        sectionItemArray = self.onTableViewSectionItemArray;
    } else {    // 关机状态下
        sectionItemArray = self.offTableViewSectionItemArray;
    }
    
    if (sectionItemArray.count <= section-1) {
        return nil;
    }
    AUXDeviceSectionItem *item = sectionItemArray[section - 1];
    
    headerView.titleLabel.text = item.title;
    headerView.iconImageView.image = [UIImage imageNamed:item.imageStr];
    headerView.showsDisclosureIndicator = !item.hideIndicator;
    
    if (item.canClicked) {
        @weakify(self, tableView);
        headerView.tapHeaderViewBlock = ^{
            @strongify(self, tableView);
            [self tableView:tableView didTapSection:section];
        };
    } else {
        headerView.tapHeaderViewBlock = nil;
    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView cellDeviceStatusAtIndexPath:indexPath];
                break;
            case 1:
                cell = [self tableView:tableView cellDeviceControlChildAtIndexPath:indexPath];
                break;
            case 2:
                cell = [self tableView:tableView cellAsFunctionListAtIndexPath:indexPath];
                break;
                
            default:
                break;
        }
    } else {
        NSArray<AUXDeviceSectionItem *> *sectionItemArray;
        
        if (self.deviceStatus.powerOn) {
            sectionItemArray = self.onTableViewSectionItemArray;
        } else {
            sectionItemArray = self.offTableViewSectionItemArray;
        }
        
        AUXDeviceSectionItem *sectionItem = sectionItemArray[indexPath.section - 1];
        
        switch (sectionItem.type) {
            case AUXDeviceFunctionTypeScheduler:
                cell = [self tableView:tableView cellForSchedulerAtIndexPath:indexPath];
                break;
                
            case AUXDeviceFunctionTypeElectricityConsumptionCurve:
                cell = [self tableView:tableView cellForElectricityCurveAtIndexPath:indexPath];
                break;
                
            case AUXDeviceFunctionTypeLimitElectricity:
                cell = [self tableView:tableView cellForLimitElectricityAtIndexPath:indexPath];
                break;
                
            case AUXDeviceFunctionTypePeakValley:
                cell = [self tableView:tableView cellForPeakValleyAtIndexPath:indexPath];
                break;
                
            case AUXDeviceFunctionTypeSleepDIY:
                cell = [self tableView:tableView cellForSleepDIYAtIndexPath:indexPath];
                break;
                
            case AUXDeviceFunctionTypeSmartPower:
                cell = [self tableView:tableView cellForSmartPowerAtIndexPath:indexPath];
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

// 设备状态
- (UITableViewCell *)tableView:(UITableView *)tableView cellDeviceStatusAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceControlStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlStatusTableViewCell" forIndexPath:indexPath];
    cell.controlType = self.controlType;
    cell.deviceFeature = self.deviceFeature;
    cell.deviceStatus = self.deviceStatus;
    return cell;
}

// 设备状态
- (UITableViewCell *)tableView:(UITableView *)tableView cellDeviceControlChildAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceControlChildTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlChildTableViewCell" forIndexPath:indexPath];
    self.controlChildView = cell;
    cell.controlType = self.controlType;
    cell.deviceFeature = self.deviceFeature;
    cell.deviceStatus = self.deviceStatus;
    cell.offline = self.offline;
    
    @weakify(self);
    cell.didAdjustTemperatureBlock = ^(CGFloat temperature) {
        @strongify(self);
        [self actionAdjustTemperature:temperature];
    };
    
    cell.showErrorMessageBlock = ^(NSString * _Nonnull errorMessage) {
        @strongify(self);
        [self showErrorViewWithMessage:errorMessage];
    };
    
    cell.pushToFaultVCBlock = ^{
        @strongify(self);
        [self pushFaultListViewController];
    };
    
    cell.powerOnBlock = ^{
        @strongify(self);
        [self actionTurnOnDevice];
    };
    
    return cell;
}


// 功能列表
- (UITableViewCell *)tableView:(UITableView *)tableView cellAsFunctionListAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceControlFunctionListTableViewCell *functionListView = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlFunctionListTableViewCell" forIndexPath:indexPath];
    self.functionListView = functionListView;
    
    functionListView.onFunctionList = self.onFunctionList;
    functionListView.offFunctionList = self.offFunctionList;
    functionListView.deviceStatus = self.deviceStatus;
    
    @weakify(self);
    functionListView.didSelectOnItemBlock = ^(NSInteger item) {
        @strongify(self);
        [self actionSelectOnFunctionAtItem:item];
    };
    
    functionListView.didSelectOffItemBlock = ^(NSInteger item) {
        @strongify(self);
        [self actionSelectOffFunctionAtItem:item];
    };
    
    return functionListView;
}
// 定时
- (UITableViewCell *)tableView:(UITableView *)tableView cellForSchedulerAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceControlerSchedulerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlerSchedulerTableViewCell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    AUXSchedulerModel *schedulerModel = self.schedulerList[row];
    
    cell.schedulerModel = schedulerModel;

    return cell;
}

// 用电曲线
- (UITableViewCell *)tableView:(UITableView *)tableView cellForElectricityCurveAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"electricityCurveCell"];
    AUXElectricityConsumptionCurveView *curveView;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"electricityCurveCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        curveView = [[AUXElectricityConsumptionCurveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), AUXElectricityConsumptionCurveView.properHeightForCell)];
        curveView.rightMargin = 0;
        curveView.yAxisScaleCount = 5;
        curveView.unitString = @"(度)";
        curveView.lineColor = [UIColor colorWithHex:0xf6f6f6];
        curveView.tag = 100;
        
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        
        curveView.oldDevice = (deviceInfo.source == AUXDeviceSourceBL);
        
        [cell.contentView addSubview:curveView];
        self.electricityConsumptionCurveView = curveView;
    } else {
        curveView = [cell.contentView viewWithTag:100];
    }
    
    curveView.year = self.dateComponents.year;
    curveView.month = self.dateComponents.month;
    curveView.day = self.dateComponents.day;
    curveView.dateType = self.curveDateType;
    
    curveView.pointModelList = self.electricityConsumptionCurveModel.pointModelList;
    [curveView updateCurveView];
    
    return cell;
}

// 用电限制
- (UITableViewCell *)tableView:(UITableView *)tableView cellForLimitElectricityAtIndexPath:(NSIndexPath *)indexPath {
    AUXDeviceControlElectricityLimitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlElectricityLimitTableViewCell" forIndexPath:indexPath];
    
    cell.percentage = self.deviceStatus.powerLimitPercent;
    
    return cell;
}

// 睡眠DIY
- (UITableViewCell *)tableView:(UITableView *)tableView cellForSleepDIYAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    AUXSleepDIYModel *sleepDIYModel = nil;
    if (self.sleepDIYList.count > row) {
        sleepDIYModel =  self.sleepDIYList[row];
    }
    AUXDeviceControlSleepDiyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlSleepDiyTableViewCell" forIndexPath:indexPath];
    cell.sleepDiyModel = sleepDIYModel;
    return cell;
}
// 峰谷节电
- (UITableViewCell *)tableView:(UITableView *)tableView cellForPeakValleyAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceFunctionSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceFunctionSubtitleTableViewCell" forIndexPath:indexPath];
    
    cell.peakValleyModel = self.peakValleyModel;
    
    return cell;
}

// 智能用电
- (UITableViewCell *)tableView:(UITableView *)tableView cellForSmartPowerAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXDeviceControlSmartElectricityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXDeviceControlSmartElectricityTableViewCell" forIndexPath:indexPath];
    cell.smartPowerModel = self.smartPowerModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didTapSection:(NSInteger)section {
    
    NSArray<AUXDeviceSectionItem *> *sectionItemArray;
    
    if (self.deviceStatus.powerOn) {
        sectionItemArray = self.onTableViewSectionItemArray;
    } else {
        sectionItemArray = self.offTableViewSectionItemArray;
    }
    
    AUXDeviceSectionItem *sectionItem = sectionItemArray[section - 1];
    
    AUXDeviceFunctionItem *functionItem = [[AUXDeviceFunctionItem alloc]init];
    
    AUXDeviceSectionItem *tapSectionItem = self.tableViewSectionItemDictionary[@(sectionItem.type)];
    functionItem.type = tapSectionItem.type;
    [self actionSelectFunctionItem:functionItem];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - 界面跳转

- (IBAction)actionShowDeviceInfo:(id)sender {
    
    if (self.controlType == AUXDeviceControlTypeSceneMultiDevice) {
        AUXSceneSetCenterControlViewController *sceneSetCenterControlViewController = [AUXSceneSetCenterControlViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        sceneSetCenterControlViewController.tmpDict = self.tmpDict;
        sceneSetCenterControlViewController.backBlock = ^(NSArray * _Nonnull tmpArray) {
            if (tmpArray.count>0) {
                self.deviceInfoArray = tmpArray.mutableCopy;
                
            }
            
        };
        
        [self.navigationController pushViewController:sceneSetCenterControlViewController animated:YES];
        
    }else{
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        NSString *address;
        AUXACDevice *device;
        
        if (!deviceInfo.virtualDevice) {
            address = deviceInfo.addressArray.firstObject;
            device = deviceInfo.device;
        }
        
        BOOL oldDevice = NO;
        if (device.bLDevice) {
            oldDevice = YES;
        }
        
        BOOL isSubDevice = NO;
        if (deviceInfo.suitType == AUXDeviceSuitTypeGateway && deviceInfo.addressArray.count < device.aliasDic.count) {
            isSubDevice = YES;
        }
        
        AUXDeviceControlType type = self.controlType;
        if (isSubDevice) {
            type = AUXDeviceControlTypeGateway;
        }

        AUXDeviceInfoViewController *deviceInfoViewController = [AUXDeviceInfoViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        deviceInfoViewController.deviceInfo = deviceInfo;
        deviceInfoViewController.device = device;
        deviceInfoViewController.oldDevice = oldDevice;
        deviceInfoViewController.address = address;
        deviceInfoViewController.deviceStatus = self.deviceStatus;
        deviceInfoViewController.controlType = type;
        [self.navigationController pushViewController:deviceInfoViewController animated:YES];
    }
}

/// 跳转到定时列表
- (void)pushSchedulerListViewController {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    NSString *address;
    AUXACDevice *device;
    
    if (!deviceInfo.virtualDevice) {
        address = deviceInfo.addressArray.firstObject;
        device = deviceInfo.device;
    }
    
    AUXSchedulerListViewController *schedulerListViewController = [AUXSchedulerListViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    
    schedulerListViewController.deviceInfo = deviceInfo;
    schedulerListViewController.device = device;
    schedulerListViewController.address = address;
    schedulerListViewController.hardwaretype = self.hardwaretype;
    
    schedulerListViewController.schedulerList = self.schedulerList;
    
    [self.navigationController pushViewController:schedulerListViewController animated:YES];
}

/// 跳转到睡眠DIY列表
- (void)pushSleepDIYListViewController {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    NSString *address;
    AUXACDevice *device;
    AUXACControl *control;
    
    if (!deviceInfo.virtualDevice) {
        address = deviceInfo.addressArray.firstObject;
        device = deviceInfo.device;
        control = device.controlDic[address];
    }
    
    BOOL oldDevice = NO;
    if (device.bLDevice) {
        oldDevice = YES;
    }
    
    AUXSleepDIYListViewController *sleepDIYListViewController = [AUXSleepDIYListViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    sleepDIYListViewController.oldDevice = oldDevice;
    sleepDIYListViewController.deviceInfo = deviceInfo;
    sleepDIYListViewController.device = device;
    sleepDIYListViewController.deviceControl = control;
    sleepDIYListViewController.deviceFeature = self.deviceFeature;
    sleepDIYListViewController.address = address;
    sleepDIYListViewController.sleepDIYList = self.allSleepDIYList;
    sleepDIYListViewController.sleepDIY = self.deviceStatus.sleepDIY;
    sleepDIYListViewController.currentOnSleepDIYId = self.currentOnSleepDIYId;
    sleepDIYListViewController.deviceControlViewController = self;
    sleepDIYListViewController.controlType = self.controlType;
    
    
    self.sleepDIYListViewController = sleepDIYListViewController;
    [self.navigationController pushViewController:sleepDIYListViewController animated:YES];
}

/// 跳转到用电限制
- (void)pushLimitElectricityViewController {
    AUXLimitElectricityViewController *limitElectricityViewController = [AUXLimitElectricityViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    self.limitElectricityViewController = limitElectricityViewController;
    
    limitElectricityViewController.percentage = self.deviceStatus.powerLimitPercent;
    limitElectricityViewController.on = self.deviceStatus.powerLimit;
    
    @weakify(self);
    limitElectricityViewController.controlBlock = ^(BOOL on, NSInteger percentage) {
        @strongify(self);
        [self.deviceControlViewModel controlDeviceWithElectricityLimit:on percentage:percentage];
        [self updateUIWithElectricityLimit:on percentage:percentage];
    };
    
    [self.navigationController pushViewController:limitElectricityViewController animated:YES];
}

/// 跳转到峰谷节电
- (void)pushPeakValleyViewController {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    AUXACDevice *device;
    
    if (!deviceInfo.virtualDevice) {
        device = deviceInfo.device;
    }
    
    AUXPeakValleyViewController *peakValleyViewController = [AUXPeakValleyViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    peakValleyViewController.deviceControlViewController = self;
    peakValleyViewController.deviceInfo = deviceInfo;
    peakValleyViewController.device = device;
    peakValleyViewController.peakValleyModel = [self.peakValleyModel copy];
    
    [self.navigationController pushViewController:peakValleyViewController animated:YES];
}

/// 跳转到智能用电
- (void)pushSmartPowerViewController {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    NSString *address;
    AUXACDevice *device;
    AUXACStatus *status;
    
    if (!deviceInfo.virtualDevice) {
        address = deviceInfo.addressArray.firstObject;
        device = deviceInfo.device;
        status = device.statusDic[address];
    }
    
    AUXSmartPowerViewController *smartPowerViewController = [AUXSmartPowerViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    smartPowerViewController.deviceControlViewController = self;
    smartPowerViewController.deviceInfo = deviceInfo;
    smartPowerViewController.device = device;
    smartPowerViewController.powerRating = status.powerRating;
    smartPowerViewController.smartPowerModel = [self.smartPowerModel copy];
    
    [self.navigationController pushViewController:smartPowerViewController animated:YES];
}

/// 跳转到用电曲线
- (void)pushElectricityCurveViewController {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    AUXACDevice *device;
    
    if (!deviceInfo.virtualDevice) {
        device = deviceInfo.device;
    }
    
    AUXElectricityConsumptionCurveViewController *electricityConsumptionCurveViewController = [AUXElectricityConsumptionCurveViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    electricityConsumptionCurveViewController.deviceInfo = deviceInfo;
    electricityConsumptionCurveViewController.device = device;
//    electricityConsumptionCurveViewController.currentDateType = self.curveDateType;
    
    @weakify(self);
    electricityConsumptionCurveViewController.didChangeDateTypeBlock = ^(AUXElectricityCurveDateType dateType) {
        @strongify(self);
//        [self actionChangeDateType:dateType];
    };
    
    [self.navigationController pushViewController:electricityConsumptionCurveViewController animated:YES];
}

/// 跳转到故障列表
- (void)pushFaultListViewController {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    AUXACDevice *device;
    
    if (!deviceInfo.virtualDevice) {
        device = deviceInfo.device;
    }
    
    AUXFaultListViewController *faultListViewController = [AUXFaultListViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
    faultListViewController.deviceInfo = deviceInfo;
    faultListViewController.device = device;
    faultListViewController.faultError = self.deviceStatus.fault;
    faultListViewController.filterInfo = self.deviceStatus.filterInfo;
    [self.navigationController pushViewController:faultListViewController animated:YES];
}

#pragma mark 用电曲线

/// 更新曲线
- (void)updateElectricityConsumptionCurveView {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo && !deviceInfo.virtualDevice) {
        [self.electricityConsumptionCurveModel removeUnnecessaryPointModels];
    }
    
    self.electricityConsumptionCurveView.dateType = self.curveDateType;
    self.electricityConsumptionCurveView.pointModelList = self.electricityConsumptionCurveModel.pointModelList;
    
    [self.electricityConsumptionCurveView updateCurveView];
}


#pragma mark - Notifications

/// 修改了设备名
- (void)deviceNameDidChangeNotification:(NSNotification *)notification {
    
    NSString *name = notification.object;
    if (AUXWhtherNullString(name)) {
        return ;
    }
    
    switch (self.controlType) {
        case AUXDeviceControlTypeDevice:
        case AUXDeviceControlTypeGatewayMultiDevice:
        case AUXDeviceControlTypeGateway:
            self.title = name;
            break;
            
        default:
            self.title = name;
            break;
    }
}

#pragma mark 根据设备首页刷新当前页面状态
- (void)reloadDeviceArray:(NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    
    if (deviceInfoArray) {
        AUXDeviceInfo *deviceInfo = deviceInfoArray.firstObject;
        NSMutableDictionary *deviceDict = [AUXUser defaultUser].deviceDictionary;
        AUXACDevice *device = deviceDict[deviceInfo.deviceId];
        
        if (!self.offline) {
            return ;
        }

        AUXBaseViewController *tmpVC = self.navigationController.viewControllers.lastObject;
        if (![tmpVC isKindOfClass:[AUXDeviceControlViewController class]]) {
            return;
        }
        deviceInfo.device = device;
        [self whtherOffline];
        [self viewWillAppear:NO];
    }
}

#pragma mark getter
- (NSMutableArray<AUXDeviceFunctionItem *> *)screenArrayList {
    if (!_screenArrayList) {
        
        AUXDeviceFunctionItem *item = [[AUXDeviceFunctionItem alloc]init];
        item.title = @"关闭";
        AUXDeviceFunctionItem *item2 = [[AUXDeviceFunctionItem alloc]init];
        item2.title = @"开启";
        
        
        NSMutableArray *screenDataArray = [NSMutableArray array];
        [screenDataArray addObject:item];
        [screenDataArray addObject:item2];
        
        if (self.deviceFeature.screenGear == AUXDeviceScreenGearThree) {
            AUXDeviceFunctionItem *item3 = [[AUXDeviceFunctionItem alloc]init];
            item3.title = @"自动";
            [screenDataArray addObject:item3];
        }
        
        _screenArrayList = screenDataArray;
    }
    return _screenArrayList;
}

- (NSDateComponents *)dateComponents {
    if (!_dateComponents) {
        self.calendar = [NSCalendar currentCalendar];
        self.date = [NSDate date];
        self.dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:self.date];
    }
    return _dateComponents;
}

@end

