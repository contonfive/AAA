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

#ifndef AUXDefinitions_h
#define AUXDefinitions_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 设备配置类型

 - AUXDeviceConfigTypeBLDevice: 旧设备
 - AUXDeviceConfigTypeMXDevice: 庆科模组设备
 - AUXDeviceConfigTypeGizDeviceAirLink: 新设备 AirLick
 - AUXDeviceConfigTypeGizDeviceSoftAP: 新设备 SoftAP
 */
typedef NS_ENUM(NSInteger, AUXDeviceConfigType) {
    AUXDeviceConfigTypeBLDevice = 1,
    AUXDeviceConfigTypeMXDevice = 2,
    AUXDeviceConfigTypeGizDeviceAirLink = 4,
    AUXDeviceConfigTypeGizDevice = 8,
};

/**
 设备功能类型

 - AUXDeviceFunctionTypeMode: 模式
 - AUXDeviceFunctionTypeWindSpeed: 风速
 - AUXDeviceFunctionTypeSwingLeftRight: 左右摆风
 - AUXDeviceFunctionTypeSwingUpDown: 上下摆风
 - AUXDeviceFunctionTypeDisplay: 屏显
 - AUXDeviceFunctionTypeECO: ECO
 - AUXDeviceFunctionTypeElectricalHeating: 电加热
 - AUXDeviceFunctionTypeSleep: 睡眠
 - AUXDeviceFunctionTypeHealth: 健康
 - AUXDeviceFunctionTypeScheduler: 定时
 - AUXDeviceFunctionTypeSleepDIY: 睡眠DIY
 - AUXDeviceFunctionTypeElectricityConsumptionCurve: 用电曲线
 - AUXDeviceFunctionTypeLimitElectricity: 用电限制
 - AUXDeviceFunctionTypePeakValley: 峰谷节电
 - AUXDeviceFunctionTypeSmartPower: 智能用电
 - AUXDeviceFunctionTypeDeviceInfo: 设备信息
 - AUXDeviceFunctionTypeClean: 清洁
 - AUXDeviceFunctionTypeMouldProof: 防霉
 - AUXDeviceFunctionTypeElectricalStatistics: 耗电统计
 - AUXDeviceFunctionTypeChildLock: 童锁
 */
typedef NS_ENUM(NSInteger, AUXDeviceFunctionType) {
    AUXDeviceFunctionTypePower = 1,
    AUXDeviceFunctionTypeMode,
    AUXDeviceFunctionTypeCold,
    AUXDeviceFunctionTypeHot,
    AUXDeviceFunctionTypeSpeedTurbo,
    AUXDeviceFunctionTypeWindSpeed,
    AUXDeviceFunctionTypeSwingLeftRight,
    AUXDeviceFunctionTypeSwingUpDown,
    AUXDeviceFunctionTypeDisplay,
    AUXDeviceFunctionTypeECO,
    AUXDeviceFunctionTypeElectricalHeating,
    AUXDeviceFunctionTypeSleep,
    AUXDeviceFunctionTypeHealth,
    AUXDeviceFunctionTypeScheduler,
    AUXDeviceFunctionTypeSleepDIY,
    AUXDeviceFunctionTypeComfortWind,
    AUXDeviceFunctionTypeElectricityConsumptionCurve,
    AUXDeviceFunctionTypeLimitElectricity,
    AUXDeviceFunctionTypePeakValley,
    AUXDeviceFunctionTypeSmartPower,
    AUXDeviceFunctionTypeDeviceInfo,
    AUXDeviceFunctionTypeClean,
    AUXDeviceFunctionTypeMouldProof,
    AUXDeviceFunctionTypeElectricalStatistics,
    AUXDeviceFunctionTypeChildLock,
};

