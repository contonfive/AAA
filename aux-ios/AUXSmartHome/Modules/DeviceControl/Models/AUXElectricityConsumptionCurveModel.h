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

#import "AUXElectricityConsumptionCurvePointModel.h"

#import "AUXDefinitions.h"

/**
 用电曲线节点数据 (Saas服务器返回)
 */
@interface AUXECPowerCurveData : NSObject

@property (nonatomic, assign) NSInteger timeShaft; // 时间轴，选择日用电曲线为时间轴单位为小时，选择月用电曲线为时间轴单位为天，选择月用电曲线为时间轴单位为月份

@property (nonatomic, assign) CGFloat peakElectricity;        // 波峰总耗电量
@property (nonatomic, assign) CGFloat valleyElectricity;      // 波谷总耗电电
@property (nonatomic, assign) CGFloat waveFlatElectricity;    // 波平总耗电量

@end

/**
 用电曲线模型
 */
@interface AUXElectricityConsumptionCurveModel : NSObject <YYModel>

@property (nonatomic, strong) NSArray<AUXECPowerCurveData *> *powerCurveDatas; // 用电曲线数据
@property (nonatomic, assign) CGFloat sumPeakElectricity;         // 波峰总耗电量
@property (nonatomic, assign) CGFloat sumValleyElectricity;       // 波谷总耗电电
@property (nonatomic, assign) CGFloat sumWaveFlatElectricity;     // 波平总耗电量
@property (nonatomic, assign) CGFloat total; // 全部耗电量

// 波峰波谷时间段，格式：num1,num2_num3,num4|num5,num6 日用电曲线需用到
// 如：10,15|0,4_20,23 表示波峰时段为 10~15，波谷时段为 0~4、20~23 (波谷时段跨天)
@property (nonatomic, strong) NSString *timeBucket;

@property (nonatomic, strong) NSMutableArray<NSValue *> *timePeriodArray;    // 波平、波峰、波谷时段

@property (nonatomic, assign) AUXElectricityCurveDateType dateType; // 数据日期类型

@property (nonatomic, assign) AUXDeviceSource source;   // 设备类型：旧设备、新设备

// 手机当前的年月日时
@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger currentMonth;
@property (nonatomic, assign) NSInteger currentDay;
@property (nonatomic, assign) NSInteger currentHour;

// 当前请求数据的年月日时
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;

// 用电曲线节点列表
@property (nonatomic, strong) NSArray<AUXElectricityConsumptionCurvePointModel *> *pointModelList;

/**
 更新手机当前时间

 @param dateComponents 日期
 */
- (void)setCurrentDateWithComponents:(NSDateComponents *)dateComponents;

/**
 更新请求数据的时间
 
 @param dateComponents 日期
 */
- (void)setRequestDateWithComponents:(NSDateComponents *)dateComponents;

/**
 更新用电曲线数据，波平、波峰、波谷用电量及总用电量，波峰波谷时段

 @param curveModel 曲线模型
 */
- (void)updatePowerCurveDatasWithModel:(AUXElectricityConsumptionCurveModel *)curveModel;

/**
 将用电曲线数据 powerCurveDatas 解析为 波平、波峰、波谷数据。
 */
- (void)analysePowerCurveDatas;

/**
 清空数据
 */
- (void)clearAllPointModels;

/**
 移除不需要的节点。查询数据的时候，接口会填充缺漏的数据，当查询日期是当天、当月、当年时，
 移除超过当前时、天、月的数据。
 */
- (void)removeUnnecessaryPointModels;

/**
 计算总用电量。计算之后，可以通过 sumPeakElectricity、sumValleyElectricity、sumWaveFlatElectricity
 获取波平、波峰、波谷总用电量。

 @return 总用电量
 */
- (CGFloat)calculateTotalDegrees;

// 测试数据
- (void)setYearTestData;
- (void)setMonthTestData;
- (void)setDayTestData;

@end
