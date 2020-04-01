//
//  AUXAUXAfterSaleConmuteTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXTopContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXAUXAfterSaleConmuteTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic,strong) AUXTopContactModel *contactModel;

@property (nonatomic, copy) void (^contactAddressHeightBlock)(CGFloat height);

@end

NS_ASSUME_NONNULL_END
