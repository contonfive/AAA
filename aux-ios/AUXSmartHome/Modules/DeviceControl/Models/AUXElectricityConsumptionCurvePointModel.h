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

#import "AUXDefinitions.h"

/**
 用电曲线节点模型
 */
@interface AUXElectricityConsumptionCurvePointModel : NSObject <NSCopying, YYModel>

@property (nonatomic, assign) CGFloat peakElectricity;        // 波峰总耗电量
@property (nonatomic, assign) CGFloat valleyElectricity;      // 波谷总耗电电
@property (nonatomic, assign) CGFloat waveFlatElectricity;    // 波平总耗电量

@property (nonatomic, assign, readonly) CGFloat totalElectricity;       // 总耗电量

// X轴的值。日用电曲线为时(0~23)，月用电曲线为日(1~28/29/30/31)，年用电曲线为月份(1~12)。
@property (nonatomic, assign) NSInteger xValue;

// 节点所在的波类型 (日用电曲线)
@property (nonatomic, assign) AUXElectricityCurveWaveType waveType;

// 日期
@property (nonatomic, strong) NSString *dateString;

// 用于曲线绘制
@property (nonatomic, assign) CGPoint point;    // 节点的绘制位置

@end
