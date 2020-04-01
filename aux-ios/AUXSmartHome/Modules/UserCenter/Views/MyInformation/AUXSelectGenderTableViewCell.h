//
//  AUXSelectGenderTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSelectGenderTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@end

NS_ASSUME_NONNULL_END
