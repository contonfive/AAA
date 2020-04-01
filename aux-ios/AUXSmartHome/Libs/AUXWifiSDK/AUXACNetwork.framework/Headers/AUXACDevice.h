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
#import <GizWifiSDK/GizWifiSDK.h>
#import "AUXACInfo.h"
#import "AUXWeakedHashTable.h"

typedef NS_ENUM(char, AUXACNetworkDeviceWifiState) {
    AUXACNetworkDeviceWifiStateNA,
    AUXACNetworkDeviceWifiStateOffline,
    AUXACNetworkDeviceWifiStateOnline,
};

typedef NS_ENUM(char, AUXACNetworkWifiHardwareType) {
    AUXACNetworkWifiHardwareTypeAUX = 0x00,
    AUXACNetworkWifiHardwareTypeBL = 0x01,
    AUXACNetworkWifiHardwareTypeMX = 0x02,
};

typedef NS_ENUM(char, AUXACNetworkDeviceWifiType) {
    AUXACNetworkDeviceWifiTypeBL = 0x01,
    AUXACNetworkDeviceWifiTypeGiz = 0x02,
    AUXACNetworkDeviceWifiTypeAll = 0x03,
};

typedef NS_ENUM(char, AUXACNetworkDeviceWindType) {
    AUXACNetworkDeviceTypeWindType1 = 0x01,
    AUXACNetworkDeviceTypeWindType2 = 0x02,
};

@interface BLWifiDevice : NSObject

@property (copy, nonatomic) NSString *mac;
@property (copy, nonatomic) NSString *alias;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *key;
@property (assign, nonatomic) int lock;
@property (assign, nonatomic) uint32_t password;
@property (assign, nonatomic) int terminal_id;
@property (assign, nonatomic) int sub_device;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (copy, nonatomic) NSString *dataOne;
@property (copy, nonatomic) NSString *dataTwo;
@property (copy, nonatomic) NSString *dataThree;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *cityCode;
@property (retain, nonatomic) NSArray *sleepDIYPoints;

@end

@interface AUXACDevice : NSObject

// GIZ
@property (retain, nonatomic, setter=setGizDevice:) GizWifiDevice *gizDevice;
@property (copy, nonatomic) NSString *passcode;

// BL
@property (retain, nonatomic, setter=setBLDevice:) BLWifiDevice *bLDevice;

@property (assign, nonatomic, readonly) AUXACNetworkDeviceWifiType deviceType;
@property (assign, nonatomic, readonly, getter=getWifiState)AUXACNetworkDeviceWifiState wifiState;
@property (assign, nonatomic, readonly, getter=isLan) BOOL lan;
@property (copy, nonatomic) NSString *bLWifiState;
@property (assign, nonatomic) BOOL supportSmartPower;

@property (retain, nonatomic, readonly) dispatch_queue_t queue;
@property (assign, nonatomic) BOOL needQuerySubDevice;
@property (assign, nonatomic) BOOL needQuerySubDeviceAliases;
@property (assign, nonatomic) NSTimeInterval subscribedTimeInterval;

// ************************ 🚧请勿写入 ************************
@property (retain, nonatomic) NSMutableDictionary *aliasDic;
@property (retain, nonatomic) NSMutableDictionary *controlDic;
@property (retain, nonatomic) NSMutableDictionary *statusDic;
// ***********************************************************

@property (retain, nonatomic) AUXWeakedHashTable *delegates;

- (void)write:(NSData *)data withSN:(int)sn;

- (void)setGizDevice:(GizWifiDevice *)gizDevice;

- (void)setBLDevice:(BLWifiDevice *)bLDevice;

/**
 获取设备mac地址

 @return 设备mac地址
 */
- (NSString *)getMac;

/**
 获取设备Wi-Fi状态

 @return 设备Wi-Fi状态
 @see AUXACNetworkDeviceWifiState
 */
- (AUXACNetworkDeviceWifiState)getWifiState;

/**
 查询设备是否在局域网下

 @return 设备是否在局域网下
 */
- (BOOL)isLan;

/**
 更新子设备列表
 */
- (void)setNeedUpdateSubDevice;

/**
 更新子设备名称
 */
- (void)setNeedUpdateSubDeviceAliases;

@end

@protocol AUXACDeviceProtocol <NSObject>
@optional

