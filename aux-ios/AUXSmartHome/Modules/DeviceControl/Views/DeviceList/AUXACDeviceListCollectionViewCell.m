//
//  AUXACDeviceListCollectionViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXACDeviceListCollectionViewCell.h"
#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"

@interface AUXACDeviceListCollectionViewCell ()

@end

@implementation AUXACDeviceListCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)initSubviews {
    [super initSubviews];
    
}

- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    [super setDeviceInfo:deviceInfo];
}

- (void)updateUI {
    
    [super updateUI];
    
    if (self.offline) {
        self.temperatureLabel.text = @"离线";
        self.modeView.hidden = YES;
        self.coolBtn.hidden = YES;
        self.heatBtn.hidden = YES;
        self.powerBtn.hidden = YES;
        
        return ;
    }
    
    self.powerBtn.selected = self.powerOn;
    
    if (self.powerOn == NO) {
        self.temperatureLabel.text = @"关机";
        self.modeView.hidden = YES;
        self.coolBtn.hidden = YES;
        self.heatBtn.hidden = YES;
        self.powerBtn.hidden = NO;
    }
    
    if (self.powerOn) {
        self.modeView.hidden = NO;
        self.coolBtn.hidden = NO;
        self.heatBtn.hidden = NO;
        self.powerBtn.hidden = NO;
        
        self.modeView.backgroundColor = [self modeColor];
        self.modeLabel.text = [AUXConfiguration getModeName:self.deviceStatus.mode];
    }
    
    [super updateTemperature];
}

#pragma mark actions
- (IBAction)atcionPower:(id)sender {
    
    if (self.powerOn) {
        self.powerBtn.selected = YES;
        [super powerOffAtcion:sender];
    } else {
        self.powerBtn.selected = NO;
        [super powerOnAction:sender];
    }
    
}

- (IBAction)atcionCool:(id)sender {
    [super heatDownAtcion:sender];
}

- (IBAction)actionHeat:(id)sender {
    [super heatUpAtcion:sender];
}

@end
