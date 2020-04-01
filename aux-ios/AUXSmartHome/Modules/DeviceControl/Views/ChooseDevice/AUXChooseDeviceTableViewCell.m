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

#import "UIColor+AUXCustom.h"

@implementation AUXChooseDeviceTableViewCell

+ (CGFloat)properHeight {
    return 90.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.chosen = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setChosen:(BOOL)chosen {
    _chosen = chosen;
    
    self.selectedImageView.highlighted = chosen;
}

- (void)setOffline:(BOOL)offline {
    _offline = offline;
}

@end
