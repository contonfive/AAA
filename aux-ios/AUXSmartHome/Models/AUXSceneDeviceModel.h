//
//  AUXSceneDeviceModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/7.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXConfiguration.h"
#import <YYModel.h>
@interface AUXSceneDeviceModel : NSObject

/**
 设备动作id
 */
@property (nonatomic,copy)      NSString *actionId;
/**
 设备id
 */
@property (nonatomic,copy)      NSString *deviceId;
/**
 设备did
 */
@property (nonatomic,copy)      NSString *did;
/**
  显示状态 0：不显示 1：显示
 */
//@property (nonatomic,assign) NSInteger display;
/**
 多联机标识
 */
@property (nonatomic,assign)    NSInteger dst;
/**
 模式 0:自动模式 1:制冷模式 2:除湿模式 4:制热模式 6:送风模式
 */
@property (nonatomic,copy)    NSString *mode;
/**
 开关机 0：关机 1：开机
 */
@property (nonatomic,assign)    NSInteger onOff;
/**
 设备productKey
 */
@property (nonatomic,copy) NSString *productKey;
/**
 温度
 */
@property (nonatomic,copy)    NSString *temperature;

@property (nonatomic,copy)      NSString *deviceName;


/**
 空调图片
 */
@property (nonatomic,copy)      NSString *imageUrl;

@end
