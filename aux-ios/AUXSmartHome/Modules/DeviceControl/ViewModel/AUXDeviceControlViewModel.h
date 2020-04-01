//
//  AUXDeviceControlViewModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXDeviceFunctionItem.h"
#import "AUXDeviceSectionItem.h"
#import "AUXDeviceStatus.h"

#import "AUXPeakValleyModel.h"
#import "AUXSmartPowerModel.h"
#import "AUXDeviceInfo.h"
#import "AUXDeviceStatus.h"
#import "AUXDeviceFeature.h"
#import "AUXPeakValleyModel.h"
#import "AUXSchedulerModel.h"
#import "AUXElectricityConsumptionCurveModel.h"
#import "AUXSleepDIYModel.h"

typedef void(^InitConfigInfoBlock)(NSMutableDictionary *dict);

typedef void(^ConfigHardwaretypeBlock)(int hardwaretype);

@protocol AUXDeviceControlViewModelDelegate <NSObject>

@optional

/**
 推出到控制器classVC

 @param classVC 根据classVC类型判断推出哪一个控制器
 */
- (void)devControlVMDelOfPushToVC:(Class)classVC;

/**
 查询设备状态 deviceStatus

 @param deviceStatus 设备状态 deviceStatus
 */
- (void)devControlVMDelOfSDKQueryAUXDeviceStatus:(AUXDeviceStatus *)deviceStatus;

/**
 SDK查询的AUXACStatus

 @param deviceStatus AUXACStatus
 */
- (void)devControlVMDelOfSDKQueryAUXACStatus:(AUXACStatus *)deviceStatus;

/**
 server查询的睡眠DIY(数组)
 
 @param sleepDIYModels 数组
 */
- (void)devControlVMDelOfQuerySleepModels:(NSArray<AUXSleepDIYModel    *> *)sleepDIYModels;

/**
 SDK查询的睡眠DIY(数组)

 @param sleepDIYPoints 数组
 */
- (void)devControlVMDelOfSDKQuerySleepDIYPoints:(NSArray<AUXACSleepDIYPoint *> *)sleepDIYPoints;

/**
 获取设备的定时信息

 @param schedulerList 定时信息列表
 */
- (void)devControlVMDelOfSchedulerInfo:(NSArray<AUXSchedulerModel *> *)schedulerList;

/**
 获取设备的用电曲线

 @param electricityConsumptionCurveModel 封装解析好的用电曲线模型
 */
- (void)devControlVMDelOfElectricityConsumptionCurveInfo:(AUXElectricityConsumptionCurveModel *)electricityConsumptionCurveModel;

/**
 新设备的故障信息也附带在设备运行状态里面，这里查询服务器，只是为了获取滤网信息。

 @param faultInfoList 故障列表（知识获取滤网信息）
 */
- (void)devControlVMDelOfFaultInfoList:(NSArray<AUXFaultInfo *> * _Nullable)faultInfoList;

/**
 峰谷节点回调代理

 @param peakValleyModel 峰谷节点model
 */
- (void)devControlVMDelOfPeakValleyInfo:(AUXPeakValleyModel *)peakValleyModel;

/**
 智能用电回调代理

 @param smartPowerModel 智能用电model
 */
- (void)devControlVMDelOfSmartPowerInfo:(AUXSmartPowerModel *)smartPowerModel;

- (void)devControlVMDelOfShowLoading;

- (void)devControlVMDelOfHideLoading;

- (void)devControlVMDelOfError:(NSError *)error;

- (void)devControlVMDelOfErrorMessage:(NSString *)errorMessage;

/**
 账号缓存过期
 */
- (void)devControlVMDelOfAccountCacheExpired;

@end

NS_ASSUME_NONNULL_BEGIN
@interface AUXDeviceControlViewModel : NSObject

- (instancetype)initWithDeviceInfoArray:(NSArray<AUXDeviceInfo *> *)deviceInfoArray
                            controlType:(AUXDeviceControlType)controlType
                               delegate:(id<AUXDeviceControlViewModelDelegate>)delegate configBlock:(InitConfigInfoBlock)configBlock;

- (void)deviceRemoveDelegate;

- (void)getFaultList;

- (void)getPowerInfo;

- (void)getDeviceDataInfo;

- (void)getPeakValleyBySDK;

- (void)getPeakValleyByServerWithLoading;

- (void)getSmartPowerBySDK;

- (void)getSmartPowerByServerWithLoading;

/// 更改温度
- (void)controlDeviceWithTemperature:(CGFloat)temperature;
/// 开关机
- (void)controlDeviceWithPower:(BOOL)powerOn ;

/// 切换模式
- (void)controlDeviceWithMode:(AirConFunction)mode ;

/// 更改风速
- (void)controlDeviceWithWindSpeed:(WindSpeed)windSpeed ;

/// 上下摆风
- (void)controlDeviceWithSwingUpDown:(BOOL)swingUpDown ;

/// 左右摆风
- (void)controlDeviceWithSwingLeftRight:(BOOL)swingLeftRight ;

/**
 屏显
 
 @param screenOnOff 开启、关闭
 @param autoScreen 自动屏显
 */
- (void)controlDeviceWithScreenOnOff:(BOOL)screenOnOff autoScreen:(BOOL)autoScreen ;

/// ECO
- (void)controlDeviceWithECO:(BOOL)eco ;

/// 电加热
- (void)controlDeviceWithElectricHeating:(BOOL)electricHeating ;

/// 童锁
- (void)controlDeviceWithChildLock:(BOOL)childLock ;

/// 清洁
- (void)controlDeviceWithClean:(BOOL)clean ;

/// 防霉
- (void)controlDeviceWithAntiFungus:(BOOL)antiFungus ;

/// 健康
- (void)controlDeviceWithHealthy:(BOOL)healthy ;

/// 清新
- (void)controlDeviceWithAirFreshing:(BOOL)airFreshing ;

/// 睡眠模式
- (void)controlDeviceWithSleepMode:(BOOL)sleepMode ;

/// 睡眠DIY (旧设备)
- (void)controlDeviceWithSleepDIY:(BOOL)on sleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel ;

/// 睡眠DIY (旧设备)
- (void)controlDeviceWithSleepDIY:(BOOL)on mode:(AUXServerDeviceMode)mode ;

/// 用电限制
- (void)controlDeviceWithElectricityLimit:(BOOL)on percentage:(NSInteger)percentage ;

/// 舒适风
- (void)controlDeviceWithComfortWind:(BOOL)comfortWind ;

@property (nonatomic,copy) ConfigHardwaretypeBlock hardwaretypeBlock;

@end

NS_ASSUME_NONNULL_END
