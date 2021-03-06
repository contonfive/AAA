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

@interface AUXMessageManagerHeaderView : UITableViewHeaderFooterView
@property (strong, nonatomic)  UILabel *titleLabel;

@property (nonatomic,strong , setter=setBackColor:) UIColor *backColor;

@end