/**
 设备支持的功能 (用于服务器)

 - AUXDeviceSupportFuncClean: 清洁
 - AUXDeviceSupportFuncMouldProof: 防霉
 - AUXDeviceSupportFuncWindSpeedMute: 静音
 - AUXDeviceSupportFuncWindSpeedTurbo: 强力
 - AUXDeviceSupportFuncHealth: 健康
 - AUXDeviceSupportFuncECO: ECO
 - AUXDeviceSupportFuncElectricalHeating: 电加热
 - AUXDeviceSupportFuncSleep: 睡眠
 - AUXDeviceSupportFuncChildLock: 童锁
 - AUXDeviceSupportFuncSwingUpDown: 上下摆风
 - AUXDeviceSupportFuncSwingLeftRight: 左右摆风
 - AUXDeviceSupportFuncComfortWind: 舒适风
 */
typedef NS_ENUM(NSInteger, AUXDeviceSupportFunc) {
    AUXDeviceSupportFuncClean,
    AUXDeviceSupportFuncMouldProof,
    AUXDeviceSupportFuncWindSpeedMute,
    AUXDeviceSupportFuncWindSpeedTurbo,
    AUXDeviceSupportFuncHealth,
    AUXDeviceSupportFuncECO,
    AUXDeviceSupportFuncElectricalHeating,
    AUXDeviceSupportFuncSleep,
    AUXDeviceSupportFuncChildLock,
    AUXDeviceSupportFuncSwingUpDown,
    AUXDeviceSupportFuncSwingLeftRight,
    AUXDeviceSupportFuncComfortWind,
};

/**
 APP支持的功能 (用于服务器)

 - AUXAppSupportFuncSleepDIY: 睡眠DIY
 - AUXAppSupportFuncElectricityConsumptionCurve: 用电曲线
 - AUXAppSupportFuncSmartPower: 智能用电
 - AUXAppSupportFuncPeakValley: 峰谷节电
 - AUXAppSupportFuncLimitElectricity: 用电限制
 - AUXAppSupportFuncFilter: 滤网清洗
 */
typedef NS_ENUM(NSInteger, AUXAppSupportFunc) {
    AUXAppSupportFuncSleepDIY,
    AUXAppSupportFuncElectricityConsumptionCurve,
    AUXAppSupportFuncSmartPower,
    AUXAppSupportFuncPeakValley,
    AUXAppSupportFuncLimitElectricity,
    AUXAppSupportFuncFilter,
};

/**
 设备模式 (用于服务器)

 - AUXServerDeviceModeAuto: 自动
 - AUXServerDeviceModeCool: 制冷
 - AUXServerDeviceModeHeat: 制热
 - AUXServerDeviceModeDry: 除湿
 - AUXServerDeviceModeWind: 送风
 */
typedef NS_ENUM(NSInteger, AUXServerDeviceMode) {
    AUXServerDeviceModeAuto,
    AUXServerDeviceModeCool,
    AUXServerDeviceModeHeat,
    AUXServerDeviceModeDry,
    AUXServerDeviceModeWind,
};

/**
 风速档数 (用于服务器)

 - AUXWindSpeedGearTypeThree: 三档（高、中、低）
 - AUXWindSpeedGearTypeFour: 四档（高、中、低、自动）
 - AUXWindSpeedGearTypeFive: 五档（高、中高、中、中低、低）
 - AUXWindSpeedGearTypeSix: 六档（高、中高、中、中低、低、自动）
 */
typedef NS_ENUM(NSInteger, AUXWindSpeedGearType) {
    AUXWindSpeedGearTypeThree = 1,
    AUXWindSpeedGearTypeFour,
    AUXWindSpeedGearTypeFive,
    AUXWindSpeedGearTypeSix,
};

/**
 屏显 (用于服务器)

 - AUXDeviceScreenGearThree: 三档（开、关、自动）
 - AUXDeviceScreenGearTwo: 二档（开、关）
 */
typedef NS_ENUM(NSInteger, AUXDeviceScreenGear) {
    AUXDeviceScreenGearThree = 1,
    AUXDeviceScreenGearTwo = 2,
};

