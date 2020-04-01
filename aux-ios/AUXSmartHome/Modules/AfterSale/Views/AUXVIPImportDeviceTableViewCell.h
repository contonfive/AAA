//
//  AUXVIPImportDeviceTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/12.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXVIPImportDeviceTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceIcon;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@end

NS_ASSUME_NONNULL_END
