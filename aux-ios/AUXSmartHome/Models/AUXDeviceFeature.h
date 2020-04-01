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

#import "AUXDefinitions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 设备支持的功能
 */
@interface AUXDeviceFeature : NSObject

@property (nonatomic, strong) NSArray<NSString *> *coolType;            // 单冷/冷暖，0：单冷，1：冷暖
@property (nonatomic, strong) NSArray<NSString *> *frenquency;          // 定频/变频，0：定频，1：变频
@property (nonatomic, strong) NSArray<NSString *> *tempInterval;        // 温度间隔，0：0.5摄氏度，1：1摄氏度
@property (nonatomic, strong) NSArray<NSString *> *roomTempDisplay;     // 室温显示，1：有，0：无
@property (nonatomic, strong) NSArray<NSString *> *faultSupport;        // 故障报警，0：支持，1：不支持
@property (nonatomic, strong) NSArray<NSString *> *timing;              // 定时，0：支持，1：不支持 (旧设备)
@property (nonatomic, strong) NSArray<NSString *> *windSpeed;           // 风速档数，1：三档（高、中、低），2：四档（高、中、低、自动），3：五档（高、中高、中、中低、低），4：六档（高、中高、中、中低、低、自动）
@property (nonatomic, strong) NSArray<NSString *> *screen;              // 屏显，1：3档（开、关、自动），2：2档（开、关）
@property (nonatomic, strong) NSArray<NSString *> *mode;                // 模式，“0,1,2,3,4”=自动、制冷、制热、除湿、送风
@property (nonatomic, strong) NSArray<NSString *> *deviceSupport;       // 设备支持功能，“0,1,2”=清洁、防霉、静音
@property (nonatomic, strong) NSArray<NSString *> *appSupport;          // APP支持功能，“0,1,2”=睡眠DIY、电量计量、智能用电

@property (nonatomic, assign) BOOL coolOnly;                // 单冷/冷暖，YES：单冷，NO：冷暖
@property (nonatomic, assign) BOOL frequencyConversion;     // 定频/变频，NO：定频，YES：变频
@property (nonatomic, assign) BOOL halfTemperature;         // 温度间隔，YES：0.5摄氏度，NO：1摄氏度
@property (nonatomic, assign) BOOL hasRoomTemperature;      // 室温显示，YES：有，NO：无
@property (nonatomic, assign) BOOL hasFault;                // 故障报警，YES：支持，NO：不支持
@property (nonatomic, assign) BOOL hasScheduler;            // 定时，YES：支持，NO：不支持

@property (nonatomic, assign) AUXWindSpeedGearType windSpeedGear; // 风速档数，1：三档（高、中、低），2：四档（高、中、低、自动），3：五档（高、中高、中、中低、低），4：六档（高、中高、中、中低、低、自动）
@property (nonatomic, assign) AUXDeviceScreenGear screenGear;     // 屏显，1：3档（开、关、自动），2：2档（开、关）

@property (nonatomic, assign) BOOL hasDeviceInfo;           // 是否可以查看设备信息，YES：可以，NO：不可以

/// 支持的模式 AUXServerDeviceMode
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *supportModes;
/// 设备支持的功能 AUXDeviceSupportFunc
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *deviceSupportFuncs;
/// APP支持的功能 AUXAppSupportFunc
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *appSupportFuncs;

- (instancetype)initWithJSON:(NSString *)JSONString;

/// 虚拟体验下的设备功能列表
+ (instancetype)virtualDeviceFeature;

/// 集中控制下的设备功能列表
+ (nullable instancetype)multiDeviceFeature;
+ (void)setMultiDeviceFeature:(AUXDeviceFeature *)deviceFeature;
+ (AUXDeviceFeature *)createDefaultMultiDeviceFeature;

- (void)setValueWithJSON:(NSString *)JSONString;

/**
 转换支持的服务器模式为SDK模式

 @return 支持的SDK模式列表
 */
- (NSArray <NSNumber *> *)convertToAirConFunctionModeList;

/**
 转换为开机状态下的 tableView section 列表 (用于构造设备控制界面)
 
 @return 设备功能列表 AUXDeviceFunctionType
 */
- (NSArray<NSNumber *> *)convertToOnSectionList;

/**
 转换为关机状态下的 tableView section 列表 (用于构造设备控制界面)
 
 @return 设备功能列表 AUXDeviceFunctionType
 */
- (NSArray<NSNumber *> *)convertToOffSectionList;

/**
 转换为开机状态下的设备功能列表 (用于构造设备控制界面)

 @return 设备功能列表 AUXDeviceFunctionType
 */
- (NSArray<NSNumber *> *)convertToOnFunctionList;

/**
 转换为关机状态下的设备功能列表 (用于构造设备控制界面)
 
 @return 设备功能列表 AUXDeviceFunctionType
 */
- (NSArray<NSNumber *> *)convertToOffFunctionList;

@end

NS_ASSUME_NONNULL_END

//{\"coolType\":[\"0\",\"0\"],\"frenquency\":[\"1\",\"0\"],\"tempInterval\":[\"0\",\"0\"],\"roomTempDisplay\":[\"1\",\"0\"],\"faultSupport\":[\"0\",\"0\"],\"timing\":[\"0\",\"0\"],\"mode\":[\"0,1,2,3,4\",\"1\"],\"deviceSupport\":[\"0\",\"1\"],\"appSupport\":[\"0,1,2,4,5\",\"1\"]}

