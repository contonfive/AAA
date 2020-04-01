//
//  AUXSchedulerSubTitleCollectionCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSchedulerSubTitleCollectionCell.h"
#import "UIColor+AUXCustom.h"

@implementation AUXSchedulerSubTitleCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.contentView.layer.cornerRadius = 5;
//    self.contentView.layer.masksToBounds = YES;
    
    self.titleLabel.layer.borderColor = [UIColor colorWithHexString:@"E5E5E5"].CGColor;
    self.titleLabel.layer.borderWidth = 1;
    self.titleLabel.layer.cornerRadius = 5;
    self.titleLabel.layer.masksToBounds = YES;
}

- (IBAction)btnSelectedAtcion:(id)sender {
    
    AUXButton *btn = (AUXButton *)sender;
    
    btn.selected = !btn.selected;
    
    if (self.btnSlectedBlock) {
        self.btnSlectedBlock(btn.selected);
    }
}


@end
