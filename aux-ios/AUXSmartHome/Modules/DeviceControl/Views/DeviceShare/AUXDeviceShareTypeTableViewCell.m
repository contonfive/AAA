//
//  AUXDeviceShareTypeTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceShareTypeTableViewCell.h"
#import "UILabel+AUXCustom.h"
#import "UIColor+AUXCustom.h"

@implementation AUXDeviceShareTypeTableViewCell

- (void)setType:(AUXDeviceShareType)type {
    _type = type;
    
    if (_type == AUXDeviceShareTypeFamily) {
        self.iconImageView.image = [UIImage imageNamed:@"mine_share_icon_family"];
        self.typeLabel.text = @"分享给家人";
        [self.subtitleLabel setLabelAttributedString:@"永久" color:[UIColor colorWithHexString:@"10BFCA"]];
        
    } else if (_type == AUXDeviceShareTypeFriend) {
        self.iconImageView.image = [UIImage imageNamed:@"mine_share_icon_friends"];
        self.typeLabel.text = @"分享给朋友";
        self.subtitleLabel.text = @"对方将获得设备8小时控制权";
        [self.subtitleLabel setLabelAttributedString:@"8小时" color:[UIColor colorWithHexString:@"10BFCA"]];
    }
}


@end
