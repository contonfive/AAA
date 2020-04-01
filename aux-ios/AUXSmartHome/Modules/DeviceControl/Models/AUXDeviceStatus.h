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
#import <YYModel/YYModel.h>

@class AUXFaultInfo;

@interface AUXDeviceStatus : NSObject <NSCopying, YYModel>

@property (nonatomic, assign) WindGearType windGearType;

@property (nonatomic, assign) BOOL powerOn;

@property (nonatomic, assign) AirConFunction mode;

/// 可访问该属性值，但请勿直接设置 windSpeed 的值，设置值请使用 convenientWindSpeed 属性。
@property (nonatomic, assign) WindSpeed windSpeed;
/// 可访问该属性值，但请勿直接设置 turbo 的值，设置值请使用 convenientWindSpeed 属性。
@property (nonatomic, assign) BOOL turbo;
/// 可访问该属性值，但请勿直接设置 silence 的值，设置值请使用 convenientWindSpeed 属性。
@property (nonatomic, assign) BOOL silence;

/**
 风速值，适用于界面更新及设置 windSpeed、turbo、silence 的值。
 (用该属性考虑的是：避免在多个地方繁琐的判断turbo、silence的值)
 */
@property (nonatomic, assign) WindSpeed convenientWindSpeed;

@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, assign) CGFloat roomTemperature;
@property (nonatomic, assign) int swingUpDown;
@property (nonatomic, assign) int swingLeftRight;
@property (nonatomic, assign) BOOL eco;             // ECO，制冷模式下才可用
@property (nonatomic, assign) BOOL electricHeating; // 电加热，制热模式下才可用
@property (nonatomic, assign) BOOL childLock;       // 童锁
@property (nonatomic, assign) BOOL clean;           // 清洁
@property (nonatomic, assign) BOOL antiFungus;      // 防霉
@property (nonatomic, assign) BOOL healthy;         // 健康
@property (nonatomic, assign) BOOL airFreshing;     // 清新
@property (nonatomic, assign) BOOL screenOnOff;     // 屏显关闭/开启
@property (nonatomic, assign) BOOL autoScreen;      // 自动屏显，当屏显开启时可用
@property (nonatomic, assign) BOOL sleepMode;       // 睡眠
@property (nonatomic, assign) BOOL scheduler;       // 是否有定时开启
@property (nonatomic, assign) BOOL sleepDIY;        // 睡眠DIY是否开启 (旧设备)
@property (nonatomic, assign) BOOL powerLimit;      // 用电限制开启/关闭
@property (nonatomic, assign) BOOL comfortWind;     // 舒适风开启/关闭
@property (nonatomic, assign) NSInteger powerLimitPercent;  // 用电限制百分比

@property (nonatomic, retain) AUXACNetworkError *fault;     // 设备故障信息 (SDK上报)
@property (nonatomic, strong) AUXFaultInfo *filterInfo;     // 设备滤网信息 (服务器查询)

- (instancetype)initWithGearType:(WindGearType)gearType;

/**
 根据 deviceControl 的值更新属性

 @param deviceControl 设备控制状态
 */
- (void)updateWithControl:(AUXACControl *)deviceControl;

/**
 使用自身的属性更新 deviceControl 的值

 @param deviceControl 设备控制状态
 */
- (void)updateValueForControl:(AUXACControl *)deviceControl;
- (void)updateValueForControl:(AUXACControl *)deviceControl withWindGear:(WindGearType)gearType;

/**
 判断当前AUXDeviceStatus能否更设置温度

 @param message 不能设置时原因message
 @return l能否
 */
- (BOOL)canAdjustTemperature:(NSString *__autoreleasing *)message;
@end
