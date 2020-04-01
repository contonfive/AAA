//
//  AUXWiFiChangedAlertView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/2.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWiFiChangedAlertView.h"

@interface AUXWiFiChangedAlertView ()
@end

@implementation AUXWiFiChangedAlertView

+ (instancetype)wifiChangeAlertView {
    AUXWiFiChangedAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:4];
    return alertView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.frame = CGRectMake(0, 0, kScreenWidth-46*SCALEH, 195);
}

- (IBAction)giveUpButtonAction:(UIButton *)sender {
    if (self.giveUpBlock) {
        self.giveUpBlock();
    }
}

- (IBAction)confirmButtonAction:(UIButton *)sender {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}


@end
