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

@interface AUXSubtitleTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

// 默认显示。如果直接设置 indicatorImageView.hidden 的值不会调整其他视图的位置。可以使用 showsIndicator。
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

// 默认隐藏。如果直接设置 iconImageView.hidden 的值不会调整其他视图的位置。可以使用 showsIconImageView。
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleLabelTrailing;

@property (nonatomic, assign) BOOL disableMode;

@property (nonatomic, assign) BOOL showsIndicator;  // 默认为YES。
@property (nonatomic, assign) BOOL showsIconImage;  // 默认为NO。

@end
