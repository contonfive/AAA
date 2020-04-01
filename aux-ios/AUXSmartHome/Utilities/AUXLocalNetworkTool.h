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
#import <AFNetworking/AFNetworking.h>

/**
 手机网络监测工具
 */
@interface AUXLocalNetworkTool : NSObject

@property (nonatomic, strong) AFNetworkReachabilityManager *networkReachability;
@property (nonatomic, copy) void (^networkStatusChangeBlock)(AFNetworkReachabilityStatus status);
@property (nonatomic,assign) long long int lastBytes;
+ (instancetype)defaultTool;

/**
 获取当前网速(每调用一次获取一次，所以需要开定时器一直获取)
 return 实时网速
 */
- (NSString *)getCurrentNetWorkSpeed;

/**
 开始监测网络状态
 */
- (void)startMonitoringNetwork;

/**
 网络是否可达

 @return 网络是否可达
 */
+ (BOOL)isReachable;

/**
 当前是否连接WiFi

 @return 当前是否连接WiFi
 */
+ (BOOL)isReachableViaWifi;

/**
 获取当前手机连接的WiFi ssid

 @return 当前手机连接的WiFi ssid
 */
+ (NSString *)getCurrentWiFiSSID;


@end
