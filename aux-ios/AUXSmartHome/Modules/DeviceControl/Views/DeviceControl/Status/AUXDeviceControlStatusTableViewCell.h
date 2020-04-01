//
//  AUXDeviceControlStatusTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceFunctionItem.h"
#import "AUXDeviceStatus.h"
#import "AUXDeviceFeature.h"

NS_ASSUME_NONNULL_BEGIN

/**
 在设备控制界面中显示的设备状态。
 需要显示的设备状态：
 1. 模式，
 2. 风速，
 3. 定时，
 4. 健康，
 5. ECO，
 6. 电加热，
 7. 睡眠，
 8. 上下摆风，
 9. 左右摆风，
 10. 舒适风
 */
@interface AUXDeviceControlStatusTableViewCell : AUXBaseTableViewCell

/// 设备控制类型。默认为 AUXDeviceControlTypeVirtual 虚拟体验。
@property (nonatomic, assign) AUXDeviceControlType controlType;
@property (nonatomic, strong) AUXDeviceFeature *deviceFeature;
@property (nonatomic, copy) AUXDeviceStatus *deviceStatus;

@end

NS_ASSUME_NONNULL_END
