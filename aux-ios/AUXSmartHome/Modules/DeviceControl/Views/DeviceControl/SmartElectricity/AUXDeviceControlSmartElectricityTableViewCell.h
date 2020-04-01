//
//  AUXDeviceControlSmartElectricityTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseTableViewCell.h"
#import "AUXSmartPowerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceControlSmartElectricityTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *modelLabelBottom;

@property (weak, nonatomic) IBOutlet UILabel *peakTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *degreeLabel;

@property (nonatomic, strong) AUXSmartPowerModel *smartPowerModel;

@end

NS_ASSUME_NONNULL_END
