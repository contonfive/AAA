//
//  AUXSceneLogTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/20.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXSceneLogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneLogTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *name1Label;
@property (weak, nonatomic) IBOutlet UILabel *name2Labnel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *cellbackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic,strong)AUXSceneLogModel*model;
@property (nonatomic,assign)CGFloat cellHeight;
@property (weak, nonatomic) IBOutlet UIView *linView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel3;
//@property (nonatomic, copy) void (^refreshBlock)(CGFloat cellHeight);

@end

NS_ASSUME_NONNULL_END
