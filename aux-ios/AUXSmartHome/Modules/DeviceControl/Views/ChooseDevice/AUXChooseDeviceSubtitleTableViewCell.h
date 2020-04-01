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

#import "AUXChooseDeviceTableViewCell.h"

/**
 设备选择列表 - 单元 (选中图标在左侧，且有两个副标题) (用于设备列表选择集中控制的设备)
 */
@interface AUXChooseDeviceSubtitleTableViewCell : AUXChooseDeviceTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;

@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger selectedCount;

@end