/**
 风速 (用于服务器)
 
 - AUXServerWindSpeedLow: 低风
 - AUXServerWindSpeedMid: 中风
 - AUXServerWindSpeedHigh: 高风
 - AUXServerWindSpeedMute: 静音
 - AUXServerWindSpeedAuto: 自动
 - AUXServerWindSpeedTurbo: 强力
 - AUXServerWindSpeedCustom: 自定义
 */
typedef NS_ENUM(NSInteger, AUXServerWindSpeed) {
    AUXServerWindSpeedLow = 0,
    AUXServerWindSpeedMid,
    AUXServerWindSpeedHigh,
    AUXServerWindSpeedMute,
    AUXServerWindSpeedAuto,
    AUXServerWindSpeedTurbo,
    AUXServerWindSpeedCustom,
};

/**
 设备分享用户类型 (用于服务器)

 - AUXDeviceShareTypeMaster: 主人
 - AUXDeviceShareTypeFamily: 家人
 - AUXDeviceShareTypeFriend: 朋友
 */
typedef NS_ENUM(NSInteger, AUXDeviceShareType) {
    AUXDeviceShareTypeMaster,
    AUXDeviceShareTypeFamily,
    AUXDeviceShareTypeFriend,
};

/**
 设备来源 (用于服务器)

 - AUXDeviceSourceBL: 古北
 - AUXDeviceSourceGiz: 机智云
 */
typedef NS_ENUM(NSInteger, AUXDeviceSource) {
    AUXDeviceSourceBL,
    AUXDeviceSourceGizwits,
};

/**
 硬件类型 (用于服务器)
 
 - AUXDeviceHardwareTypeBL: 古北
 - AUXDeviceHardwareTypeMX: 庆科
 */
typedef NS_ENUM(NSInteger, AUXDeviceHardwareType) {
    AUXDeviceHardwareTypeBL = 1,
    AUXDeviceHardwareTypeMX = 2,
};

/**
 设备类型 (用于服务器)

 - AUXDeviceSuitTypeAC: 单元机
 - AUXDeviceSuitTypeGateway: 多联机
 */
typedef NS_ENUM(NSInteger, AUXDeviceSuitType) {
    AUXDeviceSuitTypeAC,
    AUXDeviceSuitTypeGateway,
};

/**
 设备内机类型 (用于服务器)

 - AUXDeviceMachineTypeHang: 挂机
 - AUXDeviceMachineTypeStand: 柜机
 */
typedef NS_ENUM(NSInteger, AUXDeviceMachineType) {
    AUXDeviceMachineTypeHang,
    AUXDeviceMachineTypeStand,
};

/**
 设备型号类别

 - AUXDeviceCategoryTypeHang: 挂机
 - AUXDeviceCategoryTypeStand: 柜机
 - AUXDeviceCategoryTypeAC: 单元机
 - AUXDeviceCategoryTypeGateway: 多联机
 */
typedef NS_ENUM(NSInteger, AUXDeviceCategoryType) {
    AUXDeviceCategoryTypeHang,
    AUXDeviceCategoryTypeStand,
    AUXDeviceCategoryTypeAC,
    AUXDeviceCategoryTypeGateway,
};

/**
 智能用电模式
 
 - AUXSmartPowerModeFast: 极速模式
 - AUXSmartPowerModeBalance: 均衡模式
 - AUXSmartPowerModeStandard: 标识模式
 */
typedef NS_ENUM(NSInteger, AUXSmartPowerMode) {
    AUXSmartPowerModeFast,
    AUXSmartPowerModeBalance,
    AUXSmartPowerModeStandard,
};

/**
 执行周期
 
 - AUXSmartPowerCycleEveryday: 每天
 - AUXSmartPowerCycleOnce: 一次
 */
