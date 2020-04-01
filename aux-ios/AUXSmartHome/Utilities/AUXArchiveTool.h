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

NS_ASSUME_NONNULL_BEGIN

/**
 本地存储工具
 */
@interface AUXArchiveTool : NSObject

#pragma mark 账号密码

/**
 本地保存账号

 @param account 账号

 */
+ (void)archiveUserAccount:(NSString *)account ;

/**
 删除当前账号密码
 */
+ (void)removeUserAccount;

/**
 获取账号

 @return 账号
 */
+ (nullable NSString *)getArchiveAccount;

+ (void)archiveShouldLogoutWhenResume:(BOOL)logoutWhenResume;

+ (BOOL)shouldLogoutWhenResume;

+ (void)archiveIgnore:(BOOL)ignore version:(NSString *)version;

+ (BOOL)shouldIgnoreVersion:(NSString *)version;

#pragma mark Wi-Fi ssid & 密码

/**
 本地存储 WiFi ssid 和密码

 @param ssid WiFi ssid
 @param password 密码
 */
+ (void)archiveSSID:(NSString *)ssid password:(nullable NSString *)password;

/**
 根据 WiFi ssid 获取密码

 @param ssid WiFi ssid
 @return 密码
 */
+ (nullable NSString *)passwordForSSID:(NSString *)ssid;

#pragma mark 极光推送的数量保存

+ (NSNumber *)getRemoteNotificationNum;

+ (void)saveRemoteNotificationNum:(NSNumber *)index;

+ (void)clearRemoteNotificationNum;

#pragma mark 保存位置场景地图搜索历史
/**
 保存位置场景地图搜索历史

 @param data 保存的值
 */
+ (void)saveSceneMapSearchData:(NSMutableArray *)data;

/**
 取出位置场景地图搜索历史

 @return 取出的值
 */
+ (NSMutableArray *)readDataSceneMapSearchHistory;

/**
 清空保存的位置场景地图搜索历史
 */
+ (void)clearSceneMapSearchHistory;

#pragma mark 添加到小组件的设备数据
/**
 保存数据到Document中
 
 @param data 保存的数据
 */
+ (void)saveDataByNSFileManager:(NSArray *)data;

/**
 从Document中取数据
 
 @return 取出的数据
 */
+ (NSArray *)readDataByNSFileManager;

#pragma mark 科大讯飞

+ (void)archiveIFlyGrammerID:(nullable NSString *)grammerID;
+ (nullable NSString *)iflyGrammerID;

#pragma mark 用户设置列表显示样式
+ (void)saveDeviceListType:(AUXDeviceListType)deviceListType;
+ (AUXDeviceListType)readDeviceListType;
+ (void)removeDeviceListType;

#pragma mark 是否显示配置设备成功引导页
+ (BOOL)shouldShowConfigSuccessGuidePage;
+ (void)setShouldShowConfigSuccessGuidePage:(BOOL)value;

#pragma mark 是否显示控制指引页
+ (BOOL)shouldShowControlGuide;
+ (BOOL)shouldShowControlGuidePageList;
+ (BOOL)shouldShowControlGuidePageCard;
+ (void)setShouldShowControlGuidePage:(AUXDeviceListType)value;

#pragma mark 是否显示隐私声明
+ (BOOL)shouldShowPrivacy;
+ (void)setShouldShowPrivacy:(BOOL)value;

#pragma mark 是否显示控制控制栏组件使用方法
+ (BOOL)shouldShowNotificationControlGuidePage;
+ (void)setShouldShowNotificationControlGuidePage:(BOOL)value;

#pragma mark 是否是新的版本
+ (BOOL)shouldShowAdvertisementForVersion:(NSString *)version;
+ (void)hasShownAdvertisementForVersion:(NSString *)version;

#pragma mark 是否需要显示引导页
+ (BOOL)shouldShowGuidPage:(NSInteger)index;
+ (void)hasShowGuidPage:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
