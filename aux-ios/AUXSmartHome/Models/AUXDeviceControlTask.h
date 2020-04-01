/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import <Foundation/Foundation.h>

#import "AUXDeviceInfo.h"

/**
 设备控制任务 (用于集中控制或语音控制)
 */
@interface AUXDeviceControlTask : NSObject

@property (nonatomic, strong) NSString *address;        // 设备地址，单元机为01，多联机为子设备地址
@property (nonatomic, strong) AUXACControl *control;    // 设备控制状态

/**
 创建控制任务

 @param address 地址
 @param control 设备控制状态
 @return 控制任务
 */
+ (instancetype)controlTaskWithAddress:(NSString *)address control:(AUXACControl *)control;

@end

/**
 设备控制队列
 */
@interface AUXDeviceControlQueue : NSObject

/**
 创建设备控制队列

 @param deviceInfo 设备信息
 @param device 设备对象
 @return 控制队列
 */
+ (instancetype)controlQueueWithDeviceInfo:(AUXDeviceInfo *)deviceInfo device:(AUXACDevice *)device;

/**
 增加控制任务

 @param task 控制任务
 */
- (void)appendTask:(AUXDeviceControlTask *)task;

/**
 开始控制设备
 */
- (void)start;

/**
 停止控制设备
 */
- (void)stop;

/**
 暂停
 */
- (void)pause;

/**
 恢复
 */
- (void)resume;

@end
