//
//  AUXWorkOrderContactTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXSubmitWorkOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderContactTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactAddressLabel;

@property (nonatomic,strong) AUXSubmitWorkOrderModel *workOrderDetailModel;
@end

NS_ASSUME_NONNULL_END
