//
//  AUXSetTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/24.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSetTableViewCell.h"

@implementation AUXSetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code暂无可添加设备
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
