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

#import "AUXFunctoinListCell.h"

#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"

@implementation AUXFunctoinListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateCellWithItem:(AUXDeviceFunctionItem *)item {
    
    self.titleLabel.text = item.title;
    
    NSString *imageNameNor = item.imageNor;
    NSString *imageNameSel = item.imageSel;
    
    if (item.selected && !AUXWhtherNullString(imageNameSel)) {
        self.iconImageView.image = [UIImage imageNamed:imageNameSel];
    } else {
        self.iconImageView.image = [UIImage imageNamed:imageNameNor];
    }
    
    if (item.disabled) {
        self.backView.alpha = 0.3;
    } else {
        self.backView.alpha = 1;
    }
    
}

@end
