//
//  AUXMyInformationTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/27.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXMyInformationTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLanel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageview;
@property (weak, nonatomic) IBOutlet UIView *underLine;
@property (weak, nonatomic) IBOutlet UIImageView *backImageview;

@end

NS_ASSUME_NONNULL_END
