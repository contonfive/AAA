//
//  AUXDeviceShareTypeTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceShareTypeTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic,assign)  AUXDeviceShareType type;

@end

NS_ASSUME_NONNULL_END
