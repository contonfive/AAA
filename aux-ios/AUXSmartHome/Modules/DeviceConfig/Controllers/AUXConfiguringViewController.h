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
 设备配置中
 */
@interface AUXConfiguringViewController : AUXBaseViewController

@property (nonatomic, assign) AUXDeviceConfigType configType;
@property (nonatomic, strong) NSString *deviceSN;
@property (nonatomic, strong) AUXDeviceModel *deviceModel;  // 设备型号
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic,assign) BOOL isfromScan;

/**
 绑定设备，在失败页面需要用到，所以引出来

 @param acDevice 需要绑定的设备
 */
- (void)bindDeviceWithACDevice:(AUXACDevice *)acDevice;

@end
