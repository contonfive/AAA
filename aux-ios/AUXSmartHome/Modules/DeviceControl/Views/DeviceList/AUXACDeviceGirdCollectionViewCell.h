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
#import "AUXDeviceCollectionViewCell.h"


/**
 设备列表的设备单元 (单元机)
 */
@interface AUXACDeviceGirdCollectionViewCell : AUXDeviceCollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIView *modeView;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UIView *powerOnView;
@property (weak, nonatomic) IBOutlet UIButton *coolBtn;
@property (weak, nonatomic) IBOutlet UIButton *heatBtn;

@property (weak, nonatomic) IBOutlet UIView *offAndOfflineView;
@property (weak, nonatomic) IBOutlet UILabel *offAndOfflineLabel;


@end