typedef NS_ENUM(NSInteger, AUXSmartPowerCycle) {
    AUXSmartPowerCycleEveryday,
    AUXSmartPowerCycleOnce,
};

/**
 用电曲线 - 时间类型

 - AUXElectricityCurveDateTypeDay: 日
 - AUXElectricityCurveDateTypeMonth: 月
 - AUXElectricityCurveDateTypeYear: 年
 */
typedef NS_ENUM(NSInteger, AUXElectricityCurveDateType) {
    AUXElectricityCurveDateTypeDay,
    AUXElectricityCurveDateTypeMonth,
    AUXElectricityCurveDateTypeYear,
};

/**
 用电曲线 - 波类型

 - AUXElectricityCurveWaveTypeNone: 不区分类型
 - AUXElectricityCurveWaveTypeNormal: 波平
 - AUXElectricityCurveWaveTypePeak: 波峰
 - AUXElectricityCurveWaveTypeValley: 波谷
 */
typedef NS_ENUM(NSInteger, AUXElectricityCurveWaveType) {
    AUXElectricityCurveWaveTypeNone = 0,
    AUXElectricityCurveWaveTypeNormal = 1,
    AUXElectricityCurveWaveTypePeak = 2,
    AUXElectricityCurveWaveTypeValley = 3,
};

typedef NS_ENUM(NSInteger, AUXSpeechCmdCode) {
    AUXSpeechCmdOthers = 0,
    AUXSpeechCmdShareDevicesToFamilies = 41,
    AUXSpeechCmdShareDevicesToFriends = 42,
};

typedef NS_ENUM(NSInteger, AUXSpeechType) {
    AUXSpeechTypeControl = 1,
    AUXSpeechTypeShareDevices = 2,
};

/**
 配网结果状态

 - AUXConfigStatusOfBindSuccess: 绑定成功
 - AUXConfigStatusOfConfigFail: 配网失败
 - AUXConfigStatusOfBindFail: 绑定失败
 */
typedef NS_ENUM(NSInteger, AUXConfigStatus) {
    AUXConfigStatusOfBindSuccess = 1,
    AUXConfigStatusOfConfigFail = 2,
    AUXConfigStatusOfBindFail = 3,
};


/**
 有widget 跳往主APP

 - AUXExtensionPushToMainAppTypeOfLogin: 跳往登录
 - AUXExtensionPushToMainAppTypeOfAddDevice: 跳往小组件页面
 - AUXExtensionPushToMainAppTypeOfDeviceList: 跳往设备列表
 */
typedef NS_ENUM(NSInteger, AUXExtensionPushToMainAppType) {
    AUXExtensionPushToMainAppTypeOfLogin,
    AUXExtensionPushToMainAppTypeOfAddDevice,
    AUXExtensionPushToMainAppTypeOfDeviceList,
    AUXExtensionPushToMainAppTypeOfDeviceController,
};

/**
 家庭名称页面使用类型

 - AUXFamilyNameStatusOfCreateFamily: 创建家庭时的设置名字
 - AUXFamilyNameStatusOfChangeFamilyName: 修改家庭的名字
 - AUXFamilyNameStatusOfFindUser: 根据手机号查找用户
 */
typedef NS_ENUM(NSInteger, AUXFamilyNameStatus) {
    AUXFamilyNameStatusOfCreateFamily = 1,
    AUXFamilyNameStatusOfChangeFamilyName = 2,
    AUXFamilyNameStatusOfFindUser = 3,
    
};

/**
 二维码分享页面使用状态

 - AUXQRCodeStatusOfShareDevice: 分享设备
 - AUXQRCodeStatusOfShareFamilyInvitation: 分享家庭邀请
 */
typedef NS_ENUM(NSInteger, AUXQRCodeStatus) {
    AUXQRCodeStatusOfShareDevice = 1,
    AUXQRCodeStatusOfShareFamilyInvitation = 2,
};

