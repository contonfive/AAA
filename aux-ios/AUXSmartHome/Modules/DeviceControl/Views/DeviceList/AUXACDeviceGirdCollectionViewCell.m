/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXACDeviceGirdCollectionViewCell.h"

#import "AUXConfiguration.h"
#import "UIColor+AUXCustom.h"
#import "UIView+MIExtensions.h"

@interface AUXACDeviceGirdCollectionViewCell ()

@end

@implementation AUXACDeviceGirdCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 3;
    
    self.contentView.layer.borderColor = [UIColor colorWithHexString:@"EEEEEE"].CGColor;
    self.contentView.layer.borderWidth = 1;
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
        self.powerBtn.hidden = YES;
        self.modeView.hidden = YES;
        self.powerOnView.hidden = YES;
        self.offAndOfflineView.hidden = NO;
        self.offAndOfflineLabel.text = @"离线";
        return ;
    }
    
    self.powerBtn.selected = self.powerOn;
    
    if (!self.powerOn) {
        self.powerBtn.hidden = NO;
        self.modeView.hidden = YES;
        self.powerOnView.hidden = YES;
        self.offAndOfflineView.hidden = NO;
        self.offAndOfflineLabel.text = @"关机";
        return ;
    }
    
    if (self.powerOn) {
        self.powerBtn.hidden = NO;
        self.modeView.hidden = NO;
        self.powerOnView.hidden = NO;
        self.offAndOfflineView.hidden = YES;
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
