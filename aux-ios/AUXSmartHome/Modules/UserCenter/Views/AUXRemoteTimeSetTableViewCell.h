//
//  AUXRemoteTimeSetTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/17.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXPushLimitModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXRemoteTimeSetTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *contentButton;

@property (nonatomic,strong) AUXPushLimitModel *limitModel;

@property (nonatomic, copy) void (^contentBlock)(void);
@end

NS_ASSUME_NONNULL_END