/**
 设备控制类型
 
 - AUXDeviceControlTypeVirtual: 虚拟体验
 - AUXDeviceControlTypeDevice: 设备
 - AUXDeviceControlTypeSubdevice: 子设备
 - AUXDeviceControlTypeGatewayMultiDevice: 多联机集中控制
 - AUXDeviceControlTypeSceneMultiDevice: 场景集中控制
 - AUXDeviceControlTypeGateway: 多联机
 */
typedef NS_ENUM(NSInteger, AUXDeviceControlType) {
    AUXDeviceControlTypeVirtual,
    AUXDeviceControlTypeDevice,
    AUXDeviceControlTypeSubdevice,
    AUXDeviceControlTypeGatewayMultiDevice,
    AUXDeviceControlTypeSceneMultiDevice,
    AUXDeviceControlTypeGateway,
};

/**
 设备列表样式

 - AUXDeviceListTypeOfGrid: 宫格
 - AUXDeviceListTypeOfList: 长条
 */
typedef NS_ENUM(NSInteger, AUXDeviceListType) {
    AUXDeviceListTypeOfGrid = 1,
    AUXDeviceListTypeOfList = 2,
};

typedef NS_ENUM(NSInteger, AUXWeatherType) {
    AUXWeatherTypeOfSunshine = 1,
    AUXWeatherTypeOfRain = 2,
    AUXWeatherTypeOfCloud = 3,
};

typedef NS_ENUM(NSInteger, AUXSceneCollectionType) {
    AUXSceneCollectionTypeOfBig = 1,
    AUXSceneCollectionTypeOfLittle = 2,
};


/**
 场景类型

 - AUXSceneTypeOfPlace: 位置触发
 - AUXSceneTypeOfTime: 时间触发
 - AUXSceneTypeOfManual: 手动触发
 - AUXSceneTypeOfCenterControl: 集中控制

 */
typedef NS_ENUM(NSInteger, AUXSceneType) {
    AUXSceneTypeOfPlace = 1,
    AUXSceneTypeOfTime = 2,
    AUXSceneTypeOfManual = 3,
    AUXSceneTypeOfCenterControl = 4,

};

typedef NS_ENUM(NSInteger, AUXScenePower) {
    AUXScenePowerOn = 1,
    AUXScenePowerOff = 2,
};

typedef NS_ENUM(NSInteger, AUXScenePlaceType) {
    AUXScenePlaceTypeOfAway = 1,
    AUXScenePlaceTypeOfGoHome = 2,
};

typedef NS_ENUM(NSInteger, AUXSceneModelType) {
    AUXSceneModelTypeOfAuto = 0,
    AUXSceneModelTypeOfCool = 1,
    AUXSceneModelTypeOfDehumidify = 2,
    AUXSceneModelTypeOfHeat = 4,
    AUXSceneModelTypeOfVentilate = 6,
};

typedef NS_ENUM(NSInteger, AUXBindAccountType) {
    AUXBindAccountTypeOfLogin = 1,
    AUXBindAccountTypeOfUserCenter = 2,
    AUXBindAccountTypeOfAfterSale = 3,
    AUXBindAccountTypeOfStore = 4,
};

typedef NS_ENUM(NSInteger, AUXAfterSaleType) {
    AUXAfterSaleTypeOfInstallation = 1,
    AUXAfterSaleTypeOfMaintenance = 5,
};

typedef NS_ENUM(NSInteger, AUXAfterSaleDeviceType) {
    AUXAfterSaleDeviceTypeOfCommercial = 1,
    AUXAfterSaleDeviceTypeOfHouseHold = 2,
};

typedef NS_ENUM(NSInteger, AUXLogisticsType) {
    AUXLogisticsTypeOfNeedInstall = 1,
    AUXLogisticsTypeOfSubsribeInstall = 2,
};

