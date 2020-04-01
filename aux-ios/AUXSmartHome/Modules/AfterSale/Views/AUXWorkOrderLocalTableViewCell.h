//
//  AUXWorkOrderLocalTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXProduct.h"
#import "AUXSubmitWorkOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderLocalTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *mapBackView;

@property (nonatomic,strong) AUXSubmitWorkOrderModel *workOrderDetailModel;
@property (nonatomic,strong) AUXProduct *productModel;
@end

NS_ASSUME_NONNULL_END
