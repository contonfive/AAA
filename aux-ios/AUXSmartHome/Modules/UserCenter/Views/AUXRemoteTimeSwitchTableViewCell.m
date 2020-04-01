//
//  AUXRemoteTimeSwitchTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/17.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXRemoteTimeSwitchTableViewCell.h"

@implementation AUXRemoteTimeSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)switchAtcion:(id)sender {
    self.switchButton.selected = !self.switchButton.selected;
    if (self.switchBlock) {
        self.switchBlock();
    }
}


@end
