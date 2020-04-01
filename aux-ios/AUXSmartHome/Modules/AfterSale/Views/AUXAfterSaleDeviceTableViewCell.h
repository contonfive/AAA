//
//  AUXAfterSaleDeviceTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXAfterSaleDeviceTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;

@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;

@property (nonatomic,strong) AUXDeviceInfo *deviceInfo;

@end

NS_ASSUME_NONNULL_END
