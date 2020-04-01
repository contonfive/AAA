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

#import "AUXDefinitions.h"

/**
 设备分享 二维码显示界面
 */
@interface AUXDeviceShareQRCodeViewController : AUXBaseViewController

@property (nonatomic, strong) NSString *deviceId;

/**
 使用这个页面，是为了分享设备还是分享家庭邀请
 */
@property (nonatomic,assign) AUXQRCodeStatus qrCodeStatus;
@property (nonatomic, assign) AUXDeviceShareType type;  // 分享对象类型
@property (nonatomic, strong) NSString *qrContent;
@property (nonatomic, strong) NSMutableArray *deviceNames;

/**
 家庭名称
 */
@property (nonatomic,copy) NSString *familyName;

@end
