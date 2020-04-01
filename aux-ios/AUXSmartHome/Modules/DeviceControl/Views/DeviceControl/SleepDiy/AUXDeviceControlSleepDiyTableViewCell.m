//
//  AUXDeviceControlSleepDiyTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/1.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlSleepDiyTableViewCell.h"
#import "AUXConfiguration.h"

@interface AUXDeviceControlSleepDiyTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;


@end

@implementation AUXDeviceControlSleepDiyTableViewCell

+ (CGFloat)properHeight {
    return 48.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSleepDiyModel:(AUXSleepDIYModel *)sleepDiyModel {
    _sleepDiyModel = sleepDiyModel;
    
    if (_sleepDiyModel) {
        self.nameLabel.text = _sleepDiyModel.name;
        self.statusLabel.text = [NSString stringWithFormat:@"(%@)" , [AUXConfiguration getServerModeName:_sleepDiyModel.mode]];
        
        if (_sleepDiyModel.deviceManufacturer) { //新设备
            self.weekLabel.text = [_sleepDiyModel timePeriod];
        } else {
            self.weekLabel.text = [NSString stringWithFormat:@"%@小时", @(_sleepDiyModel.definiteTime)];
        }
    }
}

@end
