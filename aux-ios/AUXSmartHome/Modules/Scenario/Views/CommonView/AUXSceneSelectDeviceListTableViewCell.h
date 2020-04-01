//
//  AUXSceneSelectDeviceListTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneSelectDeviceListTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *IconImageview;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineStateImageview;
@property (weak, nonatomic) IBOutlet UIView *underLinView;

@end

NS_ASSUME_NONNULL_END
