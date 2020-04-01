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

#import "AUXDeviceFunctionSubtitleTableViewCell.h"

@interface AUXDeviceFunctionSubtitleTableViewCell()

@end

@implementation AUXDeviceFunctionSubtitleTableViewCell

+ (CGFloat)properHeight {
    return 48.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setPeakValleyModel:(AUXPeakValleyModel *)peakValleyModel {
    _peakValleyModel = peakValleyModel;
    
    if (_peakValleyModel) {
        self.peakTimeLabel.text = _peakValleyModel.peakTimePeriod;
        self.valleyTimeLabel.text = _peakValleyModel.valleyTimePeriod;
    }
}

@end
