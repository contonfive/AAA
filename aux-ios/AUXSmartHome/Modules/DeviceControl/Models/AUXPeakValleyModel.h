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
#import <YYModel/YYModel.h>

/**
 峰谷节电模型
 */
@interface AUXPeakValleyModel : NSObject <YYModel, NSCopying>

@property (nonatomic, strong) NSString *peakValleyId; // 波峰波谷表主键

@property (nonatomic, strong) NSString *deviceId;

@property (nonatomic, assign) BOOL on;  // App是否开启波峰波谷功能 0:未开启 1：开启

@property (nonatomic, assign) NSInteger peakStartHour;      // 波峰开始小时
@property (nonatomic, assign) NSInteger peakStartMinute;    // 波峰开始分钟
@property (nonatomic, assign) NSInteger peakEndHour;        // 波峰结束小时
@property (nonatomic, assign) NSInteger peakEndMinute;      // 波峰开始分钟

@property (nonatomic, assign) NSInteger valleyStartHour;    // 波谷开始小时
@property (nonatomic, assign) NSInteger valleyStartMinute;  // 波谷开始分钟
@property (nonatomic, assign) NSInteger valleyEndHour;      // 波谷结束小时
@property (nonatomic, assign) NSInteger valleyEndMinute;    // 波谷结束分钟

@property (nonatomic, strong) NSString *addTime;    // (旧设备)

/// 根据开始时间和结束时间，生成波峰时间段 (如: 23:00-09:00)
@property (nonatomic, strong, readonly) NSString *peakTimePeriod;

/// 根据开始时间和结束时间，生成波谷时间段 (如: 23:00-09:00)
@property (nonatomic, strong, readonly) NSString *valleyTimePeriod;

/**
 将峰谷节电模型转换为SDK的峰谷节电

 @return SDK峰谷节电
 */
- (AUXACPeakValleyPower *)convertToSDKPeakValleyPower;

/**
 根据SDK峰谷节电的值更新属性值

 @param peakValleyPower SDK峰谷节电
 */
- (void)setValueWithSDKPeakValleyPower:(AUXACPeakValleyPower *)peakValleyPower;

@end
