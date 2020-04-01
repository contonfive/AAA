//
//  AUXSetTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/24.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSetTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *uiderLineView;
@property (weak, nonatomic) IBOutlet UIImageView *backImageview;

@end

NS_ASSUME_NONNULL_END
