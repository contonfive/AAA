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
#import "AUXChooseButton.h"

/**
 智能用电 - 设备操作 (UI在 DeviceControl.storyboard中)
 */
@interface AUXIntelligentElectricityOperationCell : AUXMultiSelectButtonTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fastImageView;
@property (weak, nonatomic) IBOutlet UIImageView *balanseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *standardImageView;

@property (nonatomic,strong) NSMutableArray *imageArray;

@end
