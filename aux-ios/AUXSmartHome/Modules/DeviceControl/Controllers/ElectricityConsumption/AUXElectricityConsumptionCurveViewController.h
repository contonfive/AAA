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

#import "AUXDeviceInfo.h"

/**
 用电曲线界面
 */
@interface AUXElectricityConsumptionCurveViewController : AUXBaseViewController

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;

@property (nonatomic, assign) AUXElectricityCurveDateType currentDateType;

@property (nonatomic, copy) void (^didChangeDateTypeBlock)(AUXElectricityCurveDateType dateType);

@end
