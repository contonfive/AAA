//
//  AUXDeviceControlViewModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlViewModel.h"
#import "AUXNetworkManager.h"
#import "AUXDeviceControlTask.h"
#import "AUXConstant.h"
#import "AUXTimerObject.h"

@interface AUXDeviceControlViewModel ()<AUXACDeviceProtocol>

@property (nonatomic,copy) InitConfigInfoBlock configBlock;
@property (nonatomic,weak) id<AUXDeviceControlViewModelDelegate> delegate;

@property (nonatomic,copy) NSString *alis;
@property (nonatomic, strong) NSArray<AUXDeviceInfo *> *deviceInfoArray;
/// 设备控制类型。默认为 AUXDeviceControlTypeVirtual 虚拟体验。
@property (nonatomic, assign) AUXDeviceControlType controlType;
@property (nonatomic, strong) AUXDeviceFeature *deviceFeature;
@property (nonatomic, strong) AUXACControl *virtualDeviceControl;   // 设备控制状态 (虚拟体验/集中控制)
@property (nonatomic,strong) NSMutableDictionary *configDict;

@property (nonatomic, strong) AUXDeviceStatus *deviceStatus;        // 设备状态 (用于界面更新)

// 设备开机时，显示的功能列表
@property (nonatomic, strong) NSArray<AUXDeviceFunctionItem *> *onFunctionList;
@property (nonatomic, strong) NSMutableArray<AUXDeviceSectionItem *> *onTableViewSectionItemArray;
// 设备关机时，显示的功能列表
@property (nonatomic, strong) NSArray<AUXDeviceFunctionItem *> *offFunctionList;
@property (nonatomic, strong) NSMutableArray<AUXDeviceSectionItem *> *offTableViewSectionItemArray;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AUXDeviceFunctionItem *> *functionsDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AUXDeviceSectionItem *> *tableViewSectionItemDictionary;

@property (nonatomic,strong) NSMutableArray<AUXDeviceFunctionItem *> *windArrayList;
@property (nonatomic,strong) NSMutableArray<AUXDeviceFunctionItem *> *modeArrayList;
// 睡眠DIY  睡眠DIY列表
@property (nonatomic, strong) NSMutableArray<AUXSleepDIYModel *> *sleepDIYList;

@property (nonatomic, assign) BOOL hasControlSecondsBefore; // 控制设备3s内，忽略设备状态上报

@property (nonatomic, strong) AUXPeakValleyModel *peakValleyModel;
@property (nonatomic, strong) AUXSmartPowerModel *smartPowerModel;

@property (nonatomic, strong) NSTimer *queryPeakValleyTimer;  // 查询状态 峰谷用电 Timer
@property (nonatomic, strong) NSTimer *querySmartPowerTimer;  // 查询状态 智能用电 Timer

@property (nonatomic,assign) BroadlinkTimerType hardwaretype;

@property (nonatomic, strong) NSCalendar *calendar;     // 日历，用于查询用电曲线
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) AUXElectricityCurveDateType curveDateType;
@property (nonatomic, strong) AUXElectricityConsumptionCurveModel *electricityConsumptionCurveModel;    // 用电曲线模型


@property (nonatomic, strong) NSMutableDictionary<NSString *, AUXDeviceControlQueue *> *controlQueueDict;

@property (nonatomic, strong) NSString *currentOnSleepDIYId;                    // 开启中的睡眠DIY (旧设备，只能开启一个睡眠DIY)
@property (nonatomic, strong) AUXSleepDIYModel *currentSleepDIYModel;           // 当前操作中的睡眠DIY (旧设备，命令发送中)
@property (nonatomic, assign) BOOL currentSleepDIYOperation;

@property (nonatomic,assign) BOOL onlyCoolDevice;

@property (nonatomic,strong) NSTimer *hideLoadingTimer;

@end

@implementation AUXDeviceControlViewModel

- (instancetype)initWithDeviceInfoArray:(NSArray<AUXDeviceInfo *> *)deviceInfoArray
                      controlType:(AUXDeviceControlType)controlType
                          delegate:(id<AUXDeviceControlViewModelDelegate>)delegate configBlock:(InitConfigInfoBlock)configBlock{
    self = [super init];
    if (self) {
        self.deviceInfoArray = deviceInfoArray;
        self.controlType = controlType;
        self.delegate = delegate;
        self.configBlock = configBlock;
        self.hardwaretype = BroadlinkTimerTypeMTK;
        self.onlyCoolDevice = NO;
        
        [self initConfigDeviceInfo];
        [self initConfigDict];
        
    }
    return self;
}

- (void)initConfigDeviceInfo {
    AUXDeviceInfo *deviceInfo;
    NSString *address;
    switch (self.controlType) {
        case AUXDeviceControlTypeVirtual: {
            // 虚拟体验
            self.alis = @"虚拟体验";
            self.deviceFeature = [AUXDeviceFeature virtualDeviceFeature];
            
            AUXDeviceInfo *virtualDeviceInfo = [AUXDeviceInfo virtualDeviceInfo];
            [virtualDeviceInfo updateDeviceFeature:self.deviceFeature];
            
            self.deviceInfoArray = @[virtualDeviceInfo];
            
            self.deviceStatus = [[AUXDeviceStatus alloc] initWithGearType:virtualDeviceInfo.windGearType];
            
            self.virtualDeviceControl = [[AUXACControl alloc] init];
            [self.deviceStatus updateValueForControl:self.virtualDeviceControl];
        }
            break;
            
        case AUXDeviceControlTypeSceneMultiDevice:
        case AUXDeviceControlTypeGatewayMultiDevice:
            // 集中控制
            // 集中控制时，只下发命令，不接收设备状态，所以不需要设置代理。
            self.alis = @"集中控制";
            self.deviceFeature = [AUXDeviceFeature multiDeviceFeature];
            
            if (self.deviceFeature == nil) {
                [self getMultiControlFunctionListWithDeviceInfoArray];
            }
            
            self.deviceStatus = [[AUXDeviceStatus alloc] initWithGearType:WindGearType1];
            
            self.virtualDeviceControl = [[AUXACControl alloc] init];
            [self.deviceStatus updateValueForControl:self.virtualDeviceControl];
            self.virtualDeviceControl.leftRightSwing = 7;
            self.virtualDeviceControl.upDownSwing = 7;
            break;
            
        default: {
            // 单控
            deviceInfo = self.deviceInfoArray.firstObject;
            address = deviceInfo.addressArray.firstObject;
            
            // 设备
            if (self.controlType == AUXDeviceControlTypeDevice) {
                self.alis = deviceInfo.alias;
            } else if (self.controlType == AUXDeviceControlTypeSubdevice) {    // 子设备
                
                self.alis = deviceInfo.device.aliasDic[address];
                /**
                 更新轮询设备地址，默认订阅设备后轮询地址0x01
                 
                 @param address 更新设备地址，支持地址位0x01～0x40，16进制表记
                 @param mac 更新设备mac
                 */
                [[AUXACDeviceManager sharedInstance] updatePollingAddress:address forMac:deviceInfo.mac];
            } else if (self.controlType == AUXDeviceControlTypeGateway) {
                self.alis = deviceInfo.alias;
            }
            
            [deviceInfo.device.delegates addObject:self];
            
            self.deviceStatus = [[AUXDeviceStatus alloc] initWithGearType:deviceInfo.windGearType];
            self.deviceFeature = deviceInfo.deviceFeature;
            
            [[AUXACNetwork sharedInstance] getFirmwareVersionForDevice:deviceInfo.device];
        }
            break;
    }
    
    [self initCurveModel];
    [self initOnFunctionList];
    [self initOffFunctionList];
    [self initOnSectionInfoArray];
    [self initOffSectionInfoArray];
    [self initWindArray];
    [self initModeArray];
    
    // 单控，非虚拟体验
    if (deviceInfo) {
        // 更新设备状态
        AUXACControl *deviceControl = deviceInfo.device.controlDic[address];
        AUXACStatus *deviceStatus = deviceInfo.device.statusDic[address];
        
        // 更新控制状态
        if (deviceControl) {
            [self updateStatusWithSDKControl:deviceControl];
            //[self delegateRespondAUXACControl:deviceControl];
        }
        // 更新运行状态
        if (deviceStatus) {
            [self updateStatusWithSDKStatus:deviceStatus];
            [self delegateRespondAUXACStatus:deviceStatus];
            
        }
        
    } else {    // 集中控制、虚拟体验
        // 更新控制状态
        [self updateStatusWithSDKControl:self.virtualDeviceControl];
        //[self delegateRespondAUXACControl:self.virtualDeviceControl];
        // 更新运行状态
        [self delegateRespondAUXDeviceStatus:self.deviceStatus];
    }
    
}

