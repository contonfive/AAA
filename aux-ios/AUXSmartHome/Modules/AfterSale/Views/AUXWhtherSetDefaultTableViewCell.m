//
//  AUXWhtherSetDefaultTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWhtherSetDefaultTableViewCell.h"

@implementation AUXWhtherSetDefaultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(AUXTopContactModel *)model {
    _model = model;
    if (_model.IsDefault) {
        self.whtherSetDefaultButton.selected = _model.IsDefault;
    }
}

- (IBAction)setDefaultAtcion:(id)sender {
    
    self.whtherSetDefaultButton.selected = !self.whtherSetDefaultButton.selected;
    
    if (self.setDefaultBlock) {
        self.setDefaultBlock(self.whtherSetDefaultButton.selected);
    }
    
}



@end
