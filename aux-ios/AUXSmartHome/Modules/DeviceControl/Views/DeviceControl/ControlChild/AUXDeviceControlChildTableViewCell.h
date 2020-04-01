//
//  AUXDeviceControlChildTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceFeature.h"
#import "AUXDeviceStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceControlChildTableViewCell : AUXBaseTableViewCell

/// 设备控制类型。默认为 AUXDeviceControlTypeVirtual 虚拟体验。
@property (nonatomic, assign) AUXDeviceControlType controlType;

@property (nonatomic,strong) AUXDeviceFeature *deviceFeature;
@property (nonatomic,strong) AUXDeviceStatus *deviceStatus;

@property (nonatomic, assign) BOOL offline;             // 开关机状态

/// 调节了温度
@property (nonatomic, copy) void (^didAdjustTemperatureBlock)(CGFloat temperature);

@property (nonatomic, copy) void (^showErrorMessageBlock)(NSString *errorMessage);

@property (nonatomic, copy) void (^pushToFaultVCBlock)(void);

@property (nonatomic, copy) void (^powerOnBlock)(void);

@end

NS_ASSUME_NONNULL_END
