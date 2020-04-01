//
//  AUXDeviceControlerSchedulerTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXSchedulerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceControlerSchedulerTableViewCell : AUXBaseTableViewCell

@property (nonatomic, assign) BOOL statusOn;

@property (nonatomic,strong) AUXSchedulerModel *schedulerModel;

@end

NS_ASSUME_NONNULL_END
