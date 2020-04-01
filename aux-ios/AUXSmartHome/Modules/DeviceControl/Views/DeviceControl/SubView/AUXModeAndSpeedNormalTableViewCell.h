//
//  AUXModeAndSpeedNormalTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXModeAndSpeedNormalTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomSegmentationView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

NS_ASSUME_NONNULL_END
