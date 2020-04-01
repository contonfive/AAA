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

#import "AUXDeviceInfo.h"
#import "AUXPeakValleyModel.h"


/**
 峰谷节电界面
 */
@interface AUXPeakValleyViewController : AUXBaseViewController

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;

@property (nonatomic, strong) AUXPeakValleyModel *peakValleyModel;

@property (nonatomic, weak) AUXDeviceControlViewController *deviceControlViewController;

@end
