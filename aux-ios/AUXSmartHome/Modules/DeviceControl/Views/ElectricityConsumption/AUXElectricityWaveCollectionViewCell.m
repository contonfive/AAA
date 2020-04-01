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

#import "AUXElectricityWaveCollectionViewCell.h"

@implementation AUXElectricityWaveCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.value = 0;
}

- (void)setValue:(NSInteger)value {
    _value = value;
    
    self.valueLabel.text = [NSString stringWithFormat:@"%@", @(value)];
}

- (void)setIndicateColor:(UIColor *)indicateColor {
    _indicateColor = indicateColor;
    
    self.indicateView.backgroundColor = indicateColor;
}

@end
