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

#ifndef AUXConstant_h
#define AUXConstant_h

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const kAUXErrorDomain;

// JPush info
FOUNDATION_EXTERN NSString * const kAUXJPushAppKey;

//微信和QQ的AppId
FOUNDATION_EXTERN NSString * const kAUXWeChatAppId;
FOUNDATION_EXTERN NSString * const kAUXTencentAppId;

// Bugly
FOUNDATION_EXTERN NSString * const kAUXBuglyAppId;
FOUNDATION_EXTERN NSString * const kAUXBuglyAppKey;

// Bugly 测试
FOUNDATION_EXTERN NSString * const kTestAUXBuglyAppId;
FOUNDATION_EXTERN NSString * const kTestAUXBuglyAppKey;


// Product info
FOUNDATION_EXTERN NSString * const kAUXAppId;
FOUNDATION_EXTERN NSString * const kAUXAppSecret;
FOUNDATION_EXTERN NSString * const kAUXProductKeyCommercial;
FOUNDATION_EXTERN NSString * const kAUXProductKeyHousehold;
FOUNDATION_EXTERN NSString * const kAUXProductSecretCommercial;
FOUNDATION_EXTERN NSString * const kAUXProductSecretHousehold;

// Notifications
/// 通知 - 用户登录
FOUNDATION_EXTERN NSString * const AUXUserDidLoginNotification;
// 通知 - 用户绑定了手机号
FOUNDATION_EXTERN NSString * const AUXUserDidBindAccountNotification;
/// 通知 - 用户注销
FOUNDATION_EXTERN NSString * const AUXUserDidLogoutNotification;
/// 通知 - 用户账号缓存过期
FOUNDATION_EXTERN NSString * const AUXAccountCacheDidExpireNotification;
FOUNDATION_EXTERN NSString * const AUXAccessTokenDidExpireNotification;

// 通知 - 用户账号缓存更新
FOUNDATION_EXTERN NSString * const AUXAccountCacheDidUpdateNotification;

/// 通知 - 设备选择了风速
FOUNDATION_EXTERN NSString * const AUXDeviceSlectedWindSpeedNotification;
/// 通知 - 设备选择了模式
FOUNDATION_EXTERN NSString * const AUXDeviceSlectedAirConModeNotification;
/// 通知 - 解绑了设备
FOUNDATION_EXTERN NSString * const AUXDeviceDidUnbindNotification;
/// 通知 - 添加了定时
FOUNDATION_EXTERN NSString * const AUXDeviceDidAddSchedulerNotification;
/// 通知 - 删除了设备分享
FOUNDATION_EXTERN NSString * const AUXDeviceDidDeleteShareNotification;
/// 通知 - 修改了设备名称
FOUNDATION_EXTERN NSString * const AUXDeviceNameDidChangeNotification;
/// 通知 - 修改了设备SN码
FOUNDATION_EXTERN NSString * const AUXDeviceSNDidChangeNotification;
/// 通知 - 首页更新
FOUNDATION_EXTERN NSString * const AUXHomepageDidUpdateNotification;

// 设备列表请求完成
FOUNDATION_EXTERN NSString * const AUXDeviceListPostSuccessNotification;

/// 通知 - 远程推送跳转到本地但未登录
FOUNDATION_EXTERN NSString * const AUXRemoteNotificationToLocalNoLogin;

/// 通知 - 推出隐私声明
FOUNDATION_EXTERN NSString * const AUXWebUrlNotification;

/// 通知 - 商城详情页
FOUNDATION_EXTERN NSString * const AUXDetailStore;

/// 通知 - 商城绑定手机号
FOUNDATION_EXTERN NSString * const AUXStoreBindPhone;

/// 通知 - 商城绑定手机号
FOUNDATION_EXTERN NSString * const AUXStoreBindPhoneSuccess;

/// 通知 - 商城跳过绑定手机号
FOUNDATION_EXTERN NSString * const AUXStoreJumpBindAccount;


/// 通知 - 售后绑定手机号
FOUNDATION_EXTERN NSString * const AUXAfterSaleBindPhone;

/// 通知 - 售后绑定手机号成功
FOUNDATION_EXTERN NSString * const AUXAfterSaleBindPhoneFromUerSuccess;

/// 通知 - 售后绑定手机号成功
FOUNDATION_EXTERN NSString * const AUXAfterSaleBindPhoneFromControlSuccess;

/// 通知 - 售后创建新的联系人
FOUNDATION_EXTERN NSString * const AUXAfterSaleAddNewContact;

/// 通知 - 场景设备添加后的状态
FOUNDATION_EXTERN NSString * const AUXSceneDeviceSetSuccess;

/// 通知 - 场景编辑后保存上传完成
FOUNDATION_EXTERN NSString * const AUXSceneEditSaveSuccess;

/// 通知 - 场景取消删除状态
FOUNDATION_EXTERN NSString * const AUXSceneRemoeveDeleteStatus;

/// 通知 - 位置场景手动搜索结果
FOUNDATION_EXTERN NSString * const AUXScenePlaceManualSearchPlace;

// Storyboard name

FOUNDATION_EXTERN NSString * const kAUXStoryboardNameLogin;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameDeviceConfig;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameAudio;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameHomepage;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameDeviceControl;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameScene;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameFamily;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameStore;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameAfterSale;
FOUNDATION_EXTERN NSString * const kAUXStoryboardNameUserCenter;

// 二维码
FOUNDATION_EXTERN NSString * const kAUXQRCodePrefix;

#endif /* AUXConstant_h */
