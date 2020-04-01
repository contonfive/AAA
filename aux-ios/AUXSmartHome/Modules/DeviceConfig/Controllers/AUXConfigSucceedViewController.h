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

#import <GizWifiSDK/GizWifiSDK.h>

/**
 设备配置成功，设置设备名称
 */
@interface AUXConfigSucceedViewController : AUXBaseViewController

@property (nonatomic, assign) AUXDeviceConfigType configType;

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic,assign) BOOL isfromScan;

@end
