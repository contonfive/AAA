//
//  AUXModeAndSpeedTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXModeAndSpeedTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomSegmentationView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTriling;

@end

NS_ASSUME_NONNULL_END
