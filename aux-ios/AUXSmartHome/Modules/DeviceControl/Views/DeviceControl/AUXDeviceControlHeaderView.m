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

#import "AUXDeviceControlHeaderView.h"

@interface AUXDeviceControlHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *anotherContentView;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorImageView;
@end

@implementation AUXDeviceControlHeaderView

+ (CGFloat)properHeight {
    return 54;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.disclosureIndicatorImageView.hidden = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapHeaderView:)];
    [self.anotherContentView addGestureRecognizer:tapGesture];
    self.anotherContentView.userInteractionEnabled = YES;
    
}

- (void)setShowsDisclosureIndicator:(BOOL)showsDisclosureIndicator {
    _showsDisclosureIndicator = showsDisclosureIndicator;
    self.disclosureIndicatorImageView.hidden = !showsDisclosureIndicator;
}

- (void)actionTapHeaderView:(UITapGestureRecognizer *)sender {
    if (self.tapHeaderViewBlock) {
        self.tapHeaderViewBlock();
    }
}

@end
