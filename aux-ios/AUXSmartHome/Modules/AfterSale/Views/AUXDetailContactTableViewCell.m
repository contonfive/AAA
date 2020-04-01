//
//  AUXDetailContactTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/26.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDetailContactTableViewCell.h"

@implementation AUXDetailContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTopContactModel:(AUXTopContactModel *)topContactModel {
    _topContactModel = topContactModel;
    
    if (_topContactModel) {
        self.titleLabel.text = _topContactModel.Name;
        self.phoneLabel.text = _topContactModel.Phone;
        self.addressLabel.text = _topContactModel.local;
        self.isDefaultButton.selected = _topContactModel.IsDefault ? YES : NO;
    }
}

- (IBAction)deleteAtcion:(id)sender {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}

- (IBAction)editAtcion:(id)sender {
    if (self.editBlock) {
        self.editBlock();
    }
}

- (IBAction)isDefaultAtcion:(id)sender {
    self.isDefaultButton.selected = !self.isDefaultButton.selected;
    
    if (self.isDefaultBlock) {
        self.isDefaultBlock(self.isDefaultButton.selected);
    }
}


@end