/// 初始化 tableView section header 信息 (开机状态下)
- (void)initOnSectionInfoArray {
    NSArray<NSNumber *> *sectionArray = [self.deviceFeature convertToOnSectionList];
    
    self.onTableViewSectionItemArray = [[NSMutableArray alloc] init];
    self.tableViewSectionItemDictionary = [[NSMutableDictionary alloc] init];
    
    NSDictionary<NSNumber *, NSDictionary *> *sectionInfosDict = [AUXConfiguration getDeviceControlTableViewSectionInfosDictionary];
    
    for (int i = 0; i < sectionArray.count; i++) {
        NSNumber *sectionType = sectionArray[i];
        NSDictionary *sectionInfo = sectionInfosDict[sectionType];
        
        AUXDeviceSectionItem *item = [AUXDeviceSectionItem yy_modelWithDictionary:sectionInfo];
        item.section = i + 1;
        
        [self.onTableViewSectionItemArray addObject:item];
        [self.tableViewSectionItemDictionary setObject:item forKey:sectionType];
    }
}

/// 初始化 tableView section header 信息 (关机状态下)
- (void)initOffSectionInfoArray {
    NSArray<NSNumber *> *sectionArray = [self.deviceFeature convertToOffSectionList];
    
    self.offTableViewSectionItemArray = [[NSMutableArray alloc] init];
    
    NSDictionary<NSNumber *, NSDictionary *> *sectionInfosDict = [AUXConfiguration getDeviceControlTableViewSectionInfosDictionary];
    
    for (int i = 0; i < sectionArray.count; i++) {
        NSNumber *sectionType = sectionArray[i];
        
        AUXDeviceSectionItem *item = self.tableViewSectionItemDictionary[sectionType];
        
        if (!item) {
            NSDictionary *sectionInfo = sectionInfosDict[sectionType];
            item = [AUXDeviceSectionItem yy_modelWithDictionary:sectionInfo];
            [self.tableViewSectionItemDictionary setObject:item forKey:sectionType];
        }
        
        item.offSection = i + 1;
        
        [self.offTableViewSectionItemArray addObject:item];
    }
}

/// 初始化功能列表 (开机状态下)
- (void)initOnFunctionList {
    NSMutableArray<AUXDeviceFunctionItem *> *functionList = [[NSMutableArray alloc] init];
    self.onFunctionList = functionList;
    
    NSMutableDictionary<NSNumber *, AUXDeviceFunctionItem *> *functionsDictionary = [[NSMutableDictionary alloc] init];
    self.functionsDictionary = functionsDictionary;
    
    // 当前设备可用的功能列表
    NSArray<NSNumber *> *enableFuncList = [self.deviceFeature convertToOnFunctionList];
    
    // 获取设备功能列表的配置信息
    NSDictionary<NSNumber *, NSDictionary *> *totalFunctionsDict = [AUXConfiguration getDeviceFunctionsDictionary];
    
    
    if (self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        NSMutableArray *deviceSupportFunction = [NSMutableArray arrayWithArray:enableFuncList];
        
        if ([deviceSupportFunction containsObject:@(AUXDeviceFunctionTypeSwingUpDown)]) {
            [deviceSupportFunction removeObject:@(AUXDeviceFunctionTypeSwingUpDown)];
        }
        if ([deviceSupportFunction containsObject:@(AUXDeviceFunctionTypeSwingLeftRight)]) {
            [deviceSupportFunction removeObject:@(AUXDeviceFunctionTypeSwingLeftRight)];
        }
        
        enableFuncList = deviceSupportFunction;
    }
    
    // 构造开机功能列表
    for (NSNumber *funcType in enableFuncList) {
        
        NSDictionary *funcDict = totalFunctionsDict[funcType];
        
        AUXDeviceFunctionItem *item = [AUXDeviceFunctionItem yy_modelWithDictionary:funcDict];
        [functionList addObject:item];
        [functionsDictionary setObject:item forKey:@(item.type)];
    }
}

/// 初始化功能列表 (关机状态下)
- (void)initOffFunctionList {
    NSMutableArray<AUXDeviceFunctionItem *> *functionList = [[NSMutableArray alloc] init];
    self.offFunctionList = functionList;
    
    NSMutableDictionary<NSNumber *, AUXDeviceFunctionItem *> *functionsDictionary = self.functionsDictionary;
    
    // 当前设备可用的功能列表
    NSArray<NSNumber *> *enableFuncList = [self.deviceFeature convertToOffFunctionList];
    
    // 获取设备功能列表的配置信息
    NSDictionary<NSNumber *, NSDictionary *> *totalFunctionsDict = [AUXConfiguration getDeviceFunctionsDictionary];
    
    // 构造关机功能列表
    for (NSNumber *funcType in enableFuncList) {
        
        AUXDeviceFunctionItem *item = functionsDictionary[funcType];
        
        if (!item) {
            NSDictionary *funcDict = totalFunctionsDict[funcType];
            item = [AUXDeviceFunctionItem yy_modelWithDictionary:funcDict];
            [functionsDictionary setObject:item forKey:@(item.type)];
        }
        
        [functionList addObject:item];
    }
}

- (void)initWindArray {
    
    AUXWindSpeedGearType windSpeedGear = self.deviceFeature.windSpeedGear;
    BOOL turbo = [self.deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncWindSpeedTurbo)];
    BOOL silence = [self.deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncWindSpeedMute)];
    NSMutableArray *windSpeedArray = [NSMutableArray array];
    switch (windSpeedGear) {
        case AUXWindSpeedGearTypeThree: {
            windSpeedArray = [@[@(WindSpeedMin), @(WindSpeedMid), @(WindSpeedMax)] mutableCopy];
        }
            break;
            
        case AUXWindSpeedGearTypeFour: {
            windSpeedArray = [@[@(WindSpeedMin), @(WindSpeedMid), @(WindSpeedMax) , @(WindSpeedAuto)] mutableCopy];
        }
            break;
            
        case AUXWindSpeedGearTypeFive: {
            windSpeedArray = [@[@(WindSpeedMin), @(WindSpeedMidMin), @(WindSpeedMid), @(WindSpeedMidMax), @(WindSpeedMax)] mutableCopy];
        }
            break;
            
        case AUXWindSpeedGearTypeSix: {
            windSpeedArray = [@[@(WindSpeedMin), @(WindSpeedMidMin), @(WindSpeedMid), @(WindSpeedMidMax), @(WindSpeedMax) , @(WindSpeedAuto)] mutableCopy];
        }
            break;
            
        default:
            break;
    }
    
    if (silence) {
        [windSpeedArray insertObject:@(WindSpeedSilence) atIndex:0];
    }
    
    if (turbo) {
        [windSpeedArray insertObject:@(WindSpeedTurbo) atIndex:windSpeedArray.count - 1];
    }
    
    NSMutableArray<AUXDeviceFunctionItem *> *windArrayList = [NSMutableArray array];
    // 获取设备功能列表的配置信息
    NSDictionary<NSNumber *, NSDictionary *> *totalWindsDict = [AUXConfiguration getDeviceWindsDictionary];
    // 构造关机功能列表
    for (NSNumber *funcType in windSpeedArray) {
        
        AUXDeviceFunctionItem *item = [[AUXDeviceFunctionItem alloc]init];
        
        NSDictionary *funcDict = totalWindsDict[funcType];
        item = [AUXDeviceFunctionItem yy_modelWithDictionary:funcDict];
        [windArrayList addObject:item];
    }
    
    self.windArrayList = windArrayList;
}

- (void)initModeArray {
    NSMutableArray *modeArray = [NSMutableArray arrayWithArray:@[
                                                  @(AirConFunctionCool),
                                                  @(AirConFunctionHeat), @(AirConFunctionDehumidify),@(AirConFunctionVentilate),@(AirConFunctionAuto)]];
    
    
    
    NSMutableArray *removeArray = [NSMutableArray array];
    NSArray <NSNumber *>*airConModesArray = [self.deviceFeature convertToAirConFunctionModeList];
    for (NSNumber *mode in modeArray) {
        if (![airConModesArray containsObject:mode]) {
            [removeArray addObject:mode];
        }
    }
    
    if (self.controlType == AUXDeviceControlTypeDevice) {
        
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        NSString *addressString = deviceInfo.addressArray.firstObject;
        AUXACStatus *deviceStatus = deviceInfo.device.statusDic[addressString];
        AUXDeviceFeature *deviceFeature = deviceInfo.deviceFeature;
        NSInteger coolType = deviceFeature.coolType.firstObject ? deviceFeature.coolType.firstObject.integerValue : 1;
        if (!deviceStatus.supportHeat || !coolType) {
            [removeArray addObject:@(AirConFunctionHeat)];
        }
    }
    
        [modeArray removeObjectsInArray:removeArray];

    
    if (![modeArray containsObject:@(AirConFunctionHeat)]) {
        self.onlyCoolDevice = YES;
    }
    
    NSMutableArray<AUXDeviceFunctionItem *> *modeArrayList = [NSMutableArray array];
    // 获取设备功能列表的配置信息
    NSDictionary<NSNumber *, NSDictionary *> *totalModesDict = [AUXConfiguration getDeviceModesDictionary];
    // 构造关机功能列表
    for (NSNumber *funcType in modeArray) {
        
        AUXDeviceFunctionItem *item = [[AUXDeviceFunctionItem alloc]init];
        
        NSDictionary *funcDict = totalModesDict[funcType];
        item = [AUXDeviceFunctionItem yy_modelWithDictionary:funcDict];
        [modeArrayList addObject:item];
    }
    
    self.modeArrayList = modeArrayList;
}

