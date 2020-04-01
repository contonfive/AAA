//
//  AUXSceneAddHeaderTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/11.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneAddHeaderTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *seccondLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImageview;

@end

NS_ASSUME_NONNULL_END
