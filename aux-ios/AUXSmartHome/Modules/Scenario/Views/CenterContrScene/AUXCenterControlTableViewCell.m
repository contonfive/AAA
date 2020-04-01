//
//  AUXCenterControlTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXCenterControlTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AUXCenterControlTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //点击整个cell时
    self.selectBtn.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(AUXDeviceInfo *)model{
    
    _model = model;
    self.nameLabel.text = [NSString stringWithFormat:@"%@",model.alias];
    
    if (model.isSelected) {
        [self.selectBtn setImage:[UIImage imageNamed:@"common_btn_selected"] forState:UIControlStateNormal];
    } else {
        [self.selectBtn setImage:[UIImage imageNamed:@"common_btn_unselected"] forState:UIControlStateNormal];
    }
    [self.IconImageview sd_setImageWithURL: [NSURL URLWithString:model.deviceMainUri] placeholderImage:nil];
}
@end
