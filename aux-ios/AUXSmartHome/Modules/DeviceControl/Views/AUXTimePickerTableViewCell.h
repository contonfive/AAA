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

@interface AUXTimePickerTableViewCell : AUXBaseTableViewCell

@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;

@property (nonatomic, copy) void (^didSelectTimeBlock)(NSInteger hour, NSInteger minute);

- (void)selectHour:(NSInteger)hour minute:(NSInteger)minute animated:(BOOL)animated;

@end
