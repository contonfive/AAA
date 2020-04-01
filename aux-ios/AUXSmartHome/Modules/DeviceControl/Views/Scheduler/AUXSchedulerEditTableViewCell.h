//
//  AUXSchedulerEditTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseTableViewCell.h"
#import "AUXSchedulerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXSchedulerEditTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *schedulerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;


@property (nonatomic,strong) AUXSchedulerModel *schedulerModel;
@property (nonatomic,assign) AUXDeviceControlSchedulerType type;

@end

NS_ASSUME_NONNULL_END
