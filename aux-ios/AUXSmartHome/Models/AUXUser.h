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

#import <YYModel/YYModel.h>

#import "AUXDeviceInfo.h"
#import "AUXAudioDevice.h"

@class AUXUser;
typedef void(^AUXSligentLoginBlock)(AUXUser * user, NSString * token, NSString * openId, NSError * error);

NS_ASSUME_NONNULL_BEGIN

@interface AUXUser : NSObject <NSCoding>

@property (nonatomic, strong, nullable) NSData *deviceToken;

@property (nonatomic, strong, nullable, setter=setUid:) NSString *uid;
@property (nonatomic, strong, nullable) NSString *token;

@property (nonatomic, strong, nullable) NSString *accessToken;  // 用于请求SaaS的 access token

@property (nonatomic, strong, nullable) NSString *birthday;
@property (nonatomic, strong, nullable) NSString *gender;
@property (nonatomic, strong, nullable) NSString *headImg;
@property (nonatomic, strong, nullable) NSString *nickName;
@property (nonatomic, strong, nullable) NSString *phone;
@property (nonatomic, strong, nullable) NSString *realName;
@property (nonatomic, strong, nullable) NSString *country;
@property (nonatomic, strong, nullable) NSString *region;
@property (nonatomic, strong, nullable) NSString *city;

@property (nonatomic, strong, nullable) NSString *openid;
@property (nonatomic, strong, nullable) NSString *qqid;

@property (nonatomic, strong, nullable) NSString *account;
@property (nonatomic, strong, nullable) NSData *portrait;

@property (nonatomic, assign) int createdAt;
@property (nonatomic, assign) int lastLoginTime;

/**
 是否已注册 , true 已注册过，false第一次注册
 */
@property (nonatomic,assign) BOOL justRegister;
/**
 是否需要进入绑定页面
 */
@property (nonatomic,assign) BOOL needBindInFirstTIme;

/// 用户绑定过的设备列表 (服务器设备信息列表)
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;

/// 设备字典。key 为 deviceId。
@property (nonatomic, strong) NSMutableDictionary<NSString *, AUXACDevice *> *deviceDictionary;

/// 返回 SDK 设备列表
@property (nonatomic, strong, readonly) NSArray<AUXACDevice *> *deviceArray;

/// 手机唯一标识符
@property (class, nonatomic, strong, readonly) NSString *UUIDString;

/// 获取 AUXUser 的单例对象
+ (instancetype)defaultUser;

/// 本地化保存 AUXUser 的部分信息
+ (void)archiveUser;

/**
 本地化解档

 @return AUXUser
 */
+ (AUXUser *)unarchiveUser;

/**
 判断用户是否登录

 @return BOOL YES  登录  NO  没有登录
 */
+ (BOOL)isLogin;

/**
 是否绑定过手机号

 @return BOOL YES  绑定  NO  未绑定
 */
+ (BOOL)isBindAccount;

/// 用户注销。uid、token置nil；清空设备列表，取消设备订阅。
- (void)logout;

/**
 设置所有 AUXACDevice.delegates 的值

 @param delegate 设备代理
 */
- (void)addDevicesDelegate:(id<AUXACDeviceProtocol>)delegate;

- (void)removeDevicesDelegate:(id<AUXACDeviceProtocol>)delegate;

/**
 更新设备字典。(会订阅新增加的设备)

 @param deviceArray SDK搜索到的设备列表
 @param delegate 设备代理
 @return 是否有新的设备。
 */
- (BOOL)updateDeviceDictionaryWithDeviceArray:(nullable NSArray<AUXACDevice *> *)deviceArray deviceDelegate:(nullable id<AUXACDeviceProtocol>)delegate;

/**
 如果局域网内搜索不到旧设备，则创建远程设备对象。
 
 @param delegate 设备代理
 */
- (void)createOldDevicesIfNeededWithDeviceDelegate:(nullable id<AUXACDeviceProtocol>)delegate;

- (nullable AUXDeviceInfo *)getDeviceInfoWithMac:(NSString *)mac;
- (nullable AUXACDevice *)getSDKDeviceWithMac:(NSString *)mac;

/**
 将当前的设备列表转换为语音设备列表 (用于语意接口交互)

 @return 语音设备列表
 */
- (NSArray<AUXAudioDevice *> *)convertToAudioDeviceList;

/**
 设置uid时附加处理
 
 @param uid 新uid
 */
- (void)setUid:(nullable NSString *)uid;

@end

NS_ASSUME_NONNULL_END
