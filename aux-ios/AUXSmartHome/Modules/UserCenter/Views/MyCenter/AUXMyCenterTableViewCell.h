//
//  AUXMyCenterTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/23.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXMyCenterTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageview;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *dianLabel;

@end

NS_ASSUME_NONNULL_END
