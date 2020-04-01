//
//  AUXAirConditioningModeCollectionViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/12.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXCollectCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXAirConditioningModeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *modeTitleLabel;
@property (nonatomic,strong)AUXCollectCellModel *model;

@property (nonatomic,assign)BOOL select;

@end

NS_ASSUME_NONNULL_END
