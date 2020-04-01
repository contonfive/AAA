//
//  AUXSleepDIYTimeViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepdIYBaseViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXSleepDIYModel.h"


/// 将数组下标转换为时间
typedef NSInteger (^AUXIndexToHourBlock) (NSInteger index, NSInteger startHour);

NS_ASSUME_NONNULL_BEGIN

@interface AUXSleepDIYTimeViewController : AUXSleepdIYBaseViewController

@property (nonatomic, copy) void (^editSuccessBlock)(AUXSleepDIYModel *sleepDIYModel);

@end

NS_ASSUME_NONNULL_END
