//
//  AUXDeviceControlerSchedulerTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceControlerSchedulerTableViewCell.h"
#import "AUXConfiguration.h"

@interface AUXDeviceControlerSchedulerTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;

@end

@implementation AUXDeviceControlerSchedulerTableViewCell

+ (CGFloat)properHeight {
    return 44.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSchedulerModel:(AUXSchedulerModel *)schedulerModel {
    _schedulerModel = schedulerModel;

    if (_schedulerModel) {
        self.timeLabel.text = _schedulerModel.timeString;
        self.weekLabel.text = _schedulerModel.repeatDescription;
        
        NSString *statusString = schedulerModel.deviceOperate == 1 ? @"开机" : @"关机";
        
        if ([statusString isEqualToString:@"关机"]) {
            statusString = [NSString stringWithFormat:@"(%@)" , statusString];
        } else {
            statusString = [NSString stringWithFormat:@"(%@、%@)" , statusString , [AUXConfiguration getServerModeName:_schedulerModel.mode]];
        }
        self.statusLabel.text = statusString;
    }
}

@end
