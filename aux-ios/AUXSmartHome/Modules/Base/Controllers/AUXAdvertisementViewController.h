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

/**
 App第一次启动时的广告页
 */
@interface AUXAdvertisementViewController : AUXBaseViewController

@property (nonatomic, copy) void (^advertismentViewControllerShowBlock)(void);

@end
