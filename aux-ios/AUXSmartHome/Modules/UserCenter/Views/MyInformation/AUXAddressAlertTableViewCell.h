//
//  AUXAddressAlertTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXAddressAlertTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImage;

@end

NS_ASSUME_NONNULL_END
