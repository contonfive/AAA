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
#import "AUXPeakValleyModel.h"

/**
 设备功能列表 tableViewCell (用于智能用电)
 */
@interface AUXDeviceFunctionSubtitleTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *peakTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valleyTimeLabel;

@property (nonatomic, strong) AUXPeakValleyModel *peakValleyModel;

@end
