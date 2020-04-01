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
#import "AUXDeviceShareInfo.h"
#import "AUXDeviceInfo.h"

/**
 设备分享 (点击设备列表导航栏右侧弹出菜单中的【分享设备】进入)
 */
@interface AUXDeviceShareViewController : AUXBaseViewController
@property (nonatomic,strong) AUXDeviceInfo *deviceInfo;
@end
