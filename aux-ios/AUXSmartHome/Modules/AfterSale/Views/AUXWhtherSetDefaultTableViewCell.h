//
//  AUXWhtherSetDefaultTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXTopContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXWhtherSetDefaultTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIButton *whtherSetDefaultButton;

@property (nonatomic, copy) void (^setDefaultBlock)(BOOL selected);
@property (nonatomic,strong) AUXTopContactModel *model;

@end

NS_ASSUME_NONNULL_END
