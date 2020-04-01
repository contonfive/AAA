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
 智能用电模型
 
 @note 智能用电开始时间、结束时间目前不支持设置到分钟，startMinute、endMinute只是预留位
 */
@interface AUXSmartPowerModel : NSObject <YYModel, NSCopying>

//@property (nonatomic, strong) NSString *smartElecId; // 智能用电规则Id

@property (nonatomic, strong) NSString *deviceId; // 设备Id
@property (nonatomic, strong) NSString *mac;

@property (nonatomic, assign) NSInteger startHour;      // 开始时间 时
@property (nonatomic, assign) NSInteger startMinute;    // 开始时间 分
@property (nonatomic, assign) NSInteger endHour;
@property (nonatomic, assign) NSInteger endMinute;

@property (nonatomic, assign) AUXSmartPowerCycle executeCycle; // 执行周期 (旧设备不设重复周期)
@property (nonatomic, assign) AUXSmartPowerMode mode;       // 设备操作
@property (nonatomic, assign) NSInteger on;
@property (nonatomic, assign) NSInteger totalElec; // 期望用电

@property (nonatomic, strong) NSString *addTime;    // 智能用电创建时间 (旧设备)

/// 根据开始时间和结束时间，生成时间段 (如: 23:00-09:00)
@property (nonatomic, strong, readonly) NSString *timePeriod;

/**
 将智能用电模型转换为SDK的智能用电

 @return SDK智能用电
 */
- (AUXACSmartPower *)convertToSDKSmartPower;

/**
 根据SDK智能用电的值更新属性值

 @param smartPower SDK智能用电
 */
- (void)setValueWithSDKSmartPower:(AUXACSmartPower *)smartPower;

@end
