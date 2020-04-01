//
//  AUXHistoryListTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/7/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXHistoryListTableViewCell.h"

@implementation AUXHistoryListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