typedef NS_ENUM(NSInteger, AUXPushToSNCodeSearchVCType) {
    AUXPushToSNCodeSearchVCTypeOfFromScanCodeVC = 1,
    AUXPushToSNCodeSearchVCTypeOfFromAfterSaleVC = 2,
};

typedef NS_ENUM(NSInteger, AUXAfterSaleWebType) {
    AUXAfterSaleWebTypeOfChargePolicy = 1,
    AUXAfterSaleWebTypeOfServiceStatement = 2,
};

typedef NS_ENUM(NSInteger, AUXAfterSaleChargePolicyType) {
    AUXAfterSaleChargePolicyTypeOfHomeService = 1,
    AUXAfterSaleChargePolicyTypeOfCenterService = 2,
};

typedef NS_ENUM(NSInteger, AUXAfterSaleAddContactType) {
    AUXAfterSaleAddContactTypeOfFromContactList = 1,
    AUXAfterSaleAddContactTypeOfFromEditVC = 2,
};

typedef NS_ENUM(NSInteger, AUXAfterSaleCheckBindAccountType) {
    AUXAfterSaleCheckBindAccountTypeOfFromUser = 1,
    AUXAfterSaleCheckBindAccountTypeOfFromControl = 2,
};

typedef NS_ENUM(NSInteger, AUXEvaluateType) {
    AUXEvaluateTypeOfFromWorkOrderList = 1,
    AUXEvaluateTypeOfFromWorkOrderDetail = 2,
};

typedef NS_ENUM(NSInteger, AUXPushToLoginViewControllerType) {
    AUXPushToLoginViewControllerTypeOfFromStore = 1,
};

typedef NS_ENUM(NSInteger, AUXStoreMenuType) {
    AUXStoreMenuTypeOfButtonMenu = 1,
    AUXStoreMenuTypeOfDetailButtonMenu = 2,
};


typedef NS_ENUM(NSInteger, AUXTesterType) {
    AUXTesterHiddenType = 0,//测试人员不显示
    AUXTesterShowType = 1,//测试人员显示
};

typedef NS_ENUM(NSInteger, AUXNamingType) {
    AUXNamingTypeDeviceName,    // 设备命名
    AUXNamingTypeSubdeviceName, // 子设备命名
    AUXNamingTypeDeviceSN,      // 完善SN码
    AUXNamingTypeSleepDIY,      // 睡眠DIY命名
    AUXNamingTypeSceneName,      // 场景名称
    AUXNamingTypeUserNickName,      // 用户昵称
    AUXNamingTypeUserName,      // 用户名称


};

typedef NS_ENUM(NSInteger, AUXDeviceControlSchedulerType) {
    AUXDeviceControlSchedulerTypeOfTime = 1,
    AUXDeviceControlSchedulerTypeOfDevice = 2,
};

typedef NS_ENUM(NSInteger, AUXTimePeriodPickerType) {
    AUXTimePeriodPickerTypeOfSleepDIY = 1,
    AUXTimePeriodPickerTypeOfOther = 2,
};

/**
 设备信息页 rowTitle

 - AUXDeviceInfoRowTypeOfDeviceName: 设备名称
 - AUXDeviceInfoRowTypeOfDeviceSn: 设备SN
 - AUXDeviceInfoRowTypeOfDeviceMac: 设备mac
 - AUXDeviceInfoRowTypeOfDeviceFirmwareVersion: 设备固件版本
 - AUXDeviceInfoRowTypeOfDeviceHistoryFaults: 设备历史故障信息
 - AUXDeviceInfoRowTypeOfDeviceShare: 设备共享
 */
typedef NS_ENUM(NSInteger, AUXDeviceInfoRowType) {
    AUXDeviceInfoRowTypeOfDeviceName = 1,
    AUXDeviceInfoRowTypeOfDeviceSn = 2,
    AUXDeviceInfoRowTypeOfDeviceMac = 3,
    AUXDeviceInfoRowTypeOfDeviceFirmwareVersion = 4,
    AUXDeviceInfoRowTypeOfDeviceHistoryFaults = 5,
    AUXDeviceInfoRowTypeOfDeviceShare = 6,
    AUXDeviceInfoRowTypeOfDeviceSubName = 7,
};

