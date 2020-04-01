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

#import "AUXControlGuideConfirmView.h"

@implementation AUXControlGuideConfirmView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tipButton.tintColor = [UIColor whiteColor];
    
    UIImage *image = [[UIImage imageNamed:@"check_box_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *selectedImage = [[UIImage imageNamed:@"check_box_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.tipButton setImage:image forState:UIControlStateNormal];
    [self.tipButton setImage:selectedImage forState:UIControlStateSelected];
}

@end
