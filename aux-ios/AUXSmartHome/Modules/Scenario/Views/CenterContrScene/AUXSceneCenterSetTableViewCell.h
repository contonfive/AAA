//
//  AUXSceneCenterSetTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneCenterSetTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel1;
@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel2;
@property (weak, nonatomic) IBOutlet UIView *underLineView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageview;

@end

NS_ASSUME_NONNULL_END
