//
//  AUXThirdTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/24.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXFirstCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXThirdTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) AUXFirstCellModel *firstCellModel;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *aboveView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *chrysanthemumView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeight;

@end

NS_ASSUME_NONNULL_END
