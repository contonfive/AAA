//
//  AUXSceneViewListTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/3.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneViewListTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@end

NS_ASSUME_NONNULL_END
