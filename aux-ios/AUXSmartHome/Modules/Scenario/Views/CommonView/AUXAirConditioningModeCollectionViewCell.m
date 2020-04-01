//
//  AUXAirConditioningModeCollectionViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/12.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAirConditioningModeCollectionViewCell.h"
#import "UIColor+AUXCustom.h"

@implementation AUXAirConditioningModeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.modeTitleLabel.layer.masksToBounds = YES;
    self.modeTitleLabel.layer.cornerRadius= 5;
    self.modeTitleLabel.layer.borderWidth = 1;
    self.modeTitleLabel.layer.borderColor= [UIColor colorWithHexString:@"E5E5E5"].CGColor;
}

//- (void)setModel:(AUXCollectCellModel *)model{
//    model.isSelect = !model.isSelect;
//    self.modeTitleLabel.text = model.modetitle;
//    if (model.isSelect) {
//        self.modeTitleLabel.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
//        self.modeTitleLabel.textColor = [UIColor whiteColor];
//    }else{
//        self.modeTitleLabel.backgroundColor = [UIColor clearColor];
//        self.modeTitleLabel.textColor = [UIColor colorWithHexString:@"666666"];
//    }
//}

@end
