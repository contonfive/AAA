//
//  AUXCompoentsTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/7.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXCompoentsTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageview;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (nonatomic,strong) AUXDeviceInfo *deviceInfo;
//switchImage被点击
@property (nonatomic,copy) void (^tapBlcok)(AUXDeviceInfo *deviceInfo);
@property (weak, nonatomic) IBOutlet UIImageView *offLineImageView;
@property (weak, nonatomic) IBOutlet UILabel *offLineLabel;
@end

NS_ASSUME_NONNULL_END
