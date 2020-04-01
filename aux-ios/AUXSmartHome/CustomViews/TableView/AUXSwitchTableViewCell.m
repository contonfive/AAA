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

#import "AUXSwitchTableViewCell.h"

@implementation AUXSwitchTableViewCell

+ (CGFloat)properHeight {
    return 60;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)actionSwitch:(id)sender {
//    self.switchButton.selected = !self.switchButton.selected;
    
    if (self.switchBlock) {
        self.switchBlock(!self.switchButton.selected);
    }
}

@end
