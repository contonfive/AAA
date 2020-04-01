//
//  AUXRemoteTimeSetTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/17.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXRemoteTimeSetTableViewCell.h"

@implementation AUXRemoteTimeSetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setLimitModel:(AUXPushLimitModel *)limitModel {
    _limitModel = limitModel;
    
    NSString *time = [NSString stringWithFormat:@"%.2ld:%.2ld--%.2ld:%.2ld" , _limitModel.startHour , _limitModel.startMinute , _limitModel.endHour , _limitModel.endMinute];
    [self.contentButton setTitle:time forState:UIControlStateNormal];
}

- (IBAction)contentAtcion:(id)sender {
    if (self.contentBlock) {
        self.contentBlock();
    }
}
@end
