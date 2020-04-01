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

/**
 设备信息界面
 */
@interface AUXDeviceInfoViewController : AUXBaseViewController

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;
@property (nonatomic,strong) AUXDeviceStatus *deviceStatus;
@property (nonatomic, strong) NSString *address;    // 子设备地址

@property (nonatomic,assign) AUXDeviceControlType controlType;

@property (nonatomic,assign) BOOL oldDevice;
//@property (nonatomic, assign) BOOL isSubdevice;

@end