static const CGFloat kAlertAnimationTime = 0.3;

static const CGFloat kToastAnimationTime = 2.0;

static CGFloat const kAUXTabDeviceSelected = 0;
static CGFloat const kAUXTabSceneSelected = 1;
static CGFloat const kAUXTabStoreSelected = 2;
static CGFloat const kAUXTabUserSelected = 3;

static CGFloat const kAUXTemperatureMax = 32.0;
static CGFloat const kAUXTemperatureMin = 16.0;

static NSInteger const kAUXElectricityLimitPercentageMin = 30;
static NSInteger const kAUXElectricityLimitPercentageMax = 100;

static NSInteger const kAUXChatRoleUser = 100;
static NSInteger const kAUXChatRoleAI = 200;

static NSString * _Nonnull const kAUXGatewayDeviceAddress = @"00";
static NSString * _Nonnull const kAUXACDeviceAddress = @"01";
static NSString * _Nonnull const kAUXFilterFaultId = @"-1";

static NSString * _Nonnull const kAUXWeatherSunshine = @"weatherSunshine";
static NSString * _Nonnull const kAUXWeatherCloud = @"waetherCloud";
static NSString * _Nonnull const kAUXWeatherStarrySky = @"weatherStarrySky";
static NSString * _Nonnull const kAUXWeatherSnow = @"weatherSnow";
static NSString * _Nonnull const kAUXWeatherSnowWithLogo = @"weatherSnowWithLogo";

static NSString * _Nonnull const kAUXSchemesAlipays = @"alipays://";
static NSString * _Nonnull const kAUXSchemesWeXin = @"weixin://wap/pay?";
static NSString * _Nonnull const kAUXSchemesTaoBao = @"tbopen://";
static NSString * _Nonnull const kAUXSchemesTmall = @"tmall://";


static NSString * _Nonnull const kAUXItunsUrl = @"http://itunes.apple.com/lookup?id=909627323";
static NSString* const kAUXHelpSceneURL = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/help/center.html#/scene";
static NSString* const kWXPre = @"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb";
static NSString* const kAUXURL = @"https://www.aux-home.com/";

static NSString * _Nonnull const kAUXPrivacyStatement = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/privacy_protection/v2.html";//数据隐私声明

static NSString * _Nonnull const kAUXUserProtocol = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/user/agreement.html";

static NSString * _Nonnull const kAUXScenePlaceStatement = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/scene/notice2.html";
static NSString* const kAUXHelpURL = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/";
static NSString* const kAUXKnowledgeBaseURL = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/knowledge/v1.html";

static NSString* const kAUXAfterSaleChargepolicyURL = @"https://smarthomelink.aux-home.com/auxhome_5_0/views/aftersaleV2/statement.html";//售后服务声明
static NSString* const kAUXAfterSaleStatementURL = @"https://smarthomelink.aux-home.com/auxair_h5/views/aftersale_ios/statement.html";

static NSString* const kAUXCFBundleShortVersionString = @"CFBundleShortVersionString";

static NSString * _Nonnull const kAUXHelpcenterUrl = @"https://smarthomelink.aux-home.com/auxair_h5/views/help/center.html#/add_device_fail";

//推送跳转相关
static NSString* const kAUXSchema = @"schema";
static NSString* const kAUXLocal = @"local";
static NSString* const kAUXHomepage = @"homepage";
static NSString* const kAUXWebview = @"webview";
static NSString* const kAUXWebviewWithUrl = @"webview?url=";
static NSString* const kAUXShopindex = @"shopindex";
static NSString* const kAUXEshop = @"eshop";
static NSString* const kAUXEshopWithUrl = @"eshop?url=";
static NSString* const kAUXMsgcenter = @"msgcenter";