- (void)initCurveModel {
    // 集中控制不显示用电曲线
    if (self.controlType == AUXDeviceControlTypeSceneMultiDevice || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
        return;
    }

    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    // 初始化日历，用于查询用电曲线
    
    self.calendar = [NSCalendar currentCalendar];
    self.date = [NSDate date];
    self.dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:self.date];
    self.curveDateType = AUXElectricityCurveDateTypeDay;
    
    self.electricityConsumptionCurveModel = [[AUXElectricityConsumptionCurveModel alloc] init];
    self.electricityConsumptionCurveModel.dateType = self.curveDateType;
    self.electricityConsumptionCurveModel.source = deviceInfo.source;
    [self.electricityConsumptionCurveModel setCurrentDateWithComponents:self.dateComponents];
    [self.electricityConsumptionCurveModel setRequestDateWithComponents:self.dateComponents];
}

- (void)initConfigDict {
    
    [self.configDict setObject:@(self.onlyCoolDevice) forKey:@"onlyCoolDevice"];
    
    if (!AUXWhtherNullString(self.alis)) {
        [self.configDict setObject:self.alis forKey:@"alis"];
    }
    if (self.deviceInfoArray) {
        [self.configDict setObject:self.deviceInfoArray forKey:@"deviceInfoArray"];
    }
    if (self.deviceFeature) {
        [self.configDict setObject:self.deviceFeature forKey:@"deviceFeature"];
    }
    if (self.virtualDeviceControl) {
        [self.configDict setObject:self.virtualDeviceControl forKey:@"virtualDeviceControl"];
    }
    if (self.deviceStatus) {
        [self.configDict setObject:self.deviceStatus forKey:@"deviceStatus"];
    }
    if (self.onFunctionList) {
        [self.configDict setObject:self.onFunctionList forKey:@"onFunctionList"];
    }
    
    if (self.onTableViewSectionItemArray) {
        [self.configDict setObject:self.onTableViewSectionItemArray forKey:@"onTableViewSectionItemArray"];
    }
    if (self.offFunctionList) {
        [self.configDict setObject:self.offFunctionList forKey:@"offFunctionList"];
    }
    if (self.offTableViewSectionItemArray) {
        [self.configDict setObject:self.offTableViewSectionItemArray forKey:@"offTableViewSectionItemArray"];
    }
    if (self.functionsDictionary) {
        [self.configDict setObject:self.functionsDictionary forKey:@"functionsDictionary"];
    }
    if (self.tableViewSectionItemDictionary) {
        [self.configDict setObject:self.tableViewSectionItemDictionary forKey:@"tableViewSectionItemDictionary"];
    }
    if (self.windArrayList) {
        [self.configDict setObject:self.windArrayList forKey:@"windArrayList"];
    }
    if (self.modeArrayList) {
        [self.configDict setObject:self.modeArrayList forKey:@"modeArrayList"];
    }
    
    if (self.configBlock) {
        self.configBlock(self.configDict);
    }
}

/// 获取集中控制功能列表
- (void)getMultiControlFunctionListWithDeviceInfoArray {
    
    AUXDeviceFeature *multiDeviceFeature = [AUXDeviceFeature multiDeviceFeature];
    
    self.deviceFeature = multiDeviceFeature;
    if (multiDeviceFeature) {
        return;
    }
    
    [self delegateRespondShowLoading];
    [[AUXNetworkManager manager] getMultiControlFunctionListWithCompletion:^(NSString * _Nullable feature, NSError * _Nonnull error) {
        [self delegateRespondHideLoading];
        
        if (error.code == AUXNetworkErrorAccountCacheExpired) {
            [self delegateRespondAccountCacheExpired];
            return;
        }
        
        AUXDeviceFeature *deviceFeature;
        if (error.code == AUXNetworkErrorNone) {
            deviceFeature = [[AUXDeviceFeature alloc] initWithJSON:feature];
            deviceFeature.hasDeviceInfo = NO;
        } else {
            deviceFeature = [AUXDeviceFeature createDefaultMultiDeviceFeature];
        }
        
        self.deviceFeature = deviceFeature;
        [AUXDeviceFeature setMultiDeviceFeature:deviceFeature];
        
        if (self.deviceFeature) {
            [self initConfigDeviceInfo];
            [self initConfigDict];
        }
    }];
}

- (void)getDeviceDataInfo {
    
    switch (self.controlType) { // 单控
        case AUXDeviceControlTypeDevice:
        case AUXDeviceControlTypeSubdevice:
            // 获取睡眠DIY列表
            [self getSleepDIYList];
            // 获取定时列表
            [self getSchedulerList];
            // 获取用电曲线
            [self getElectricityConsumptionCurve];
            break;
            
        case AUXDeviceControlTypeVirtual:   // 虚拟体验
            [self getElectricityConsumptionTestData];
            break;
            
        default:
            break;
    }
}

- (void)deviceRemoveDelegate {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    AUXACDevice *device = deviceInfo.device;
    
    if ([device.delegates.allObjects containsObject:self]) {
        [device.delegates removeObject:self];
    }
}

#pragma mark 界面更新

/// 更新设备控制状态 (集中控制不要调用该方法)
- (void)updateStatusWithSDKControl:(AUXACControl *)deviceControl {
    
    if (!deviceControl) {
        return;
    }
    
    // 更新状态
    [self.deviceStatus updateWithControl:deviceControl];
    self.deviceStatus.powerOn = deviceControl.onOff;
    [self updateFunctionStatusWithStatus:self.deviceStatus];
    [self delegateRespondAUXDeviceStatus:self.deviceStatus];
}

/// 更新设备运行状态 (集中控制不要调用该方法)
- (void)updateStatusWithSDKStatus:(AUXACStatus *)deviceStatus {
    if (!deviceStatus) {
        return;
    }
    
    if (deviceStatus.roomTemperatureDecimal >= 100) {
        deviceStatus.roomTemperatureDecimal = (CGFloat)deviceStatus.roomTemperatureDecimal / 100;
    } else if (deviceStatus.roomTemperatureDecimal >= 10) {
        deviceStatus.roomTemperatureDecimal = (CGFloat)deviceStatus.roomTemperatureDecimal / 10;
    }
    self.deviceStatus.roomTemperature = (CGFloat)deviceStatus.roomTemperature + (CGFloat)deviceStatus.roomTemperatureDecimal / 10;
    
    // 故障信息
    self.deviceStatus.fault = [deviceStatus getFault];
    
    [self delegateRespondAUXDeviceStatus:self.deviceStatus];
}

- (void)updateFunctionStatusWithStatus:(AUXDeviceStatus *)deviceStatus {
    // 更新功能列表的状态
    for (AUXDeviceFunctionItem *item in self.functionsDictionary.allValues) {
        [self updateFunctionItem:item deviceStatus:deviceStatus];
    }
    
    for (AUXDeviceFunctionItem *item in self.onFunctionList) {
        [self updateFunctionItem:item deviceStatus:deviceStatus];
    }

    for (AUXDeviceFunctionItem *item in self.offFunctionList) {
        [self updateFunctionItem:item deviceStatus:deviceStatus];
    }
    
    NSMutableArray *tmparr = self.onFunctionList.mutableCopy;
    for (AUXDeviceFunctionItem *item in tmparr) {
        item.disabled = NO;
        
        if ([item.title isEqualToString:@"童锁"]) {
            continue;
        }
        item.disabled = deviceStatus.childLock;
        
        if (item.type == AUXDeviceFunctionTypeECO && deviceStatus.mode != AirConFunctionCool) { //ECO 制冷模式无法开启
            item.disabled = YES;
        }
        
        if (item.type == AUXDeviceFunctionTypeElectricalHeating && deviceStatus.mode != AirConFunctionHeat) {   //电加热只能在制热模式开启
            item.disabled = YES;
        }
        
        if (item.type == AUXDeviceFunctionTypeSleep && (deviceStatus.mode == AirConFunctionVentilate || deviceStatus.sleepDIY)) {   //睡眠模式  送风模式无法开启，睡眠DIY下无法开启
            item.disabled = YES;
        }
        
        if (item.type == AUXDeviceFunctionTypeComfortWind) { //舒适风 在非制冷模式 或 自动风下无法开启
            
            if (deviceStatus.mode != AirConFunctionCool) {
                item.disabled = YES;
            }
            
            if (deviceStatus.convenientWindSpeed == WindSpeedAuto && !deviceStatus.comfortWind) {
                item.disabled = YES;
            }
            
        }
        
        if (item.type == AUXDeviceFunctionTypeHot && self.onlyCoolDevice) { //单冷机制热无法使用
            item.disabled = YES;
        }

    }
    self.onFunctionList = tmparr.mutableCopy;
    
    for (AUXDeviceFunctionItem *item in self.offFunctionList) {
        if ([item.title isEqualToString:@"童锁"]) {
            continue;
        }
        item.disabled = deviceStatus.childLock;
    }
    
    
}

