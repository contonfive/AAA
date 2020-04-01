//
//  AUXSecondTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/24.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXFirstCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSecondTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bubblesImageview;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) AUXFirstCellModel *firstCellModel;
@property (nonatomic,assign)CGFloat cellHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeHeight;

@end

NS_ASSUME_NONNULL_END
