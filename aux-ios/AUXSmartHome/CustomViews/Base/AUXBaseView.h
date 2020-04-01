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

@interface AUXBaseView : UIView

/**
 从 UINib 中实例化对象

 @return 实例化对象
 @note xib 的名字需要和类名一样
 */
+ (instancetype)instantiateFromNib;

/**
 子类可以重写该方法，在里面加载额外的 nib
 */
- (void)loadNib;

/**
 子类可以重写该方法，执行一些视图初始化的操作
 */
- (void)initSubviews;

@end
