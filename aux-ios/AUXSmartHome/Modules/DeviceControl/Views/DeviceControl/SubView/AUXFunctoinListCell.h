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

#import "AUXDefinitions.h"
#import "AUXDeviceFunctionItem.h"

/**
 设备控制界面，设备功能列表单元
 */
@interface AUXFunctoinListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deviceIconListImageView;

- (void)updateCellWithItem:(AUXDeviceFunctionItem *)item;

@end
