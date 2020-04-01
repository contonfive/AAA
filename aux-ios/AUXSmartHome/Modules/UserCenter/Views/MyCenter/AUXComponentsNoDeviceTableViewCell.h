//
//  AUXComponentsNoDeviceTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/13.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"

@interface AUXComponentsNoDeviceTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addDeviceButton;

@property (nonatomic, copy) void (^addDeviceBlock)(void);

@end
