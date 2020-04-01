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

#import "AUXMultiSelectButtonTableViewCell.h"

@interface AUXSchedulerCycleTableViewCell : AUXMultiSelectButtonTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(AUXChooseButton) NSArray *cycleBtnsCollection;

@property (weak, nonatomic) IBOutlet UIView *customDayView;

@property (nonatomic, copy) void (^cycleBtnDidSlectedBlcok)(NSInteger tag);
@end
