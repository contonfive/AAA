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
#import "BLNetwork.h"
#import "AUXACDevice.h"
#import "AUXACDeviceManager.h"
#import "AUXACInfo.h"
#import "AUXACNetworkError.h"
#import "AUXWeakedHashTable.h"

#import "JSONKit.h"
#import "UIDevice+IPAddr.h"
#import "route.h"

typedef NS_ENUM(char, AUXACNetworkDeviceType) {
    AUXACNetworkDeviceTypeCeiling = 0x01,
    AUXACNetworkDeviceTypeDucted = 0x02,
    AUXACNetworkDeviceTypeCrane = 0x03,
    AUXACNetworkDeviceTypeHunging = 0x04,
};

typedef void (^AUXACUARTHandler)(BOOL success, NSDictionary *response, NSError *error);

@protocol AUXACNetworkProtocol <NSObject>
@optional

/**
 发送用户短信验证码回调
 
 @param result 发送失败原因
 @param success 是否发送成功
 @param token token
 */
- (void)auxACNetworkDidSendSMSCodeToPhone:(NSError *)result success:(BOOL)success token:(NSString *)token;

/**
 用户登录回调
 
 @param result 登录失败原因
 @param success 是否登录成功
 @param uid uid
 @param token token
 */
- (void)auxACNetworkDidUserLogin:(NSError *)result success:(BOOL)success uid:(NSString *)uid token:(NSString *)token;

/**
 设备配置入网回调

 @param result 设备配置入网失败原因
 @param success 设备配置入网是否成功
 @param mac 配置入网设备mac
 @param device 配置入网设备
 @param type 配置入网设备类型
 @see AUXACNetworkDeviceWifiType
 */
- (void)auxACNetworkDidSetDeviceOnboarding:(NSError *)result success:(BOOL)success mac:(NSString *)mac device:(AUXACDevice *)device withType:(AUXACNetworkDeviceWifiType)type;

/**
 获取同Wi-Fi下配置入网设备回调

 @param deviceList 发现设备列表，可能存在其他可发现设备未在本次调用中返回，需多次调用累加设备列表
 @param success 发现设备是否成功
 @param error 发现设备失败原因
 */
- (void)auxACNetworkDidDiscoveredDeviceList:(NSArray *)deviceList success:(BOOL)success withError:(NSError *)error;

/**
 绑定设备回调

 @param result 绑定设备失败原因
 @param success 绑定设备是否成功
 @param did 成功绑定设备的id
 */
- (void)auxACNetworkDidBindDevice:(NSError *)result success:(BOOL)success did:(NSString *)did;

@end

@interface AUXACNetwork : NSObject

@property (retain, nonatomic) AUXWeakedHashTable *delegates;
@property (assign, nonatomic, getter=isSetDeviceOnboarding) BOOL setDeviceOnboarding;
@property (retain, nonatomic, readonly) dispatch_queue_t queue;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

/**
 发送验证短信至手机

 @param phone 接收验证短信手机号码
 @see 回调签名：[AUXACNetworkProtocol auxACNetworkDidSendSMSCodeToPhone:success:token:]
 */
- (void)requestSendSMSCodeToPhone:(NSString *)phone;

/**
 用户登录

 @param userId 用户ID
 @param password 用户密码
 @see 回调签名：[AUXACNetworkProtocol auxACNetworkDidUserLogin:success:uid:token]
 */
- (void)loginWithUserId:(NSString *)userId password:(NSString *)password;

/*
 配置设备入网
 
 @param ssid 路由器SSID名
 @param password 路由器密码
 @param timeout 配置的超时时间，SDK 默认执行的最小超时时间为30秒
 @param wifiType 待配置设备模组软件类型，预定义支持机智云或古北模组
 @param hardwareType 待配置设备模组硬件类型，预定义支持古北或庆科模组
 @param softAPSSIDPrefix 设备ssid，airkiss配网时传入nil，ap配网时传入ssid
 @see 回调签名：[AUXACNetworkProtocol auxACNetworkDidSetDeviceOnboarding:success:device:withType:]
 @see AUXACNetworkDeviceWifiType
 @see AUXACNetworkWifiHardwareType
 */
