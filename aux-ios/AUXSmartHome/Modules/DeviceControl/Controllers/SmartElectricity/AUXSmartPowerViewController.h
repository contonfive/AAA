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
#import "AUXDeviceControlViewController.h"

#import "AUXSmartPowerModel.h"
#import "AUXDeviceInfo.h"


/**
 智能用电界面
 */
@interface AUXSmartPowerViewController : AUXBaseViewController

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;
@property (nonatomic, assign) NSInteger powerRating;    // 额定功率，单位W

@property (nonatomic, strong) AUXSmartPowerModel *smartPowerModel;

@property (nonatomic, weak) AUXDeviceControlViewController *deviceControlViewController;

@end
