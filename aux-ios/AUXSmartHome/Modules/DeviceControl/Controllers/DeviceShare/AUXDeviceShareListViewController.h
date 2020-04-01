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

@class AUXDeviceShareInfo;

/**
 设备分享列表 (家人、朋友)
 */
@interface AUXDeviceShareListViewController : AUXBaseViewController

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic,strong) NSArray<AUXDeviceShareInfo *> *deviceShareInfoList;

- (void)removeCellAtIndexPath:(NSIndexPath *)indexPath;
@end
