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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AUXDefinitions.h"
#import "AUXDeviceModel.h"

/**
 配置类
 */
@interface AUXConfiguration : NSObject

@property (nonatomic, strong) UIColor *blueColor;   // 蓝主题色 (制冷、除湿)
@property (nonatomic, strong) UIColor *orangeColor; // 橙主题色 (制热)
@property (nonatomic, strong) UIColor *greenColor;  // 绿主题色 (送风、自动)

@property (nonatomic, strong) UIColor *curveNormalColor;    // 用电曲线 - 波平颜色
@property (nonatomic, strong) UIColor *curvePeakColor;      // 用电曲线 - 波峰颜色
@property (nonatomic, strong) UIColor *curveValleyColor;    // 用电曲线 - 波谷颜色
@property (nonatomic, strong) UIColor *curveCommonColor;    // 用电曲线 - 通用颜色

/// 设备型号字典，key 为设备SN码。
@property (nonatomic, strong) NSMutableDictionary<NSString *, AUXDeviceModel *> *deviceModelDictionary;

+ (instancetype)sharedInstance;

#pragma mark 场景模式
/**
 根据场景名称返回场景
 */
+ (AUXSceneModelType)getSceneMode:(NSString *)modeName;

/**
 根据场景返回场景名称
 */
+ (NSString *)getSceneModeName:(AUXSceneModelType)mode;

#pragma mark - SDK 模式、风速

/**
 获取模式

 @param modeName 模式名称
 @return 对应的模式
 */
+ (AirConFunction)getServerDeviceMode:(NSString *)modeName;

/**
 获取模式名称

 @param mode 模式
 @return 模式名称
 */
+ (NSString *)getModeName:(AirConFunction)mode;

/**
 获取风速名称

 @param windSpeed 风速
 @return 风速名称
 */
+ (NSString *)getWindSpeedName:(WindSpeed)windSpeed;

#pragma mark - 服务器 模式、风速

/**
 根据设备内机类型获取SDK风速档位类型

 @param machineType 设备内机类型(挂机、柜机)
 @return SDK风速档位
 */
+ (WindGearType)getSDKWindGearTypeWithMachineType:(AUXDeviceMachineType)machineType;

/**
 获取服务器模式名称
 
 @param mode 模式
 @return 模式名称
 */
+ (NSString *)getServerModeName:(AUXServerDeviceMode)mode;

/**
 获取定时风速名称
 
 @param windSpeed 风速
 @return 风速名称
 */
+ (NSString *)getServerWindSpeedName:(AUXServerWindSpeed)windSpeed;

/**
 将用于服务器的风速转换为对应SDK的风速

 @param serverWindSpeed 风速
 @return SDK风速
 */
+ (WindSpeed)getSDKWindSpeedWithServerWindSpeed:(AUXServerWindSpeed)serverWindSpeed;

/**
 将SDK的风速转换为用于服务器的风速

 @param windSpeed 风速
 @return 服务器风速
 */
+ (AUXServerWindSpeed)getServerWindSpeedWithSDKWindSpeed:(WindSpeed)windSpeed;

/**
 将用于服务器的模式转换为对应SDK的模式

 @param serverMode 模式
 @return SDK模式
 */
+ (AirConFunction)getSDKModeWithServerMode:(AUXServerDeviceMode)serverMode;

/**
 将SDK的模式转换为用于服务器的模式

 @param mode 模式
 @return 服务器模式
 */
+ (AUXServerDeviceMode)getServerModeWithSDKMode:(AirConFunction)mode;

/**
 获取智能用电模式名称

 @param mode 智能用电模式
 @return 智能用电模式名称
 */
+ (NSString *)getSmartPowerModeNameWithMode:(AUXSmartPowerMode)mode;

#pragma mark - 界面构造
/**
 获取设备模式的配置信息

 @return 设备模式的配置信息。key 为 AirConFunction。
 */
+ (NSDictionary<NSNumber *,NSDictionary *> *)getDeviceModesDictionary;
/**
 获取设备风速的配置信息

 @return 设备风速的配置信息。key 为 Windspeed。
 */
+ (NSDictionary<NSNumber *,NSDictionary *> *)getDeviceWindsDictionary;

/**
 获取服务器风速的配置信息

 @return 设备风速的配置信息。key 为 AUXServerWindSpeed。
 */
+ (NSDictionary<NSNumber *,NSDictionary *> *)getServerWindsDictionary;

/**
 获取设备功能列表的配置信息
 
 @return 设备功能列表的配置信息。key 为 AUXDeviceFunctionType。
 */
+ (NSDictionary<NSNumber *, NSDictionary *> *)getDeviceFunctionsDictionary;

/**
 获取设备控制界面 tableView 的 section info
 
 @return 设备功能列表的配置信息。key 为 AUXDeviceFunctionType。
 */
+ (NSDictionary<NSNumber *, NSDictionary *> *)getDeviceControlTableViewSectionInfosDictionary;

#pragma mark - 获取图标

/**
 获取设备列表的模式图标 (单元机)
 
 @param mode 模式
 @return 状态图标
 */
+ (NSString *)getDeviceListACModeIcon:(AirConFunction)mode;

/**
 获取设备列表的风速图标 (单元机)
 
 @param windSpeed 风速
 @return 状态图标
 */
+ (NSString *)getDeviceListACWindSpeedIcon:(WindSpeed)windSpeed;

/**
 获取设备列表卡片效果模式图标

 @param mode 模式
 @return 状态图标
 */
+ (NSString *)getDeviceCardModeIcon:(AirConFunction)mode;

/**
 获取设备列表卡片效果背景图标

 @param mode 模式
 @return 背景图标
 */
+ (NSString *)getDeviceCardPowernBgIcon:(AirConFunction)mode;

/**
 获取设备列表的模式图标 (多联机)
 
 @param mode 模式
 @return 状态图标
 */
+ (NSString *)getDeviceListGatewayModeIcon:(AirConFunction)mode;

/**
 获取设备控制界面设备状态的模式图标

 @param mode 模式
 @return 状态图标
 */
+ (NSString *)getDeviceControlStatusModeIcon:(AirConFunction)mode;

/**
 获取设备控制界面设备状态的风速图标
 
 @param windSpeed 风速
 @return 状态图标
 */
+ (NSString *)getDeviceControlStatusWindSpeedIcon:(WindSpeed)windSpeed;

/**
 获取设备功能 - 风速 图标

 @param windSpeed 风速
 @return 风速图标
 */
+ (NSDictionary<NSString *, NSString *> *)getDeviceFunctionWindSpeedIcon:(WindSpeed)windSpeed;

/**
 获取设备功能 - 屏显 图标

 @param autoScreen 自动屏显是否开启
 @return 屏显图标
 */
+ (NSDictionary<NSString *, NSString *> *)getDeviceFunctionScreenIcon:(BOOL)autoScreen;

/**
 获取设备风速控制界面的风速图标

 @param windSpeed 风速
 @return 风速图标
 */
+ (NSString *)getDeviceControlWindSpeedIcon:(WindSpeed)windSpeed;

#pragma mark - 设备分享

/**
 获取角色名 (家人、朋友)

 @param shareType 分享类型
 @return 角色名
 */
+ (NSString *)getRoleNameWithShareType:(AUXDeviceShareType)shareType;

@end
