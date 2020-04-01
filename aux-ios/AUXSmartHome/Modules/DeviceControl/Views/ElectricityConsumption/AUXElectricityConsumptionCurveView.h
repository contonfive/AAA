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

#import <UIKit/UIKit.h>

#import "AUXElectricityConsumptionCurvePointModel.h"

#import "AUXDefinitions.h"

/**
 用电曲线
 */
@interface AUXElectricityConsumptionCurveView : UIView

@property (class, nonatomic, assign, readonly) CGFloat properHeightForCell;

@property (nonatomic, assign) AUXElectricityCurveDateType dateType;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign, readonly) NSInteger numberOfDaysForMonth; // 对应年月的天数

@property (nonatomic, assign) CGFloat rightMargin;  // 默认为20

@property (nonatomic, strong) NSString *unitString;

@property (nonatomic, strong) UIColor *scaleColor;  // 刻度颜色
@property (nonatomic, strong) UIFont *scaleFont;    // 刻度字体
@property (nonatomic, strong) UIColor *lineColor;   // 线条颜色

@property (nonatomic, assign) NSInteger yAxisMinValue;      // Y轴最小值
@property (nonatomic, assign) NSInteger yAxisMaxValue;      // Y轴最大值
@property (nonatomic, assign) NSInteger yAxisScaleCount;    // Y轴刻度个数 (包含最小值、最大值)

@property (nonatomic, assign) BOOL oldDevice;   // 新设备、旧设备。默认为NO，即新设备。

// 曲线数据
@property (nonatomic, strong) NSArray<AUXElectricityConsumptionCurvePointModel *> *pointModelList;

- (void)updateCurveView;

@end