- (void)setDeviceOnboarding:(NSString *)ssid password:(NSString *)password timeout:(int)timeout wifiType:(AUXACNetworkDeviceWifiType)wifiType hardwareType:(AUXACNetworkWifiHardwareType)hardwareType softAPSSIDPrefix:(NSString *)softAPSSIDPrefix;

/**
 获取同Wi-Fi下配置入网设备
 
 @param uid 用户uid
 @param token 用户token
 @param type 获取设备模组类型，预定义支持机智云或古北模组，或同时获取两者
 @see 回调签名：[auxACNetworkDidDiscoveredDeviceList:success:withError:]
 @see AUXACNetworkDeviceWifiType
 */
- (void)getBoundDevicesWithUid:(NSString *)uid token:(NSString *)token type:(AUXACNetworkDeviceWifiType)type;

/**
 绑定指定设备
 
 @param uid 绑定至用户id
 @param token 绑定至用户token
 @param device 待绑定设备
 @see 回调签名：[AUXACNetworkProtocol auxACNetworkDidUserLogin:success:]
 */
- (void)bindDeviceWithUid:(NSString *)uid token:(NSString *)token device:(AUXACDevice *)device;

/**
 订阅指定设备

 @param device 待订阅设备
 @param type 待订阅设备模组类型，预定义支持机智云或古北模组
 @see 回调签名：[AUXACNetworkProtocol auxACNetworkDidSubscribeDevice:success:withError:]
 @see AUXACNetworkDeviceWifiType
 */
- (void)subscribeDevice:(AUXACDevice *)device withType:(AUXACNetworkDeviceWifiType)type;

/**
 取消订阅指定设备
 
 @param device 待订阅设备
 @param type 待订阅设备模组类型，预定义支持机智云或古北模组
 @see 回调签名：[AUXACNetworkProtocol auxACNetworkDidUnsubscribeDevice:success:withError:]
 @see AUXACNetworkDeviceWifiType
 */
- (void)unsubscribeDevice:(AUXACDevice *)device withType:(AUXACNetworkDeviceWifiType)type;

/**
 查询指定设备，查询多联机子设备别名时，多联机子设备仅支持英文别名

 @param device 待查询设备
 @param queryType 查询设备内容，预定义支持查询设备控制状态(支持机智云或古北模组)，运行状态(支持机智云或古北模组)，睡眠曲线(仅支持古北模组)
 @param deviceType 待查询设备模组类型，预定义支持机智云或古北模组
 @param address 待查询设备总线地址，非多联机仅支持查询地址01的设备，多联机支持查询地址位0x01～0x40的设备，16进制表记；查询子设备数量与地址时为任意值或nil
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidQueryDevice:atAddress:success:withError:type:]
 @see AUXACNetworkQueryType
 @see AUXACNetworkDeviceWifiType
 */
- (void)queryDevice:(AUXACDevice *)device withQueryType:(AUXACNetworkQueryType)queryType deviceType:(AUXACNetworkDeviceWifiType)deviceType atAddress:(NSString *)address;

/**
 查询指定设备Wi-Fi状态
 
 @param device 待查询设备
 @param deviceType 待查询设备模组类型，预定义支持机智云或古北模组
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidQueryWifiOfDevice:success:withError:]
 @see AUXACNetworkDeviceWifiType
 */
- (void)queryWifiOfDevice:(AUXACDevice *)device deviceType:(AUXACNetworkDeviceWifiType)deviceType;

/**
 发送控制命令至指定设备

 @param device 待控制设备
 @param control 控制参数
 @param address 待控制设备总线地址，非多联机仅支持控制地址01的设备，多联机支持控制地址位0x01～0x40的设备，16进制表记
 @param type 待控制设备模组类型，预定义支持机智云或古北模组
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidSendCommandForDevice:atAddress:success:withError:]
 @see 控制参数：AUXACDevice.controlDic[address]
 @see AUXACNetworkDeviceWifiType
 */
- (void)sendCommand2Device:(AUXACDevice *)device controlInfo:(AUXACControl *)control atAddress:(NSString *)address withType:(AUXACNetworkDeviceWifiType)type;

/**
 设置子设备名称

 @param alias 子设备名称
 @param device 待设置子设备名称设备
 @param type 设备类型
 @param address 子设备地址，支持地址位0x01～0x40的设备，16进制表记
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidSetSubDeviceAliasForDevice:atAddress:success:withError:]
 @see AUXACNetworkDeviceWifiType
 */
