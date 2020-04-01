//
//  AUXRemoteTimeSwitchTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/17.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXRemoteTimeSwitchTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@property (nonatomic, copy) void (^switchBlock)(void);

@end

NS_ASSUME_NONNULL_END
