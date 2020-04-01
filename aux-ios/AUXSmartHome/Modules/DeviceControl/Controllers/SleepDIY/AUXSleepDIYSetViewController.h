//
//  AUXSleepDIYSetViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepdIYBaseViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXSleepDIYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSleepDIYSetViewController : AUXSleepdIYBaseViewController

@property (nonatomic, copy) void (^updateSleepDIYNameBlock)(NSString *name);

@end

NS_ASSUME_NONNULL_END