- (void)updateFunctionItem:(AUXDeviceFunctionItem *)item deviceStatus:(AUXDeviceStatus *)deviceStatus {
    switch (item.type) {
        case AUXDeviceFunctionTypePower:   // 开关
            item.selected = deviceStatus.powerOn;
            break;
            
        case AUXDeviceFunctionTypeCold:   // 制冷
            item.selected = (deviceStatus.powerOn && deviceStatus.mode == AirConFunctionCool ? YES : false);
            break;
            
        case AUXDeviceFunctionTypeHot:   // 制热
            item.selected = (deviceStatus.powerOn && deviceStatus.mode == AirConFunctionHeat ? YES : false);
            break;
            
        case AUXDeviceFunctionTypeSwingLeftRight:   // 左右摆风
            item.selected = deviceStatus.swingLeftRight;
            break;
            
        case AUXDeviceFunctionTypeSwingUpDown:      // 上下摆风
            item.selected = deviceStatus.swingUpDown;
            break;
            
        case AUXDeviceFunctionTypeDisplay: {    // 屏显: 关闭、开启、自动
            item.selected = deviceStatus.screenOnOff;
            
            if ((deviceStatus.autoScreen && self.deviceFeature.screenGear == AUXDeviceScreenGearThree) || deviceStatus.screenOnOff) {
                NSDictionary *iconsDict = [AUXConfiguration getDeviceFunctionScreenIcon:deviceStatus.autoScreen];
                [item yy_modelSetWithDictionary:iconsDict];
            }
        }
            break;
            
        case AUXDeviceFunctionTypeECO:  // ECO
            item.selected = deviceStatus.eco;
            break;
            
        case AUXDeviceFunctionTypeElectricalHeating:    // 电加热
            item.selected = deviceStatus.electricHeating;
            break;
            
        case AUXDeviceFunctionTypeChildLock:    // 童锁
            item.selected = deviceStatus.childLock;
            break;
            
        case AUXDeviceFunctionTypeHealth:   // 健康
            item.selected = deviceStatus.healthy;
            break;
            
        case AUXDeviceFunctionTypeSleep:    // 睡眠
            item.selected = deviceStatus.sleepMode;
            break;
        case AUXDeviceFunctionTypeLimitElectricity:    // 用电限制
            item.selected = deviceStatus.powerLimit;
            break;
            
        case AUXDeviceFunctionTypeComfortWind:    // 舒适风
            item.selected = deviceStatus.comfortWind;
            break;
            
        case AUXDeviceFunctionTypeClean:    // 清洁
            item.selected = deviceStatus.clean;
            break;
            
        case AUXDeviceFunctionTypeMouldProof:    // 防霉
            item.selected = deviceStatus.antiFungus;
            break;
            
        case AUXDeviceFunctionTypeScheduler:    // 定时
            item.selected = deviceStatus.scheduler;
            break;
            
        default:
            break;
    }
}

