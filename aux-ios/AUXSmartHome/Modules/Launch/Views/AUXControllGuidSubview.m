//
//  AUXControllGuidSubview.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/12/1.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXControllGuidSubview.h"

@implementation AUXControllGuidSubview

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nextBtn.layer.borderWidth = 2;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    self.pageFirstBtn.hidden = NO;
    self.pageSecondBtn.hidden = NO;
    self.pageThirtBtn.hidden = NO;
    
    self.pageFirstBtn.selected = NO;
    self.pageSecondBtn.selected = NO;
    self.pageFirstBtn.selected = NO;
    
    self.nextBtn.hidden = YES;
    
    if (_index == 0) {
        self.titleLabel.text = @"界面全新改版";
        self.subtitleLabel.text = @"简化控制界面，优化用户体验";
        self.pageFirstBtn.selected = YES;
    } else if (_index == 1) {
        self.titleLabel.text = @"优化配网";
        self.subtitleLabel.text = @"优化配网流程，提升配网成功率";
        self.pageSecondBtn.selected = YES;
    } else if (_index == 2) {
        
        self.pageFirstBtn.hidden = YES;
        self.pageSecondBtn.hidden = YES;
        self.pageThirtBtn.hidden = YES;
        self.nextBtn.hidden = NO;
        
        self.titleLabel.text = @"场景升级";
        self.subtitleLabel.text = @"随心玩转智能场景，体验更佳";
    }
}

- (IBAction)nextAtcion:(id)sender {
    if (self.nextAtcionBlock) {
        self.nextAtcionBlock();
    }
}


@end
