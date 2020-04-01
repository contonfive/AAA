//
//  AUXWorkOrderInfoTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXSubmitWorkOrderModel.h"
#import "AUXWorkOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderInfoTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *logisticsLabel;
@property (weak, nonatomic) IBOutlet UILabel *logisticsStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceNumberTitleLabelCenterY;

@property (nonatomic,strong) AUXSubmitWorkOrderModel *workOrderDetailModel;

@end

NS_ASSUME_NONNULL_END