- (void)setSubDeviceAlias:(NSString *)alias forDevice:(AUXACDevice *)device withType:(AUXACNetworkDeviceWifiType)type atAddress:(NSString *)address;

/**
 查询多子设备名称
 
 @param device 待设置子设备名称设备
 @param type 设备类型
 @param addresses 子设备地址，支持地址位0x01～0x40的设备，16进制表记
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidQuerySubDeviceAliasForDevice:atAddresses:success:withError:]
 @see AUXACNetworkDeviceWifiType
 */
- (void)querySubDeviceAliasForDevice:(AUXACDevice *)device withType:(AUXACNetworkDeviceWifiType)type atAddresses:(NSArray *)addresses;

/**
 获取设备定时列表，由于机智云模组设备采用云定时，本方法仅支持古北模组设备

 @param device 待获取定时列表设备
 @param hardwareType 设备类型
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidGetTimerListOfDevice:timerList:cycleTimerList:success:withError:]
 */
- (void)getTimerListOfDevice:(AUXACDevice *)device hardwareType:(BroadlinkTimerType)hardwareType;

/**
 设置设备周定时，由于机智云模组设备由云端定时下发定时任务，本方法仅支持古北模组设备
 
 @param device 待定时设备
 @param timer 定时任务
 @param control 当前状态
 @param cmdType 定时命令类型
 @param hardwareType 设备类型
 @param windGearType 风速档位类型
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidSetCycleTimerForDevice:success:withError:]
 @see Broadlink2UartCmd
 */
- (void)setCycleTimerForDevice:(AUXACDevice *)device timer:(AUXACBroadlinkCycleTimer *)timer control:(AUXACControl *)control cmdType:(Broadlink2UartCmd)cmdType hardwareType:(BroadlinkTimerType)hardwareType windGearType:(WindGearType)windGearType;

/**
 设置设备睡眠DIY曲线，由于机智云模组设备由云端定时下发睡眠曲线，本方法仅支持古北模组设备
 
 @param device 待设置睡眠DIY曲线设备
 @param sleepDIYPoints 睡眠DIY曲线点
 @see 回调签名：[AUXACDeviceProtocol auxACNetworkDidSetSleepDIYPointsForDevice:success:withError:]
 */
- (void)setSleepDIYPointsForDevice:(AUXACDevice *)device sleepDIYPoints:(NSArray *)sleepDIYPoints;

/**
 查询设备用电设置

 @param device 待查询设备
 */
- (void)getPowerInfoForDevice:(AUXACDevice *)device;

/**
 设置智能用电

 @param device 待设置智能用电设备
 @param startTime 智能用电开始时间 格式 7:00
 @param endTime 智能用电结束时间 格式 14:00
 @param quantity 智能用电量
 @param mode 智能用电模式
 @param enabled 智能用电开启或关闭
 @see SmartPowerMode
 */
- (void)setSmartPowerForDevice:(AUXACDevice *)device startTime:(NSString *)startTime endTime:(NSString *)endTime quantity:(int)quantity mode:(SmartPowerMode)mode enabled:(BOOL)enabled;

/**
 设置峰谷节电

 @param device 待设置峰谷节电设备
 @param peakStartTime 峰电开始时间 格式 8:00
 @param peakEndTime 峰电结束时间 格式 14:00
 @param valleyStartTime 谷电开始时间 格式 19:00
 @param valleyEndTime 谷电结束时间 格式 22:00
 @param enabled 峰谷节电开启或关闭
 */
- (void)setPeakValleyPowerForDevice:(AUXACDevice *)device peakStartTime:(NSString *)peakStartTime peakEndTime:(NSString *)peakEndTime valleyStartTime:(NSString *)valleyStartTime valleyEndTime:(NSString *)valleyEndTime enabled:(BOOL)enabled;

- (void)getRunTimeForDevice:(AUXACDevice *)device;

- (void)clearRunTimeForDevice:(AUXACDevice *)device;

- (void)getFirmwareVersionForDevice:(AUXACDevice *)device;

- (void)updateFirmwareForDevice:(AUXACDevice *)device;

@end
