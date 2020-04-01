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
 设备选择列表 - 单元 (选中图标在右侧) (用于设备分享选择要分享的设备)
 */
@interface AUXChooseDeviceTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *outLineImageView;
@property (weak, nonatomic) IBOutlet UILabel *outLineLabel;



/// 标识是否被选中。默认为NO。
@property (nonatomic, assign) BOOL chosen;
/**
 集中控制--是否离线
 */
@property (nonatomic,assign) BOOL offline;
@end
