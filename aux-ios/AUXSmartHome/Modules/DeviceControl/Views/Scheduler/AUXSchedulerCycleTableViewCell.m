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

#import "AUXSchedulerCycleTableViewCell.h"
#import "AUXChooseButton.h"
#import "UIImage+QMUI.h"
#import "UIColor+AUXCustom.h"
@implementation AUXSchedulerCycleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.customDayView.hidden = YES;
    self.customDayView.layer.cornerRadius = 5;
    self.customDayView.layer.masksToBounds = YES;
    
    for (AUXChooseButton *btn in self.cycleBtnsCollection) {
        [btn addTarget:self action:@selector(cycleAtcion:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = btn.frame.size.width / 2;
    }
}

- (void)cycleAtcion:(UIButton *)btn {
    
    for (AUXChooseButton *btn in self.cycleBtnsCollection) {
        btn.selected = NO;
    }
    
    btn.selected = !btn.selected;
    
    if (btn.tag == 203) {
        if (btn.selected) {
            self.customDayView.hidden = NO;
        } 
    } else {
        self.customDayView.hidden = YES;
    }
    
    NSInteger tag = btn.tag - 200;
    
    if (self.cycleBtnDidSlectedBlcok) {
        self.cycleBtnDidSlectedBlcok(tag);
    }
}

@end
