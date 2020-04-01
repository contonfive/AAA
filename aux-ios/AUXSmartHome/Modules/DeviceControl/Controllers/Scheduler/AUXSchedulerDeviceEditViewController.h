//
//  AUXSchedulerDeviceEditViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXSchedulerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXSchedulerDeviceEditViewController : AUXBaseViewController

@property (nonatomic, assign) BOOL addScheduler;         // YES=添加定时、NO=编辑定时，默认为NO。

@property (nonatomic,assign) BroadlinkTimerType hardwaretype;
@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXACDevice *device;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, copy) AUXSchedulerModel *schedulerModel;
@property (nonatomic, strong) NSArray<AUXSchedulerModel *> *existedSchedulerArray;  // 当前已有的定时列表

@property (nonatomic, copy) void (^editSuccessBlock)(AUXSchedulerModel *schedulerModel);

@end

NS_ASSUME_NONNULL_END
