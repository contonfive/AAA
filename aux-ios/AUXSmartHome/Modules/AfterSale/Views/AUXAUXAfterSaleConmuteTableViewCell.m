//
//  AUXAUXAfterSaleConmuteTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAUXAfterSaleConmuteTableViewCell.h"

@implementation AUXAUXAfterSaleConmuteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setContactModel:(AUXTopContactModel *)contactModel {
    _contactModel = contactModel;
    
    if (_contactModel) {
        self.nameLabel.text = _contactModel.Name;
        self.phoneLabel.text = _contactModel.Phone;
        self.addressLabel.text = _contactModel.local;
    }
}

@end
