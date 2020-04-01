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

@interface AUXTextField : UITextField

/**
 textField 左边显示的图标。只能在 IB 上设置。
 */
@property (nonatomic, strong) IBInspectable UIImage *iconImage;

/**
 是否在 textField 右边显示隐藏/显示密码的按钮。只能在 IB 上设置。
 */
@property (nonatomic, assign) IBInspectable BOOL showOrHidePassword;

/**
 是否显示 textField 底部的边框线。只能在 IB 上设置。
 */
@property (nonatomic, assign) IBInspectable BOOL showsBottomLine;

/**
 textField 的左边距。只能在 IB 上设置。
 */
@property (nonatomic, assign) IBInspectable CGFloat leftPadding;

@end