/**
 订阅指定设备回调
 
 @param device 指定设备
 @param success 订阅指定设备是否成功
 @param error 订阅指定设备失败原因
 */
- (void)auxACNetworkDidSubscribeDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 取消订阅指定设备回调
 
 @param device 指定设备
 @param success 取消订阅指定设备是否成功
 @param error 取消订阅指定设备失败原因
 */
- (void)auxACNetworkDidUnsubscribeDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 获取指定设备Wi-Fi状态回调
 
 @param device 指定设备
 @param success 获取指定设备Wi-Fi状态是否成功
 @param error 获取指定设备Wi-Fi状态失败原因
 */
- (void)auxACNetworkDidQueryWifiOfDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 查询指定设备回调
 
 @param device 指定设备
 @param address 指定地址
 @param success 查询是否成功
 @param error 查询失败原因
 @param type 查询类型
 @see AUXACNetworkQueryType
 */
- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type;

- (void)auxACNetworkDidQuerySubDeviceAliasForDevice:(AUXACDevice *)device atAddresses:(NSArray *)addresses success:(BOOL)success withError:(NSError *)error;

/**
 发送控制命令至指定设备回调
 
 @param device 指定设备
 @param address 指定地址
 @param success 控制是否成功
 @param error 控制失败原因
 */
- (void)auxACNetworkDidSendCommandForDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error;

/**
 修改指定设备的子设备别名回调

 @param device 指定设备
 @param address 指定地址
 @param success 控制是否成功
 @param error 控制失败原因
 */
- (void)auxACNetworkDidSetSubDeviceAliasForDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error;

/**
 查询设备定时回调
 
 @param device 指定设备
 @param timerList 定时列表，定时设置暂不可用，默认返回nil
 @param cycleTimerList 周定时列表
 @param success 查询是否成功
 @param error 查询失败原因
 */
- (void)auxACNetworkDidGetTimerListOfDevice:(AUXACDevice *)device timerList:(NSArray *)timerList cycleTimerList:(NSArray *)cycleTimerList success:(BOOL)success withError:(NSError *)error;

/**
 设置设备定时
 
 @param device 指定设备
 @param success 定时设置是否成功
 @param error 定时设置失败原因
 */
- (void)auxACNetworkDidSetTimerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 设置设备周定时
 
 @param device 指定设备
 @param success 定时设置是否成功
 @param error 定时设置失败原因
 */
- (void)auxACNetworkDidSetCycleTimerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 设置设备睡眠DIY曲线回调
 
 @param device 指定设备
 @param success 定时设置是否成功
 @param error 定时设置失败原因
 */
- (void)auxACNetworkDidSetSleepDIYPointsForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 设置用电限制回调
 
 @param device 指定设备
 @param success 用电限制设置是否成功
 @param error 用电限制设置失败原因
 */
- (void)auxACNetworkDidSetPowerLimitForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 设置智能用电回调
 
 @param device 指定设备
 @param success 智能用电设置是否成功
 @param error 智能用电设置失败原因
 */
- (void)auxACNetworkDidSetSmartPowerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 设置峰谷用电回调
 
 @param device 指定设备
 @param success 峰谷用电设置是否成功
 @param error 峰谷用电设置失败原因
 */
- (void)auxACNetworkDidSetPeakValleyPowerForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

/**
 查询用电设置回调

 @param device 指定设备
 @param peakValleyPower 峰谷用电设置信息
 @param smartPower 智能用电设置信息
 @param success 智能用电查询是否成功
 @param error 智能用电查询失败原因
 */
- (void)auxACNetworkDidGetPowerInfoForDevice:(AUXACDevice *)device peakValleyPower:(AUXACPeakValleyPower *)peakValleyPower smartPower:(AUXACSmartPower *)smartPower success:(BOOL)success withError:(NSError *)error;

- (void)auxACNetworkDidGetRunTimeForDevice:(AUXACDevice *)device runTime:(int)runTime success:(BOOL)success withError:(NSError *)error;

- (void)auxACNetworkDidClearRunTimeForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

- (void)auxACNetworkDidGetFirmwareVersionForDevice:(AUXACDevice *)device firmwareVersion:(int)firmwareVersion success:(BOOL)success withError:(NSError *)error;

- (void)auxACNetworkDidUpdateFirmwareForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error;

@end
