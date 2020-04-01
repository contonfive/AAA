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

#import "AUXFaultTableViewCell.h"

@interface AUXFaultTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailing;

@end

@implementation AUXFaultTableViewCell

+ (CGFloat)properHeight {
    return 60.0;
}

- (void)setHideTimeLabel:(BOOL)hideTimeLabel {
    _hideTimeLabel = hideTimeLabel;
    
    self.timeLabel.hidden = hideTimeLabel;
    
    self.timeLabelWidth.constant = hideTimeLabel ? 0 : 120;
}

@end
