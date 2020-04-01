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

#import "AUXSubtitleTableViewCell.h"

#import "AUXConfiguration.h"

@implementation AUXSubtitleTableViewCell

+ (CGFloat)properHeight {
    return 60;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _showsIndicator = YES;
    _showsIconImage = NO;
    
    self.iconImageView.hidden = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDisableMode:(BOOL)disableMode {
    _disableMode = disableMode;
    
    self.subtitleLabel.textColor = disableMode ? [UIColor lightGrayColor] : [AUXConfiguration sharedInstance].blueColor;
    self.indicatorImageView.hidden = disableMode;
}

- (void)setShowsIndicator:(BOOL)showsIndicator {
    if (_showsIndicator != showsIndicator) {
        _showsIndicator = showsIndicator;
        
        self.indicatorImageView.hidden = !showsIndicator;
        self.subtitleLabelTrailing.constant = showsIndicator ? 35 : 18;
    }
}

- (void)setShowsIconImage:(BOOL)showsIconImage {
    if (_showsIconImage != showsIconImage) {
        _showsIconImage = showsIconImage;
        
        self.iconImageView.hidden = !showsIconImage;
        self.titleLabelLeading.constant = showsIconImage ? 62 : 20;
    }
}

@end
