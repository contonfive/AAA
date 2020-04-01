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
 配置失败
 */
@interface AUXConfigFailViewController : AUXBaseViewController

@property (nonatomic, assign) AUXDeviceConfigType configType;

@property (nonatomic,assign) AUXConfigStatus configStatus;

@property (nonatomic,strong) AUXACDevice *currentDevice;

@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *deviceSN;
@property (nonatomic, strong) AUXDeviceModel *deviceModel;  // 设备型号
@property (nonatomic,assign) BOOL isfromScan;


@end
