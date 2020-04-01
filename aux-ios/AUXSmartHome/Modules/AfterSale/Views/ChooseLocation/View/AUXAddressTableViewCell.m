//
//  AUXAddressTableViewCell.m
//  ChooseLocation
//
//  Created by Sekorm on 16/8/26.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "AUXAddressTableViewCell.h"
#import "UIColor+AUXCustom.h"

@interface AUXAddressTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectFlag;
@end
@implementation AUXAddressTableViewCell

- (void)setAddressModel:(AUXAddressModel *)addressModel {
    _addressModel = addressModel;
    _addressLabel.text = _addressModel.text;
    _addressLabel.textColor = _addressModel.isSelected ? [UIColor colorWithHexString:@"256BBD"] : [UIColor blackColor];
    _selectFlag.hidden = !_addressModel.isSelected;
}

@end