#pragma mark 获取服务器睡眠DIY列表
- (void)getSleepDIYList {
    
    // 设备不支持睡眠DIY
    if (![self.deviceFeature.appSupportFuncs containsObject:@(AUXAppSupportFuncSleepDIY)]) {
        return;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    // 虚拟体验
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    [[AUXNetworkManager manager] getSleepDIYListWithDeviceId:deviceInfo.deviceId completion:^(NSArray<AUXSleepDIYModel *> * _Nullable sleepDIYList, NSError * _Nonnull error) {
        
        if (error.code == AUXNetworkErrorNone) {
            if (sleepDIYList && sleepDIYList.count > 0) {
                self.sleepDIYList = [NSMutableArray arrayWithArray:sleepDIYList];
                
                if (deviceInfo.source == AUXDeviceSourceBL) {
                    // 旧设备，查询设备上设置的睡眠DIY节点列表
                    [self queryDeviceSleepDIYPoints];
                }
            } else {
                self.sleepDIYList = nil;
            }
            [self delegateRespondSleepDIYModels:[self.sleepDIYList copy]];
        } else if (error.code == AUXNetworkErrorAccountCacheExpired) {
            [self delegateRespondAccountCacheExpired];
        }
    }];
}

/// 关闭所有正在开启的睡眠DIY
- (void)turnOffAllSleepDIY {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice || deviceInfo.source == AUXDeviceSourceBL) {
        return;
    }
    
    BOOL shouldTurnOff = NO;
    
    for (AUXSleepDIYModel *sleepDIYModel in self.sleepDIYList) {
        if (sleepDIYModel.on) {
            sleepDIYModel.on = NO;
            
            shouldTurnOff = YES;
        }
    }
    
    if (!shouldTurnOff) {
        return;
    }
    
    [[AUXNetworkManager manager] turnOffAllSleepDIYWithDeviceId:deviceInfo.deviceId completion:^(NSError * _Nonnull error) {
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self.sleepDIYList removeAllObjects];
                [self delegateRespondSleepDIYModels:self.sleepDIYList];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark 获取定时列表
- (void)getSchedulerList {
    if (!self.deviceFeature.hasScheduler) {
        return;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    if (deviceInfo.device.bLDevice) {
        // 旧设备的定时保存在设备上
        [[AUXACNetwork sharedInstance] getTimerListOfDevice:deviceInfo.device hardwareType:self.hardwaretype];
    } else {
        
        NSString *address = nil;
        
        if (deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
            address = deviceInfo.addressArray.firstObject;
        }
        
        [[AUXNetworkManager manager] getSchedulerListWithDeviceId:deviceInfo.deviceId address:address completion:^(NSArray<AUXSchedulerModel *> * _Nullable schedulerList, NSError * _Nonnull error) {
            
            switch (error.code) {
                case AUXNetworkErrorNone:
                    [self delegateRespondSchedulerInfo:schedulerList];
                    break;
                    
                case AUXNetworkErrorAccountCacheExpired:
                    [self delegateRespondAccountCacheExpired];
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

#pragma mark 查询用电曲线
- (void)getElectricityConsumptionCurve {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    // 设备不支持用电曲线
    if (![self.deviceFeature.appSupportFuncs containsObject:@(AUXAppSupportFuncElectricityConsumptionCurve)]) {
        return;
    }
    
    // 从古北云查询旧设备的用电曲线
    if (deviceInfo.device.bLDevice) {
        NSString *mac = deviceInfo.mac;
        
        BOOL isToday = NO;
        if (self.curveDateType == AUXElectricityCurveDateTypeDay) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if ([[formatter stringFromDate:[NSDate date]] isEqualToString:[formatter stringFromDate:self.date]]) {
                isToday = YES;
            }
        }
        
        if (isToday) {
            [[AUXNetworkManager manager] getTodayElectricityConsumptionCurveWithMac:mac completion:^(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable pointModelArray, NSError * _Nonnull error) {
                if (error.code == AUXNetworkErrorNone) {
                    self.electricityConsumptionCurveModel.pointModelList = pointModelArray;
                    
                    [self delegateRespondElectricityConsumptionCurveInfo:self.electricityConsumptionCurveModel];
                }
            }];
        } else {
            [[AUXNetworkManager manager] getElectricityConsumptionCurveWithMac:mac subIndex:0 date:self.date dateType:self.curveDateType completion:^(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable pointModelArray, NSError * _Nonnull error) {
                
                if (error.code == AUXNetworkErrorNone) {
                    self.electricityConsumptionCurveModel.pointModelList = pointModelArray;
                    
                    [self delegateRespondElectricityConsumptionCurveInfo:self.electricityConsumptionCurveModel];
                }
            }];
        }
    } else {
        [[AUXNetworkManager manager] getElectricityConsumptionCurveWithDid:deviceInfo.did date:self.date dateType:self.curveDateType completion:^(AUXElectricityConsumptionCurveModel * _Nullable curveModel, NSError * _Nonnull error) {
            
            switch (error.code) {
                case AUXNetworkErrorNone:
                    [self.electricityConsumptionCurveModel updatePowerCurveDatasWithModel:curveModel];
                    [self.electricityConsumptionCurveModel analysePowerCurveDatas];
                    
                    [self delegateRespondElectricityConsumptionCurveInfo:self.electricityConsumptionCurveModel];
                    break;
                    
                case AUXNetworkErrorAccountCacheExpired:
                    [self delegateRespondAccountCacheExpired];
                    break;
                    
                default:
                    break;
            }
        }];
    }
}

/// 用的曲线测试数据
- (void)getElectricityConsumptionTestData {
    
    switch (self.curveDateType) {
        case AUXElectricityCurveDateTypeYear:
            [self.electricityConsumptionCurveModel setYearTestData];
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            [self.electricityConsumptionCurveModel setMonthTestData];
            break;
            
        default:
            [self.electricityConsumptionCurveModel setDayTestData];
            break;
    }
    
    [self delegateRespondElectricityConsumptionCurveInfo:self.electricityConsumptionCurveModel];
}

#pragma mark 获取故障列表
- (void)getFaultList {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    // 设备不支持故障报警
    if (!self.deviceFeature.hasFault) {
        return;
    }
    
    // 旧设备的故障信息附带在设备运行状态里面 (旧设备没有滤网信息)
    if (!deviceInfo.device || deviceInfo.device.bLDevice) {
        return;
    }
    
    // 新设备的故障信息也附带在设备运行状态里面，这里查询服务器，只是为了获取滤网信息。
    [[AUXNetworkManager manager] getFaultListWithMac:deviceInfo.mac completion:^(NSArray<AUXFaultInfo *> * _Nullable faultInfoList, NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self updateUIWithFaultList:faultInfoList];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default:
                break;
        }
    }];
}

/// 更新故障信息 (滤网信息)
- (void)updateUIWithFaultList:(NSArray<AUXFaultInfo *> *)faultList {
    
    AUXFaultInfo *filterInfo;
    
    for (AUXFaultInfo *faultInfo in faultList) {
        if ([faultInfo.faultId isEqualToString:kAUXFilterFaultId]) {
            filterInfo = faultInfo;
            break;
        }
    }
    
    self.deviceStatus.filterInfo = filterInfo;
    
    [self delegateRespondAUXDeviceStatus:self.deviceStatus];
}

#pragma mark 获取峰谷节电、智能用电设置
- (void)getPowerInfo {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    // 旧设备，通过SDK获取峰谷节电、智能用电设置
    if (deviceInfo.device.bLDevice) {
        [[AUXACNetwork sharedInstance] getPowerInfoForDevice:deviceInfo.device];
        return;
    }
    
    // 新设备，通过服务器获取峰谷节电设置
    [self getPeakValleyByServer];
    
    // 新设备，通过服务器获取智能用电设置
    [self getSmartPowerByServer];
}


#pragma mark 设备状态查询
/// 查询睡眠DIY节点 (旧设备)
- (void)queryDeviceSleepDIYPoints {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    NSString *address = deviceInfo.addressArray.firstObject;
    
    if (deviceInfo.device.bLDevice) {
        [[AUXACNetwork sharedInstance] queryDevice:deviceInfo.device withQueryType:AUXACNetworkQueryTypeSleepDIYPoints deviceType:deviceInfo.device.deviceType atAddress:address];
    }
}

#pragma mark 网络请求

#pragma mark 峰谷节电
/// 获取峰谷节电设置 (新设备，通过服务器获取)
- (void)getPeakValleyByServer {
    
    // 设备不支持峰谷节电
    if (![self.deviceFeature.appSupportFuncs containsObject:@(AUXAppSupportFuncPeakValley)]) {
        return;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    [[AUXNetworkManager manager] getPeakValleyWithDeviceId:deviceInfo.deviceId completion:^(AUXPeakValleyModel * _Nullable peakValleyModel, NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.peakValleyModel = peakValleyModel;
                [self delegateRespondPeakValleyInfo:peakValleyModel];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default:
                break;
        }
    }];
}
/// 获取峰谷节电设置 (新设备，通过服务器获取) (跳转到峰谷节电界面时调用。加个loading框)
- (void)getPeakValleyByServerWithLoading {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        [self delegateRespondPushToVC:@"AUXPeakValleyViewController"];
        return;
    }
    
    [self delegateRespondShowLoading];
    [[AUXNetworkManager manager] getPeakValleyWithDeviceId:deviceInfo.deviceId completion:^(AUXPeakValleyModel * _Nullable peakValleyModel, NSError * _Nonnull error) {
        
        [self delegateRespondHideLoading];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.peakValleyModel = peakValleyModel;
                [self delegateRespondPeakValleyInfo:self.peakValleyModel];
                [self delegateRespondPushToVC:@"AUXPeakValleyViewController"];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default: {
                
                [self delegateRespondErrorMessage:@"获取峰谷节电设置失败"];
            }
                break;
        }
    }];
}

/// 通过SDK获取峰谷节电设置 (成功之后跳转到峰谷节电界面)
- (void)getPeakValleyBySDK {
    
    // 设备不支持峰谷节电
    if (![self.deviceFeature.appSupportFuncs containsObject:@(AUXAppSupportFuncPeakValley)]) {
        return;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    [self delegateRespondShowLoading];
    self.queryPeakValleyTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getPeakValleyBySDKTimeout) userInfo:nil repeats:NO];
    
    [[AUXACNetwork sharedInstance] getPowerInfoForDevice:deviceInfo.device];
}

/// 通过SDK获取峰谷节电超时
- (void)getPeakValleyBySDKTimeout {
    [self delegateRespondHideLoading];
    self.queryPeakValleyTimer = nil;
    [self delegateRespondErrorMessage:@"获取峰谷节电设置失败"];
}

/// 关闭峰谷节电 (峰谷节电开启中，切换模式的时候，需要关闭)
- (void)turnOffPeakValley {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice || !self.peakValleyModel) {
        return;
    }
    
    if (!self.peakValleyModel.on) {
        return;
    }
    
    // 旧设备，通过SDK关闭峰谷节电
    if (deviceInfo.source == AUXDeviceSourceBL) {
        self.peakValleyModel.on = NO;
        AUXACPeakValleyPower *peakValleyPower = [self.peakValleyModel convertToSDKPeakValleyPower];
        
        [[AUXACNetwork sharedInstance] setPeakValleyPowerForDevice:deviceInfo.device peakStartTime:peakValleyPower.peakStartTime peakEndTime:peakValleyPower.peakEndTime valleyStartTime:peakValleyPower.valleyStartTime valleyEndTime:peakValleyPower.valleyEndTime enabled:peakValleyPower.enabled];
        return;
    }
    
    self.peakValleyModel.on = NO;
    
    // 新设备，通过服务器关闭峰谷节电
    [[AUXNetworkManager manager] updatePeakValley:self.peakValleyModel completion:^(NSError * _Nonnull error) {
        switch (error.code) {
            case AUXNetworkErrorNone:
                self.peakValleyModel.on = NO;
                [self delegateRespondPeakValleyInfo:self.peakValleyModel];
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark 智能用电
/// 获取智能用电规则 (新设备，通过服务器获取)
- (void)getSmartPowerByServer {
    
    // 设备不支持智能用电
    if (![self.deviceFeature.appSupportFuncs containsObject:@(AUXAppSupportFuncSmartPower)]) {
        return;
    }
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    [[AUXNetworkManager manager] getSmartPowerWithDeviceId:deviceInfo.deviceId completion:^(AUXSmartPowerModel * _Nullable smartPowerModel, NSError * _Nonnull error) {
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.smartPowerModel = smartPowerModel;
                [self delegateRespondSmartPowerInfo:smartPowerModel];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default:
                break;
        }
    }];
}

/// 获取智能用电规则 (新设备，通过服务器获取) (跳转到智能用电界面时调用。加个loading框)
- (void)getSmartPowerByServerWithLoading {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        [self delegateRespondPushToVC:@"AUXSmartPowerViewController"];
        return;
    }
    
    if (!deviceInfo.device.supportSmartPower) {
        [self delegateRespondErrorMessage:@"该设备不支持智能用电功能"];
        return;
    }
    
    [self delegateRespondShowLoading];
    
    [[AUXNetworkManager manager] getSmartPowerWithDeviceId:deviceInfo.deviceId completion:^(AUXSmartPowerModel * _Nullable smartPowerModel, NSError * _Nonnull error) {
        [self delegateRespondHideLoading];
        
        switch (error.code) {
            case AUXNetworkErrorNone: {
                self.smartPowerModel = smartPowerModel;
                [self delegateRespondSmartPowerInfo:self.smartPowerModel];
                
                [self delegateRespondPushToVC:@"AUXSmartPowerViewController"];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default: {
                [self delegateRespondErrorMessage:@"获取智能用电设置失败!"];
            }
                break;
        }
    }];
}

/// 通过SDK获取智能用电设置 (成功之后跳转到智能用电界面)
- (void)getSmartPowerBySDK {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    [self delegateRespondShowLoading];
    self.querySmartPowerTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(getSmartPowerBySDKTimeout) userInfo:nil repeats:NO];
    
    [[AUXACNetwork sharedInstance] getPowerInfoForDevice:deviceInfo.device];
}

/// 查询智能用电设置超时
- (void)getSmartPowerBySDKTimeout {
    [self delegateRespondHideLoading];
    self.querySmartPowerTimer = nil;
    [self delegateRespondErrorMessage:@"获取智能用电设置失败"];
}

/// 关闭智能用电 (智能用电开启中，切换模式的时候，需要关闭智能用电)
- (void)turnOffSmartPower {
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice || !self.smartPowerModel) {
        return;
    }
    
    if (!self.smartPowerModel.on) {
        return;
    }
    
    // 旧设备，通过SDK关闭智能用电
    if (deviceInfo.source == AUXDeviceSourceBL) {
        self.smartPowerModel.on = NO;
        AUXACSmartPower *smartPower = [self.smartPowerModel convertToSDKSmartPower];
        
        [[AUXACNetwork sharedInstance] setSmartPowerForDevice:deviceInfo.device startTime:smartPower.startTime endTime:smartPower.endTime quantity:smartPower.quantity mode:smartPower.mode enabled:smartPower.enabled];
        return;
    }
    
    self.smartPowerModel.on = NO;
    
    // 通过服务器关闭智能用电
    [[AUXNetworkManager manager] turnOffSmartPower:deviceInfo.deviceId completion:^(NSError * _Nonnull error) {
        switch (error.code) {
            case AUXNetworkErrorNone:
                self.smartPowerModel.on = NO;
                [self delegateRespondSmartPowerInfo:self.smartPowerModel];
                break;
            case AUXNetworkErrorAccountCacheExpired:
                [self delegateRespondAccountCacheExpired];
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark 设备控制
#pragma mark 命令下发
- (void)countdownToUpdateDeviceStatus {
    // 控制设备之后，3s内忽略设备上报的状态
    self.hasControlSecondsBefore = NO;
}

/// 控制设备。（单台设备控制）
- (void)controlDeviceWithControl:(AUXACControl *)deviceControl {
    if (deviceControl) {
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        NSString *address = deviceInfo.addressArray.firstObject;
        
        [self controlDevice:deviceInfo.device controlInfo:deviceControl atAddress:address];
        [self updateStatusWithSDKControl:deviceControl];
    }
}

- (void)controlDevice:(AUXACDevice *)device controlInfo:(AUXACControl *)control atAddress:(NSString *)address {
    
    if (self.controlType != AUXDeviceControlTypeSceneMultiDevice || self.controlType != AUXDeviceControlTypeGatewayMultiDevice) {
        if (self.hasControlSecondsBefore) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countdownToUpdateDeviceStatus) object:nil];
        } else {
            // 控制设备之后，3s内忽略设备上报的状态
            self.hasControlSecondsBefore = YES;
        }
        
        [self performSelector:@selector(countdownToUpdateDeviceStatus) withObject:nil afterDelay:3.0];
    }
    
    if (!device || !control) {
        return ;
    }
    [[AUXACNetwork sharedInstance] sendCommand2Device:device controlInfo:control atAddress:address withType:device.deviceType];
}

/**
 控制设备。（更改 AUXACControl 的属性）
 
 @param handler 可以在该block里更改 control 的值。返回YES表示可以控制该设备，NO则不控制设备 (用于集中控制，当某台设备不满足条件时，不下发控制命令；单控可以直接返回YES)。
 @return 某个 AUXACControl 的实例，用于界面更新。
 */
- (AUXACControl *)controlDeviceWithHandler:(BOOL (^)(AUXDeviceInfo *deviceInfo, AUXACControl *control))handler {
    
    // 用于界面更新
    AUXACControl *someControl;
    
    switch (self.controlType) {
        case AUXDeviceControlTypeVirtual: { // 虚拟体验
            AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
            
            if (handler) {
                handler(deviceInfo, self.virtualDeviceControl);
            }
            
            someControl = self.virtualDeviceControl;
        }
            break;
            
        case AUXDeviceControlTypeSceneMultiDevice:
        case AUXDeviceControlTypeGatewayMultiDevice:{ // 集中控制
            
            if (handler) {
                handler(nil, self.virtualDeviceControl);
            }
            someControl = self.virtualDeviceControl;
            
            for (AUXDeviceInfo *deviceInfo in self.deviceInfoArray) {
                
                if (!deviceInfo.device || deviceInfo.device.wifiState != AUXACNetworkDeviceWifiStateOnline) {
                    continue;
                }
                
                AUXACControl *control = [someControl copy];
                if (handler) {
                    BOOL shouldControl = handler(deviceInfo, control);
                    
                    if (!shouldControl) {
                        continue;
                    }
                }
                
                // 需要更新 windSpeed 的值，因为挂机与柜机的风速值不一样，而集中控制的虚拟设备定义为挂机
                [control setWindSpeed:self.deviceStatus.convenientWindSpeed WithType:deviceInfo.windGearType];
                
                // 单元机直接控制
                if (deviceInfo.suitType == AUXDeviceSuitTypeAC) {
                    NSString *address = deviceInfo.addressArray.firstObject;
                    
                    [self controlDevice:deviceInfo.device controlInfo:control atAddress:address];
                    
                } else {    // 多联机创建控制任务
                    for (NSString *address in deviceInfo.addressArray) {
                        
                        AUXDeviceControlQueue *controlQueue = self.controlQueueDict[deviceInfo.deviceId];
                        
                        if (!controlQueue) {
                            controlQueue = [AUXDeviceControlQueue controlQueueWithDeviceInfo:deviceInfo device:deviceInfo.device];
                            [self.controlQueueDict setObject:controlQueue forKey:deviceInfo.deviceId];
                        }
                        
                        AUXDeviceControlTask *task = [AUXDeviceControlTask controlTaskWithAddress:address control:control];
                        [controlQueue appendTask:task];
                    }
                }
            }
            
            // 启动控制任务
            for (AUXDeviceControlQueue *controlQueue in self.controlQueueDict.allValues) {
                [controlQueue start];
            }
            
        }
            break;
            
        default: {  // 单控
            [self delegateRespondShowLoading];
            
            AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
            
            if (!deviceInfo.device || deviceInfo.device.wifiState != AUXACNetworkDeviceWifiStateOnline) {
                break;
            }
            
            NSString *address = deviceInfo.addressArray.firstObject;
            
            AUXACControl *control = deviceInfo.device.controlDic[address];
            if (handler) {
                handler(deviceInfo, control);
            }
            
            someControl = control;
            
            [self controlDevice:deviceInfo.device controlInfo:control atAddress:address];
        }
            break;
    }
    return someControl;
}

/// 更改温度
- (void)controlDeviceWithTemperature:(CGFloat)temperature {
    
    int nTemperature = temperature;
    BOOL half = (temperature != (NSInteger)temperature);
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.temperature = nTemperature;
        control.half = half;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 开关机
- (void)controlDeviceWithPower:(BOOL)powerOn {
    
    if (!powerOn) {
        self.deviceStatus.mode = AirConFunctionAuto;
    }
    
    @weakify(self);
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        @strongify(self);
        [self updateControl:control withDeviceInfo:deviceInfo onOff:powerOn];
        return YES;
    }];
    
    [self updateStatusWithSDKControl:someControl];
}

/// 切换模式
- (void)controlDeviceWithMode:(AirConFunction)mode {
    
    __block BOOL shouldTurnOffSleepDIY = NO;
    
    for (AUXDeviceFunctionItem *item in self.modeArrayList) {
        if ((NSInteger)item.type == mode) {
            continue;
        }
        item.selected = NO;
    }
    
    if (mode == self.deviceStatus.mode && self.deviceStatus.powerOn) {
        return ;
    }
    
    @weakify(self);
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        @strongify(self);
        
        if (control.sleepDiy) {
            shouldTurnOffSleepDIY = YES;
        }
        
        [self updateControl:control withDeviceInfo:deviceInfo mode:mode];
        return YES;
    }];
    
    // 切换模式，关闭峰谷节电、智能用电、睡眠DIY
    if (self.deviceStatus.mode != mode) {
        switch (self.controlType) {
            case AUXDeviceControlTypeDevice:        // 单控
            case AUXDeviceControlTypeSubdevice:
                [self turnOffPeakValley];
                [self turnOffSmartPower];
                
                if (shouldTurnOffSleepDIY) {
                    [self turnOffAllSleepDIY];
                }
                break;
                
            default:
                break;
        }
    }
    
    [self updateStatusWithSDKControl:someControl];
}

