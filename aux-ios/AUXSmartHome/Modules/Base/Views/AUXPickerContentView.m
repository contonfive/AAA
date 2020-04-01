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

#import "AUXPickerContentView.h"
#import "UIView+AUXCornerRadius.h"

@implementation AUXPickerContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.indicateLabel.hidden = YES;
    self.titleLabel.text = @"";
//    [self setCorner:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    self.backView.layer.masksToBounds = YES;
    self.backView.layer.cornerRadius = 10;
}

@end
