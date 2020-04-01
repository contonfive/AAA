//
//  AUXSubDeviceNameTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSubDeviceNameTableViewCell.h"

@implementation AUXSubDeviceNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)editNameAtcion:(id)sender {
    if (self.editNameBlock) {
        self.editNameBlock();
    }
}


@end
