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
 用电限制界面 (控制及状态的更新都交给控制界面来完成)
 */
@interface AUXLimitElectricityViewController : AUXBaseViewController

@property (nonatomic, assign) BOOL on;                  // 用电限制开启/关闭
@property (nonatomic, assign) NSInteger percentage;     // 用电限制百分比

@property (nonatomic, copy) void (^controlBlock)(BOOL on, NSInteger percentage);

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
