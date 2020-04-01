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

#import "AUXBaseTableViewCell.h"

/**
 右侧带有一个switch按钮的 tableViewCell (用于定时列表、睡眠DIY列表)
 */
@interface AUXDeviceFunctionSwitchTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (nonatomic, assign) BOOL statusOn;

@property (nonatomic, copy) void (^switchBlock)(BOOL on);

@end
