//
//  AUXWorkOrderDeviceTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXProduct.h"
#import "AUXSubmitWorkOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderDeviceTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyDateLabel;

@property (nonatomic,strong) AUXSubmitWorkOrderModel *workOrderDetailModel;
@end

NS_ASSUME_NONNULL_END
