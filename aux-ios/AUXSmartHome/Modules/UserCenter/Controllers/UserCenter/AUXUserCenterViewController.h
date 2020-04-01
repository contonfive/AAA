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
 我的 (该VC的界面在 Homepage.storyboard 中)
 */
@interface AUXUserCenterViewController : AUXBaseViewController


- (void)showComponentViewController;

/**
 根据 index 跳转到售后指定页面

 @param index index
 */
- (void)pushToAfterSaleWithIndex:(NSInteger)index;

@end