/// 更改风速
- (void)controlDeviceWithWindSpeed:(WindSpeed)windSpeed {
    
    for (AUXDeviceFunctionItem *item in self.windArrayList) {
        if ((NSInteger)item.type == windSpeed) {
            continue;
        }
        item.selected = NO;
    }
    
    @weakify(self);
    [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        @strongify(self);
        
        self.deviceStatus.convenientWindSpeed = windSpeed;
        control.comfortWind = NO;
        control.turbo = self.deviceStatus.turbo;
        control.silence = self.deviceStatus.silence;
        [control setWindSpeed:self.deviceStatus.convenientWindSpeed WithType:deviceInfo.windGearType];
        
        self.deviceStatus.comfortWind = NO;
        self.deviceStatus.swingUpDown = control.upDownSwing == 0 || control.upDownSwing == 6 ? true : false;
        self.deviceStatus.swingLeftRight = control.leftRightSwing == 0 || control.leftRightSwing ==  4 ? true : false;
        
        self.deviceStatus.sleepMode = control.sleepMode;
        self.deviceStatus.sleepDIY = control.sleepDiy;
        
        [self updateFunctionStatusWithStatus:self.deviceStatus];
        [self delegateRespondAUXDeviceStatus:self.deviceStatus];
        
        return YES;
    }];
}

