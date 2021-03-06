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

@interface AUXSwitchTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (nonatomic, copy) void (^switchBlock)(BOOL on);

@end
