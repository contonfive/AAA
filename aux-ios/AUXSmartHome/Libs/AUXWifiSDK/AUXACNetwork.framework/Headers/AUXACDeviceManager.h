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
#import "AUXACDevice.h"

@interface AUXACDeviceManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

- (void)startPolling;

- (void)stopPolling;

/**
 缓存已发现设备对象，防止同一设备对象重复

 @param device 待缓存设备
 */
- (void)addDevice:(AUXACDevice *)device;

/**
 移除已发现设备

 @param device 待移除设备
 */
- (void)removeDevice:(AUXACDevice *)device;

/**
 添加设备至订阅列表

 @param device 待添加设备
 */
- (void)subscribeDevice:(AUXACDevice *)device;

/**
 移除订阅列表中设备

 @param device 待移除设备
 */
- (void)unsubscribeDevice:(AUXACDevice *)device;

/**
 查询是否设备已被缓存

 @param mac 待查询设备mac地址
 @return 如果设备存在，返回设备，否则，返回nil
 */
- (AUXACDevice *)containDeviceWithMac:(NSString *)mac;

/**
 更新轮询设备地址，默认订阅设备后轮询地址0x01
 
 @param address 更新设备地址，支持地址位0x01～0x40，16进制表记
 @param mac 更新设备mac
 */
- (void)updatePollingAddress:(NSString *)address forMac:(NSString *)mac;

/**
 反序列化古北模组设备

 @param mac 待反序列化设备mac地址
 @param password 待反序列化设备password
 @param key 待反序列化设备key
 @param alias 待反序列化设备别名
 @param type 待反序列化设备固件版本
 @return 返回反序列化后的设备
 */
- (AUXACDevice *)createBLDeviceWithMac:(NSString *)mac password:(uint32_t)password key:(NSString *)key alias:(NSString *)alias type:(NSString *)type terminal_id:(uint8_t)terminal_id;

@end
