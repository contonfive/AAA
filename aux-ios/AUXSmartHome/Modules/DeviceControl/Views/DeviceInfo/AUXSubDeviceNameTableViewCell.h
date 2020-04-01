//
//  AUXSubDeviceNameTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSubDeviceNameTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *editNameBtn;

@property (nonatomic, copy) void (^editNameBlock)(void);

@end

NS_ASSUME_NONNULL_END
