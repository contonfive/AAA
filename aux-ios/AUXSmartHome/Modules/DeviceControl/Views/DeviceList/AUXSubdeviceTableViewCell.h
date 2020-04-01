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

#import "AUXBaseTableViewCell.h"

/**
 多联机子设备列表单元
 */
@interface AUXSubdeviceTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIButton *titleButton; // 设备名

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *offLineImageView;
@property (weak, nonatomic) IBOutlet UILabel *offLineLabel;

@property (nonatomic, assign) BOOL editingName;     // 默认为NO

@property (nonatomic, strong) NSString *deviceName; // 设备名
@property (nonatomic, strong) UIImage *icon;        // 设备图标

@end
