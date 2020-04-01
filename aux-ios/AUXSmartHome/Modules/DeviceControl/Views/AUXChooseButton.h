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

/**
 选择按钮不可点击时的样式

 - AUXChooseButtonDisableStyleGrayWhenSelected: 当button.selected为YES时，才将背景色设置为灰色。
 - AUXChooseButtonDisableStyleGrayAlways: 不可用时，背景色一直为灰色。
 */
typedef NS_ENUM(NSInteger, AUXChooseButtonDisableStyle) {
    AUXChooseButtonDisableStyleGrayWhenSelected,
    AUXChooseButtonDisableStyleGrayAlways,
};

/**
 选择按钮
 */
@interface AUXChooseButton : UIButton

@property (nonatomic, strong) IBInspectable UIColor *normalBackgroundColor;           // 背景色。nil时，显示为白色。
@property (nonatomic, strong) IBInspectable UIColor *selectedBackgroundColor;         // 选中时的背景色。nil时，显示为蓝色。
@property (nonatomic, strong) IBInspectable UIColor *disabledSelectedBackgroundColor; // 不可用时的背景色。nil时，显示为灰色。
@property (nonatomic, strong) IBInspectable UIColor *borderColor;                     // 边框颜色。nil时，取normal状态下的titleColor。

/**
 是否隐藏border。默认为YES，即显示border。
 */
@property (nonatomic, assign) IBInspectable BOOL showsBorder;

/**
 圆角矩形。默认为YES。circleSide为YES时，roundRect不起作用。
 */
@property (nonatomic, assign) IBInspectable BOOL roundRect;

/**
 圆角半径。roundRect为YES时，才起作用。默认为5.0。
 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/**
 按钮的左右两端是否显示为半圆形。默认为NO。
 */
@property (nonatomic, assign) IBInspectable BOOL circleSide;

@property (nonatomic, assign) BOOL disableMode; // 是否可以点击。默认为NO，即可以点击。 (不用enabled是因为要做一些自定义操作)
@property (nonatomic, assign) AUXChooseButtonDisableStyle disableStyle; // 不可点击时的样式。默认为 AUXChooseButtonDisableStyleGrayWhenSelected。

@end
