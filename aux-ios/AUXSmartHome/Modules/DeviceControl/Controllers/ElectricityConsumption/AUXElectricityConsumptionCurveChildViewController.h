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

#import "AUXBaseViewController.h"

#import "AUXElectricityConsumptionCurvePointModel.h"
#import "AUXElectricityConsumptionCurveModel.h"
#import "AUXDefinitions.h"

/**
 用电曲线界面 - 子界面 (用电曲线图)
 */
@interface AUXElectricityConsumptionCurveChildViewController : AUXBaseViewController

@property (nonatomic, assign) AUXElectricityCurveDateType dateType;

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;

@property (nonatomic, assign) AUXDeviceSource source;   // 设备类型：旧设备、新设备

@property (nonatomic, strong) NSArray<AUXElectricityConsumptionCurvePointModel *> *pointModelList;

/// 设置了波平、波峰、波谷数据之后，请调用该方法更新曲线。
- (void)updateCurve;

@end
