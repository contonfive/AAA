//
//  AUXCenterControlTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXCenterControlTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *IconImageview;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineStateLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (nonatomic,strong) AUXDeviceInfo*model;
@property (weak, nonatomic) IBOutlet UIImageView *outOnlineImagView;
@property (weak, nonatomic) IBOutlet UIView *underLineView;

@end

NS_ASSUME_NONNULL_END
