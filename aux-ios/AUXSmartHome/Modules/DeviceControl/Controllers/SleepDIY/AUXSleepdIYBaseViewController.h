//
//  AUXSleepdIYBaseViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXSleepDIYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSleepdIYBaseViewController : AUXBaseViewController

@property (nonatomic, assign) BOOL addSleepDIY;         // YES=添加睡眠DIY、NO=编辑睡眠DIY
@property (nonatomic, assign) AUXServerDeviceMode mode; // 模式

/// 设备控制类型。默认为 AUXDeviceControlTypeVirtual 虚拟体验。
@property (nonatomic, assign) AUXDeviceControlType controlType;
@property (nonatomic, strong) AUXDeviceFeature *deviceFeature;
@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, assign) BOOL oldDevice;           // YES=旧设备，NO=新设备

@property (nonatomic, copy) AUXSleepDIYModel *sleepDIYModel;

@property (nonatomic, strong) NSArray<AUXSleepDIYModel *> *existedModelList;

@end

NS_ASSUME_NONNULL_END
