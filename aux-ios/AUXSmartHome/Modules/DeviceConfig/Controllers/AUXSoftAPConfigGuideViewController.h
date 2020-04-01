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

#import "AUXDeviceModel.h"

/**
 机智云设备 SoftAP 配置指引
 */
@interface AUXSoftAPConfigGuideViewController : AUXBaseViewController

@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *deviceSN;
@property (nonatomic, strong) AUXDeviceModel *deviceModel;  // 设备型号
@property (nonatomic, assign) AUXDeviceConfigType configType;
@end
