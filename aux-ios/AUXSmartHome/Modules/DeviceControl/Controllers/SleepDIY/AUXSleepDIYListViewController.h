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
#import "AUXDeviceStatus.h"
#import "AUXDeviceInfo.h"
#import "AUXSleepDIYModel.h"

@class AUXDeviceControlViewController;

/**
 睡眠DIY列表
 */
@interface AUXSleepDIYListViewController : AUXBaseViewController

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;
@property (nonatomic, strong) AUXACControl *deviceControl;
@property (nonatomic, strong) AUXDeviceFeature *deviceFeature;
@property (nonatomic,strong) AUXDeviceStatus *deviceStatus;

/// 设备控制类型。默认为 AUXDeviceControlTypeVirtual 虚拟体验。
@property (nonatomic, assign) AUXDeviceControlType controlType;

@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSMutableArray<AUXSleepDIYModel *> *sleepDIYList;

@property (nonatomic, strong) NSString *currentOnSleepDIYId;
@property (nonatomic, assign) BOOL sleepDIY;
@property (nonatomic,assign) BOOL oldDevice;

@property (nonatomic, weak) AUXDeviceControlViewController *deviceControlViewController;
@end
