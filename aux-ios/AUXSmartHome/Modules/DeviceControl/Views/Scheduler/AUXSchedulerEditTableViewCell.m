//
//  AUXSchedulerEditTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSchedulerEditTableViewCell.h"
#import "AUXConfiguration.h"

@implementation AUXSchedulerEditTableViewCell

+ (CGFloat)properHeight {
    return 80.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSchedulerModel:(AUXSchedulerModel *)schedulerModel {
    _schedulerModel = schedulerModel;
}

- (void)setType:(AUXDeviceControlSchedulerType)type {
    _type = type;
    
    if (_type == AUXDeviceControlSchedulerTypeOfTime) {
        self.iconImageView.image = [UIImage imageNamed:@"device_icon_timing"];
        self.schedulerLabel.hidden = NO;
        self.timeLabel.text = self.schedulerModel.timeString;
        self.cycleLabel.text = self.schedulerModel.repeatDescription;
        self.statusLabel.hidden = YES;
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"device_icon_device"];
        self.schedulerLabel.hidden = YES;
        self.cycleLabel.hidden = YES;
        self.timeLabel.hidden = YES;
        
        NSString *statusStr;
        if (self.schedulerModel.deviceOperate) {
            statusStr = @"开机";
            
            NSString *modeName = [AUXConfiguration getServerModeName:self.schedulerModel.mode];
            
            if (!AUXWhtherNullString(modeName)) {
                statusStr = [NSString stringWithFormat:@"%@，%@" , statusStr , modeName];
            }
            
            if (self.schedulerModel.temperature && (self.schedulerModel.mode != AUXServerDeviceModeWind && self.schedulerModel.mode != AUXServerDeviceModeAuto)) {
                statusStr = [NSString stringWithFormat:@"%@%ld°C" , statusStr , (NSInteger)self.schedulerModel.temperature];
            }
            
            NSString *windSpeedStr = [AUXConfiguration getServerWindSpeedName:self.schedulerModel.windSpeed];
            
            if (!AUXWhtherNullString(windSpeedStr)) {
                statusStr = [NSString stringWithFormat:@"%@，%@" , statusStr , windSpeedStr];
            }
        } else {
            statusStr = @"关机";
        }
        self.statusLabel.text = statusStr;
    }
}

@end
