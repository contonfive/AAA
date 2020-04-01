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

#import "AUXDeviceFunctionSwitchTableViewCell.h"

#import "UIColor+AUXCustom.h"

@implementation AUXDeviceFunctionSwitchTableViewCell

+ (CGFloat)properHeight {
    return 80.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:NO];
}

- (void)setStatusOn:(BOOL)statusOn {
    _statusOn = statusOn;
    
    self.switchButton.selected = statusOn;
}

- (IBAction)actionSwitch:(id)sender {
    
    self.statusOn = !self.statusOn;
    
    if (self.switchBlock) {
        self.switchBlock(self.statusOn);
    }
}

@end
