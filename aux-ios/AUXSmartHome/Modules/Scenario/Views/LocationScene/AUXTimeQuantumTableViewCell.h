//
//  AUXTimeQuantumTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/11.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXTimeQuantumTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeBackView;
@property (weak, nonatomic) IBOutlet UILabel *shiduanLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

NS_ASSUME_NONNULL_END
