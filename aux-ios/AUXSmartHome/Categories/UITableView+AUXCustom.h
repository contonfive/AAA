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

#import <UIKit/UIKit.h>

@interface UITableView (AUXCustom)

/**
 注册 cell

 @param nibName nibName
 @note reuse identifier 会设置为 nibName
 */
- (void)registerCellWithNibName:(NSString *)nibName;

/**
 注册 header or footer view

 @param nibName nibName
 @note reuse identifier 会设置为 nibName
 */
- (void)registerHeaderFooterViewWithNibName:(NSString *)nibName;

@end
