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

#import "AUXButton.h"

@implementation AUXButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.roundRect) {
        CGFloat height = CGRectGetHeight(self.frame);
        self.layer.cornerRadius = height / 2.0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.roundRect) {
        CGFloat height = CGRectGetHeight(self.frame);
        self.layer.cornerRadius = height / 2.0;
    }
}

@end
