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

#import "AUXMessageManagerTableViewCell.h"
#import "UIColor+AUXCustom.h"

@implementation AUXMessageManagerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    

    self.view.layer.cornerRadius = 2;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderColor = [UIColor colorWithHexString:@"ECEDEE"].CGColor;
    self.view.layer.borderWidth = 1;
    self.imageHeightZeroConstraint = [self.messageImage.heightAnchor constraintEqualToConstant:0];
}


@end
