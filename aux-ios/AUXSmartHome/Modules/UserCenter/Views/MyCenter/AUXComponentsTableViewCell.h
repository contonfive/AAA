//
//  AUXComponentsTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/5/31.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceInfo.h"

@interface AUXComponentsTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (nonatomic,strong) AUXDeviceInfo *deviceInfo;

//switchImage被点击
@property (nonatomic,copy) void (^tapBlcok)(AUXDeviceInfo *deviceInfo);

@end