/// 上下摆风
- (void)controlDeviceWithSwingUpDown:(BOOL)swingUpDown {
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {

        control.comfortWind = NO;
        control.upDownSwing = swingUpDown ? 0 : 7;
        
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 左右摆风
- (void)controlDeviceWithSwingLeftRight:(BOOL)swingLeftRight {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        
        control.comfortWind = NO;
        control.leftRightSwing = swingLeftRight ? 0 : 7;
        
        return YES;
    }];
    
    [self updateStatusWithSDKControl:someControl];
}

/**
 屏显
 
 @param screenOnOff 开启、关闭
 @param autoScreen 自动屏显
 */
- (void)controlDeviceWithScreenOnOff:(BOOL)screenOnOff autoScreen:(BOOL)autoScreen {
    
    BOOL screenOnOff2 = screenOnOff || autoScreen;
    
    AUXDeviceFunctionItem *item = self.functionsDictionary[@(AUXDeviceFunctionTypeDisplay)];
    item.selected = screenOnOff2;
    
    if (screenOnOff2 || (autoScreen && self.deviceFeature.screenGear == AUXDeviceScreenGearThree)) {
        NSDictionary *iconsDict = [AUXConfiguration getDeviceFunctionScreenIcon:autoScreen];
        [item yy_modelSetWithDictionary:iconsDict];
    }
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.screenOnOff = screenOnOff;
        control.autoScreen = autoScreen;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// ECO
- (void)controlDeviceWithECO:(BOOL)eco {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.eco = eco;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 电加热
- (void)controlDeviceWithElectricHeating:(BOOL)electricHeating {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.electricHeating = electricHeating;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 童锁
- (void)controlDeviceWithChildLock:(BOOL)childLock {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.electricLock = childLock;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 清洁
- (void)controlDeviceWithClean:(BOOL)clean {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.clean = clean;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 防霉
- (void)controlDeviceWithAntiFungus:(BOOL)antiFungus {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.antiFungus = antiFungus;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 健康
- (void)controlDeviceWithHealthy:(BOOL)healthy {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.healthy = healthy;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 清新
- (void)controlDeviceWithAirFreshing:(BOOL)airFreshing {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.airFreshing = airFreshing;
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 睡眠模式
- (void)controlDeviceWithSleepMode:(BOOL)sleepMode {
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.sleepMode = sleepMode;
        control.comfortWind = NO;
        
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}

/// 舒适风
- (void)controlDeviceWithComfortWind:(BOOL)comfortWind {
    
    AUXACControl *someControl = [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        control.comfortWind = comfortWind;
        control.sleepMode = NO;
        control.sleepDiy = NO;
        
        return YES;
    }];
    [self updateStatusWithSDKControl:someControl];
}


/// 睡眠DIY (旧设备)
- (void)controlDeviceWithSleepDIY:(BOOL)on sleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    if (deviceInfo.virtualDevice) {
        return;
    }
    
    self.currentSleepDIYModel = [[AUXSleepDIYModel alloc] init];
    self.currentSleepDIYModel = sleepDIYModel;
    self.currentSleepDIYOperation = on;
    
    if (on) {
        NSArray<AUXACSleepDIYPoint *> *sleepDIYPointArray = [sleepDIYModel convertToACSleepDIYPointArray];
        [[AUXACNetwork sharedInstance] setSleepDIYPointsForDevice:deviceInfo.device sleepDIYPoints:sleepDIYPointArray];
    } else {
        [self controlDeviceWithSleepDIY:on mode:sleepDIYModel.mode];
    }
}

/// 睡眠DIY (旧设备)
- (void)controlDeviceWithSleepDIY:(BOOL)on mode:(AUXServerDeviceMode)mode {
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
    
    NSString *address = deviceInfo.addressArray.firstObject;
    AUXACControl *control = deviceInfo.device.controlDic[address];
    
    control.sleepDiy = on;
    
    control.airConFunc = (mode == AUXServerDeviceModeCool) ? AirConFunctionCool : AirConFunctionHeat;
    [self controlDeviceWithControl:control];
}

/// 用电限制
- (void)controlDeviceWithElectricityLimit:(BOOL)on percentage:(NSInteger)percentage {
    
    [self controlDeviceWithHandler:^(AUXDeviceInfo *deviceInfo, AUXACControl *control) {
        if (on) {
            control.powerLimitPercent = percentage;
        }
        
        control.powerLimit = on;
        return YES;
    }];
}

#pragma mark 互斥逻辑处理
- (void)updateControl:(AUXACControl *)control withDeviceInfo:(AUXDeviceInfo *)deviceInfo onOff:(BOOL)onOff {
    
    // 是否支持电加热
    BOOL supportElectricHeating = [self.deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncElectricalHeating)];
    
    AUXDeviceSuitType suitType;
    
    if (deviceInfo) {
        suitType = deviceInfo.suitType;
    } else {
        suitType = AUXDeviceSuitTypeAC;
    }
    
    control.onOff = onOff;
    
    if (onOff) {
        // 开机：取消清洁、如为制热模式打开电加热
        control.clean = NO;
        
        // 单元机，制热模式强制开启电加热
        if (supportElectricHeating && suitType == AUXDeviceSuitTypeAC && control.airConFunc == AirConFunctionHeat) {
            control.electricHeating = YES;
        }
    } else {
        // 关机：取消静音、取消强力、取消睡眠、取消电加热、取消ECO、取消健康
        control.silence = NO;
        control.turbo = NO;
        control.sleepMode = NO;
        control.electricHeating = NO;
        control.eco = NO;
        control.healthy = NO;
        control.powerLimit = NO;

        if (self.deviceStatus.sleepDIY) {
            [self turnOffAllSleepDIY];
        }
        control.sleepDiy = NO;
        [self turnOffPeakValley];
        [self turnOffSmartPower];
    }
}

- (void)updateControl:(AUXACControl *)control withDeviceInfo:(AUXDeviceInfo *)deviceInfo mode:(AirConFunction)mode {
    
    // 是否支持电加热
    BOOL supportElectricHeating = [self.deviceFeature.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncElectricalHeating)];
    WindGearType gearType;
    AUXDeviceSuitType suitType;
    
    if (deviceInfo) {
        gearType = deviceInfo.windGearType;
        suitType = deviceInfo.suitType;
    } else {
        gearType = self.deviceStatus.windGearType;
        suitType = AUXDeviceSuitTypeAC;
    }
    
    // 切换模式的时候，如果设备关机了，需要将设备打开
    if (!control.onOff) {
        [self updateControl:control withDeviceInfo:deviceInfo onOff:YES];
    }
    
    control.airConFunc = mode;
    
    // 模式切换：取消静音、取消强力、取消睡眠、取消电加热、取消ECO
    
    if (control.silence || control.turbo) {
        control.silence = NO;
        control.turbo = NO;
    }
    
    control.sleepMode = NO;
    control.electricHeating = NO;
    control.eco = NO;
    
    // 模式切换：关闭睡眠DIY
    control.sleepDiy = NO;
    
    switch (mode) {
        case AirConFunctionAuto:
            // 从其他模式转到自动模式，设定温度变为24度
            control.temperature = 24;
            control.half = NO;
            break;
            
        case AirConFunctionVentilate: {
            // 从其他模式转到送风模式，如果当前是自动风，则设置为低风
            WindSpeed windSpeed = [control getWindSpeedWithType:gearType];
            if (windSpeed == WindSpeedAuto) {
                [control setWindSpeed:WindSpeedMin WithType:gearType];
            }
        }
            break;
            
        case AirConFunctionHeat:
            // 单元机，切换至制热模式强制开启电加热
            if (supportElectricHeating && suitType == AUXDeviceSuitTypeAC) {
                control.electricHeating = YES;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark AUXACDeviceProtocol
- (void)auxACNetworkDidSendCommandForDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error {
    
    [self delegateRespondHideLoading];
    
    
    if (!success) {
        
        if (self.controlType == AUXDeviceControlTypeSceneMultiDevice || self.controlType == AUXDeviceControlTypeGatewayMultiDevice) {
            return ;
        }
        [self delegateRespondErrorMessage:@"通讯异常，请稍后重试"];
    } else {
        [self delegateRespondAUXDeviceStatus:self.deviceStatus];
    }
}

- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSArray *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type {
    
    if (success) {
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray.firstObject;
        
        if (!deviceInfo || deviceInfo.virtualDevice) {
            return;
        }
        
        if (![device isEqual:deviceInfo.device]) {
            return;
        }
        
        NSString *addressString = deviceInfo.addressArray.firstObject;
        
        switch (type) {
            case AUXACNetworkQueryTypeControl: {
                AUXACControl *deviceControl = device.controlDic[addressString];
                
                if (!deviceControl) {
                    break;
                }
                
                if (self.hasControlSecondsBefore) {
                    break;
                }
                
                [self updateStatusWithSDKControl:deviceControl];
                //[self delegateRespondAUXACControl:deviceControl];
            }
                break;
                
            case AUXACNetworkQueryTypeStatus: {
                AUXACStatus *deviceStatus = device.statusDic[addressString];
                
                if (!deviceStatus) {
                    break;
                }
                
                // 设备控制若干秒之内忽略设备上报的状态
                if (self.hasControlSecondsBefore) {
                    break;
                }
                
                [self updateStatusWithSDKStatus:deviceStatus];
                [self delegateRespondAUXACStatus:deviceStatus];
            }
                break;
                
            case AUXACNetworkQueryTypeSleepDIYPoints: {
                if (device.bLDevice.sleepDIYPoints) {
                    [self delegateRespondSleepDIYPoints:device.bLDevice.sleepDIYPoints];
                }
            }
                break;
                
            case AUXACNetworkQueryTypeAliasOfSubDevice:
            case AUXACNetworkQueryTypeAliasesOfSubDevices: {
                NSString *alias = device.aliasDic[addressString];
                self.alis = alias;
                
                if (!AUXWhtherNullString(self.alis)) {
                    [self.configDict setObject:self.alis forKey:@"alis"];
                    
                    if (self.configBlock) {
                        self.configBlock(self.configDict);
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)auxACNetworkDidGetTimerListOfDevice:(AUXACDevice *)device timerList:(NSArray *)timerList cycleTimerList:(NSArray *)cycleTimerList success:(BOOL)success withError:(NSError *)error {
    if (success) {
        [self delegateRespondSchedulerInfo:[AUXSchedulerModel schedulerListFromSDKCycleTimerList:cycleTimerList]];
    }
}

- (void)auxACNetworkDidGetPowerInfoForDevice:(AUXACDevice *)device peakValleyPower:(AUXACPeakValleyPower *)peakValleyPower smartPower:(AUXACSmartPower *)smartPower success:(BOOL)success withError:(NSError *)error {
    if (success || error.code == -20001) {
        // 更新峰谷节电
        if (peakValleyPower) {
            if (!self.peakValleyModel) {
                self.peakValleyModel = [[AUXPeakValleyModel alloc] init];
            }
            [self.peakValleyModel setValueWithSDKPeakValleyPower:peakValleyPower];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self delegateRespondPeakValleyInfo:self.peakValleyModel];
                
                if (self.queryPeakValleyTimer) {
                    [self timerInvalidateWithTimer:self.queryPeakValleyTimer Completion:^{
                        [self delegateRespondHideLoading];
                        [self delegateRespondPushToVC:@"AUXPeakValleyViewController"];
                    }];
                }
            });
        }
        
        // 更新智能用电
        if (smartPower) {
            if (!self.smartPowerModel) {
                self.smartPowerModel = [[AUXSmartPowerModel alloc] init];
            }
            [self.smartPowerModel setValueWithSDKSmartPower:smartPower];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self delegateRespondSmartPowerInfo:self.smartPowerModel];
                
                if (self.querySmartPowerTimer) {
                    [self timerInvalidateWithTimer:self.querySmartPowerTimer Completion:^{
                        [self delegateRespondHideLoading];
                        [self delegateRespondPushToVC:@"AUXSmartPowerViewController"];
                    }];
                }
            });
        }
    } else {
        
        if (self.queryPeakValleyTimer) {
            
            [self timerInvalidateWithTimer:self.queryPeakValleyTimer Completion:^{
                [self delegateRespondHideLoading];
                [self delegateRespondErrorMessage:@"获取峰谷节电设置失败"];
            }];
            
        } else if (self.querySmartPowerTimer) {
            [self timerInvalidateWithTimer:self.querySmartPowerTimer Completion:^{
                [self delegateRespondHideLoading];
                [self delegateRespondErrorMessage:@"获取智能用电设置失败"];
            }];
        }
    }
}

- (void)auxACNetworkDidSetSleepDIYPointsForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    if (success) {
        [self queryDeviceSleepDIYPoints];
        
        if (self.currentSleepDIYModel==nil) {
            return;
        }
        [self controlDeviceWithSleepDIY:self.currentSleepDIYOperation mode:self.currentSleepDIYModel.mode];
    } else {
        [self delegateRespondHideLoading];
    }
}

- (void)auxACNetworkDidGetFirmwareVersionForDevice:(AUXACDevice *)device firmwareVersion:(int)firmwareVersion success:(BOOL)success withError:(NSError *)error {
    if (firmwareVersion == 28) {
        self.hardwaretype = BroadlinkTimerTypeMVL;
        
        if (self.hardwaretypeBlock) {
            self.hardwaretypeBlock(self.hardwaretype);
        }
        
        [self getSchedulerList];
    }
}

- (void)timerInvalidateWithTimer:(NSTimer *)timer Completion:(void (^)(void))completion {
    [timer invalidate];
    timer = nil;
    completion();
}

#pragma mark setter & getter
- (NSMutableDictionary<NSString *,AUXDeviceControlQueue *> *)controlQueueDict {
    if (!_controlQueueDict) {
        _controlQueueDict = [[NSMutableDictionary alloc] init];
    }
    return _controlQueueDict;
}

- (NSMutableDictionary *)configDict {
    if (!_configDict) {
        _configDict = [NSMutableDictionary dictionary];
    }
    return _configDict;
}

#pragma mark private atcion

- (void)delegateRespondPushToVC:(NSString *)vcString {
    
    if (AUXWhtherNullString(vcString)) {
        return ;
    }
    
    Class vcClass = NSClassFromString(vcString);
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfPushToVC:)]) {
        [self.delegate devControlVMDelOfPushToVC:vcClass];
    }
}

- (void)delegateRespondAUXDeviceStatus:(AUXDeviceStatus *)deviceStatus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfSDKQueryAUXDeviceStatus:)]) {
        [self.delegate devControlVMDelOfSDKQueryAUXDeviceStatus:deviceStatus];
    }
}

