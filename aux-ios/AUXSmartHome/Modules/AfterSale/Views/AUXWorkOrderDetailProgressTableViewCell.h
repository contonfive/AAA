//
//  AUXWorkOrderDetailProgressTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXProduct.h"
#import "AUXSubmitWorkOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderDetailProgressTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *serviceBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *serviceStateTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *serviceProgressImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceProgressImageViewCenterX;
@property (weak, nonatomic) IBOutlet UIView *serviceGradientView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceGradientTrailing;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stateButtons;

@property (nonatomic,strong) AUXSubmitWorkOrderModel *workOrderDetailModel;
@property (nonatomic,strong) AUXProduct *productModel;
@end

NS_ASSUME_NONNULL_END
