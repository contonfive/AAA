//
//  AUXTodayExensionNoDeviceTableViewCell.m
//  AUXTodayExtension
//
//  Created by AUX Group Co., Ltd on 2018/6/4.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTodayExensionNoDeviceTableViewCell.h"
#import "AUXConfiguration.h"
#import "UILabel+AUXCustom.h"

@implementation AUXTodayExensionNoDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.centerTitleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(atcionTap:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark atcion
- (void)atcionTap:(UITapGestureRecognizer *)sender {
    
    self.cellTapAtcion(self.toMainAppType);
    
}

- (void)setShouldLogin:(BOOL)shouldLogin {
    _shouldLogin = shouldLogin;
    if (_shouldLogin) {
        self.centerTitleLabel.text = @"登陆后控制设备,前往登录";
        [self.centerTitleLabel setLabelAttributedString:@"前往登录" color:[AUXConfiguration sharedInstance].blueColor];
        self.toMainAppType = AUXExtensionPushToMainAppTypeOfLogin;
    }
}

- (void)setShouldAddDevice:(BOOL)shouldAddDevice {
    _shouldAddDevice = shouldAddDevice;
    if (_shouldAddDevice) {
        self.centerTitleLabel.text = @"未在小组件中添加设备,前往设置";
        [self.centerTitleLabel setLabelAttributedString:@"前往设置" color:[AUXConfiguration sharedInstance].blueColor];
        self.toMainAppType = AUXExtensionPushToMainAppTypeOfAddDevice;
    }
}

- (void)setShouldAgainLogin:(BOOL)shouldAgainLogin {
    _shouldAgainLogin = shouldAgainLogin;
    if (_shouldAgainLogin) {
        self.centerTitleLabel.text = @"用户账号缓存已过期,重新登录";
        [self.centerTitleLabel setLabelAttributedString:@"重新登录" color:[AUXConfiguration sharedInstance].blueColor];
        self.toMainAppType = AUXExtensionPushToMainAppTypeOfDeviceList;
    }
}

@end
