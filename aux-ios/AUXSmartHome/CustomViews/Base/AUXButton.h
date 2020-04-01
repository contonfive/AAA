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
#import <QMUIKit/QMUIKit.h>

@interface AUXButton : QMUIButton

/**
 按钮的左右两端是否显示为半圆形。只能在 IB 上设置。
 */
@property (nonatomic, assign) IBInspectable BOOL roundRect;

@end
