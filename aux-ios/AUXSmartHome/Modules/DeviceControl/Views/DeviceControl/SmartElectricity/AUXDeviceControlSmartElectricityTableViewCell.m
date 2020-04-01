//
//  AUXDeviceControlSmartElectricityTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlSmartElectricityTableViewCell.h"
#import "AUXConfiguration.h"

@implementation AUXDeviceControlSmartElectricityTableViewCell

+ (CGFloat)properHeight {
    return 60.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSmartPowerModel:(AUXSmartPowerModel *)smartPowerModel {
    _smartPowerModel = smartPowerModel;
    
    if (_smartPowerModel) {
        self.modeLabel.text = [AUXConfiguration getSmartPowerModeNameWithMode:_smartPowerModel.mode];
        self.peakTimeLabel.text = [_smartPowerModel timePeriod];
        self.degreeLabel.text = [NSString stringWithFormat:@"%@度", @(self.smartPowerModel.totalElec)];
    }
}

@end
