//
//  AUXMySceneTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/3.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXSceneDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXMySceneTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageview;
@property (weak, nonatomic) IBOutlet UIView *handMovementView;
@property (weak, nonatomic) IBOutlet UIView *automaticView;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIButton *handButtonAction;

@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sceneDescribeLabel;

@property (nonatomic,strong) AUXSceneDetailModel *sceneDetailModel;
@property (weak, nonatomic) IBOutlet UIImageView *switchImageView;

@property (nonatomic, copy) void (^manualPerfomBlock)(AUXSceneDetailModel *detailModel);
@property (nonatomic, copy) void (^autoPerformBlock)(AUXSceneDetailModel *detailModel , BOOL status);
@end

NS_ASSUME_NONNULL_END