//页面名称
static NSString* const kAUXScanCodeViewController = @"AUXScanCodeViewController";
static NSString* const kAUXDeviceControlViewController = @"AUXDeviceControlViewController";
static NSString* const kAUXDeviceShareViewController = @"AUXDeviceShareViewController";
static NSString* const kAUXHomeCenterViewController = @"AUXHomeCenterViewController";
static NSString* const kAUXPersonalCenterViewController = @"AUXPersonalCenterViewController";
static NSString* const kAUXMessageManagerViewController = @"AUXMessageManagerViewController";
static NSString* const kAUXUserWebViewController = @"AUXUserWebViewController";
static NSString* const kAUXFeedbackViewController = @"AUXFeedbackViewController";
static NSString* const kAUXSceneAddNewViewController = @"AUXSceneAddNewViewController";
static NSString* const kAUXSceneEditViewController = @"AUXSceneEditViewController";
static NSString* const kAUXStoreViewController = @"AUXStoreViewController";
static NSString* const kAUXUserCenterViewController = @"AUXUserCenterViewController";

#pragma mark 极光推送的 tag
static NSString* const kAPPPUSH_LEVEL_V1 = @"PUSH_LEVEL_V1";

//static NSString* const kAPPPUSH_LEVEL_V2 = @"PUSH_LEVEL_V2"; //测试专用

static const NSInteger DeviceControlCommondMaxTime = 3.0;

static inline BOOL AUXWhtherNullString(NSString * string) {
    
    if (!string) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!string.length) {
        return YES;
    }
    if ([string isEqualToString:@"undefined"]) {
        return YES;
    }
    if ([string isEqualToString:@"UNKNOWN"]) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [string stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

/**
 根据步进来调整浮点数。
 如：step = 0.5，当 floatValue = 26.4 的时候，将 temperature 调整为 26.5。
 如：step = 1.0，则四舍五入。
 
 @param floatValue 浮点数
 @param step 步进
 @return 温度值
 */
static inline CGFloat AUXAdjustFloatValue(CGFloat floatValue, CGFloat step) {
    
    // 整数位
    NSInteger intValue = (NSInteger)floatValue;
    // 小数位
    CGFloat decimalValue = floatValue - intValue;
    
    if (step == 0.5) {
        if (decimalValue < 0.25) {
            decimalValue = 0.0;
        } else if (decimalValue < 0.75) {
            decimalValue = 0.5;
        } else {
            decimalValue = 1.0;
        }
        
        floatValue = intValue + decimalValue;
        
    } else if (step == 1.0) {
        if (decimalValue < 0.5) {
            decimalValue = 0.0;
        } else {
            decimalValue = 1.0;
        }
        
        floatValue = intValue + decimalValue;
    }
    
    return floatValue;
}

static inline BOOL AUXCheckNumber(NSString * _Nullable phone)
{
    if (phone == nil || [phone length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[phone componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![phone isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}

static inline BOOL AUXCheckPhoneNumber(NSString * _Nullable phone) {
    if (!phone || phone.length <= 0) {
        return NO;
    }
    
    // 电信号段:133/153/180/181/189/177/173/149
    // 联通号段:130/131/132/155/156/185/186/145/176/175
    // 移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    // 虚拟运营商:170[1700/1701/1702(电信)、1703/1705/1706(移动)、1704/1707/1708/1709(联通)]、171(联通)
    
//    NSString *regularExpression = @"^1(3[0-9]|4[579]|5[0-35-9]|7[0135-8]|8[0-9])\\d{8}$";
    // 检查11位数字
    NSString *regularExpression = @"^\\d{11}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpression];
    return [predicate evaluateWithObject:phone];
}

static inline UIEdgeInsets aux_safeAreaInsets(UIView * _Nonnull view) {
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}


#endif /* AUXDefinitions_h */