- (void)delegateRespondAUXACStatus:(AUXACStatus *)deviceStatus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfSDKQueryAUXACStatus:)]) {
        [self.delegate devControlVMDelOfSDKQueryAUXACStatus:deviceStatus];
    }
}

- (void)delegateRespondSleepDIYModels:(NSArray<AUXSleepDIYModel *> *)sleepDIYModels {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfQuerySleepModels:)]) {
        [self.delegate devControlVMDelOfQuerySleepModels:sleepDIYModels];
    }
}

- (void)delegateRespondSleepDIYPoints:(NSArray<AUXACSleepDIYPoint *> *)sleepDIYPoints {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfSDKQuerySleepDIYPoints:)]) {
        [self.delegate devControlVMDelOfSDKQuerySleepDIYPoints:sleepDIYPoints];
    }
}

- (void)delegateRespondSchedulerInfo:(NSArray<AUXSchedulerModel *> *)schedulerList {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfSchedulerInfo:)]) {
        [self.delegate devControlVMDelOfSchedulerInfo:schedulerList];
    }
}

- (void)delegateRespondElectricityConsumptionCurveInfo:(AUXElectricityConsumptionCurveModel *)electricityConsumptionCurveModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfElectricityConsumptionCurveInfo:)]) {
        [self.delegate devControlVMDelOfElectricityConsumptionCurveInfo:electricityConsumptionCurveModel];
    }
}

- (void)delegateRespondPeakValleyInfo:(AUXPeakValleyModel *)peakValleyModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfPeakValleyInfo:)]) {
        [self.delegate devControlVMDelOfPeakValleyInfo:peakValleyModel];
    }
}

- (void)delegateRespondSmartPowerInfo:(AUXSmartPowerModel *)smartPowerModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfSmartPowerInfo:)]) {
        [self.delegate devControlVMDelOfSmartPowerInfo:smartPowerModel];
    }
}

- (void)delegateRespondFaultList:(NSArray<AUXFaultInfo *> * _Nullable)faultInfoList {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfFaultInfoList:)]) {
        [self.delegate devControlVMDelOfFaultInfoList:faultInfoList];
    }
}

- (void)delegateRespondAccountCacheExpired {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfAccountCacheExpired)]) {
        [self.delegate devControlVMDelOfAccountCacheExpired];
    }
}

- (void)delegateRespondError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfError:)]) {
        [self.delegate devControlVMDelOfError:error];
    }
}

- (void)delegateRespondErrorMessage:(NSString *)errorMessage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfErrorMessage:)]) {
        [self.delegate devControlVMDelOfErrorMessage:errorMessage];
    }
}

- (void)delegateRespondShowLoading {
    
    self.hideLoadingTimer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:DeviceControlCommondMaxTime target:self selector:@selector(hidelLoading) userInfo:nil repeats:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfShowLoading)]) {
        [self.delegate devControlVMDelOfShowLoading];
    }
}

- (void)delegateRespondHideLoading {
    if (self.delegate && [self.delegate respondsToSelector:@selector(devControlVMDelOfHideLoading)]) {
        [self.delegate devControlVMDelOfHideLoading];
    }
}

- (void)hidelLoading {
    [self delegateRespondHideLoading];
    if (self.hideLoadingTimer) {
        [self.hideLoadingTimer invalidate];
        self.hideLoadingTimer = nil;
    }
    
}

@end
