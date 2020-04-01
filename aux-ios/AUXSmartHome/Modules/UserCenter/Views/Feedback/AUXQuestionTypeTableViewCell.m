//
//  AUXQuestionTypeTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXQuestionTypeTableViewCell.h"

@implementation AUXQuestionTypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
