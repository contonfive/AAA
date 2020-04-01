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

#import "AUXDefinitions.h"

/**
 定时模型 (旧设备的循环规则只可以选择一天)
 */
@interface AUXSchedulerModel : NSObject <YYModel, NSCopying>

@property (nonatomic, strong) NSString *schedulerId;

@property (nonatomic, strong) NSString *deviceId;

@property (nonatomic, assign) NSInteger dst;    // 设备地址，单元机传1，多联机子设备传1~64 (多联机传0，则会控制所有子设备)

@property (nonatomic, assign) NSInteger deviceOperate;
@property (nonatomic, assign) AUXServerDeviceMode mode;
@property (nonatomic, assign) AUXServerWindSpeed windSpeed;
@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, assign) BOOL on;

@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, strong, readonly) NSString *timeString;

/**
 循环规则。例：1,3,5,7
 
 @warning 请勿主动设置该属性的值，请使用 repeatValue
 @see repeatValue
 */
@property (nonatomic, strong) NSString *repeatRule;
@property (nonatomic, assign) NSUInteger repeatValue;   // 循环规则 0b1010100 = 3、5、7
@property (nonatomic, strong, readonly) NSString *repeatDescription; // 循环描述 例：每天、周末、工作日

@property (nonatomic, strong) AUXACBroadlinkCycleTimer *cycleTimer; // SDK定时

/**
 将定时模型转换为SDK的定时

 @return SDK定时
 */
- (AUXACBroadlinkCycleTimer *)convertToSDKCycleTimer;

/**
 根据SDK定时更新值

 @param cycleTimer SDK定时
 */
- (void)setValueWithSDKCycleTimer:(AUXACBroadlinkCycleTimer *)cycleTimer;

/**
 更新SDK定时的值
 */
- (void)updateCycleTimer;

/**
 将定时模型的参数转换为 SDK 的定时参数

 @param gearType 风速档位 (挂机、柜机)
 @param currentControl 设备当前的控制状态 (不能为空)
 @return SDK 的定时参数
 */
- (AUXACControl *)getControlWithGearType:(WindGearType)gearType currentControl:(AUXACControl *)currentControl;

/**
 将SDK定时列表转换为定时模型类别

 @param cycleTimerList SDK定时列表
 @return 定时模型列表
 */
+ (NSMutableArray<AUXSchedulerModel *> *)schedulerListFromSDKCycleTimerList:(NSArray<AUXACBroadlinkCycleTimer *> *)cycleTimerList;

@end
