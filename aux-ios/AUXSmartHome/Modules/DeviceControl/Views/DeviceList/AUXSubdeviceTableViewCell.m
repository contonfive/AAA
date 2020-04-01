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

#import "AUXSubdeviceTableViewCell.h"

#import "UIColor+AUXCustom.h"

@interface AUXSubdeviceTableViewCell ()


@end

@implementation AUXSubdeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _editingName = NO;
    
    self.titleButton.enabled = NO;
    [self.titleButton setImage:nil forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Setters & Getters

+ (CGFloat)properHeight {
    return 90;
}

- (void)setDeviceName:(NSString *)deviceName {
    _deviceName = deviceName;
    [self.titleButton setTitle:deviceName forState:UIControlStateNormal];
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
    self.iconImageView.image = icon;
}

- (void)setEditingName:(BOOL)editingName {
    _editingName = editingName;
    
    if (editingName) {
        [self.titleButton setImage:[UIImage imageNamed:@"device_list_cell_edit_blue"] forState:UIControlStateNormal];
    } else {
        [self.titleButton setImage:nil forState:UIControlStateNormal];
    }
    
    self.indicatorImageView.hidden = editingName;
}

#pragma mark - Actions

- (IBAction)actionEditName:(id)sender {
    
}

@end
