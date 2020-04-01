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

/**
 用于自动登录成功后，调用SDK方法发现设备，保存设备列表。
 */
@interface AUXDeviceDiscoverManager : NSObject <AUXACNetworkProtocol, AUXACDeviceProtocol>

@property (nonatomic, assign) BOOL discoveringDevices;

+ (instancetype)defaultManager;

/// 调用SDK方法开始搜索设备
- (void)startDiscoverDevice;

/// 并没有真的停止搜索，调用该方法只是停止内部的 timer 及移除代理
- (void)stopDiscoverDevice;

- (void)removeDevicesDelegate;

@end
