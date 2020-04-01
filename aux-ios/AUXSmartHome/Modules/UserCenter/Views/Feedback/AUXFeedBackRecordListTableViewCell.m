//
//  AUXFeedBackRecordListTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXFeedBackRecordListTableViewCell.h"

@implementation AUXFeedBackRecordListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.numberLabel.layer.masksToBounds = YES;
    self.numberLabel.layer.cornerRadius = 9;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
