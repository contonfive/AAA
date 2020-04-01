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
 用户协议界面 (注册时)
 */
@interface AUXUseProtocolViewController : AUXBaseViewController

/// 退出按钮点击回调block
@property (nonatomic, copy) void (^exitBlock)(void);

/// 同意按钮点击回调block
@property (nonatomic, copy) void (^agreeBlock)(void);
/// 返回按钮点击回调block
@property (nonatomic, copy) void (^backBlock)(void);

@end
