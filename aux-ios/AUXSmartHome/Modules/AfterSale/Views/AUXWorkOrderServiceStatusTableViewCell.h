//
//  AUXWorkOrderServiceStatusTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/10.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXProduct.h"
#import "AUXWorkOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderServiceStatusTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusContentlabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (nonatomic,strong) AUXWorkOrderModel *workOrderModel;
@property (nonatomic,strong) AUXProduct *productModel;


@end

NS_ASSUME_NONNULL_END
