//
//  AUXConstant.m
//  AUXSmartHome
//
//  Created by Minus🍀 on 2018/3/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXConstant.h"

NSString * const kAUXErrorDomain = @"com.auxgroup.smarthome";

// JPush info
NSString * const kAUXJPushAppKey = @"d394d34c95d7b8d80f4d975d";

NSString * const kAUXWeChatAppId = @"wx56da5ea2e7839f40";
NSString * const kAUXTencentAppId = @"tencent1106827098";

// Bugly 正式
NSString * const kAUXBuglyAppId = @"7dfa7cdd68";
NSString * const kAUXBuglyAppKey = @"c9a193e4-ea24-4f45-b78c-1a7a924d5c9f";

// Bugly 测试
NSString * const kTestAUXBuglyAppId = @"5baaab9fb3";
NSString * const kTestAUXBuglyAppKey = @"ff025b67-251b-40da-a42b-bf519543b3b2";




// Product info
//NSString * const kAUXAppId = @"780b49c9b953425da6bc8b026cd54b81"; //用来测试的 AppID  测完删除
NSString * const kAUXAppId = @"60b8eaa792aa4de1badf04fc20a8ba56";
NSString * const kAUXAppSecret = @"832af0018b5f434f93c55fae32096f0b";
NSString * const kAUXProductKeyCommercial = @"031fd83a03d5403a963fb45d33d85a76";
NSString * const kAUXProductKeyHousehold = @"60c8cbbef8814de2951383f7040aef26";
NSString * const kAUXProductSecretCommercial = @"2d5332b2f9c84029925db98d1ce9c718";
NSString * const kAUXProductSecretHousehold = @"5c5d5618297345f8bab9266b4d8d8bc8";

// Notifications
// 通知 - 用户登录
NSString * const AUXUserDidLoginNotification = @"AUXUserDidLoginNotification";
// 通知 - 用户绑定了手机号
NSString * const AUXUserDidBindAccountNotification = @"AUXUserDidBindAccountNotification";
// 通知 - 用户注销
NSString * const AUXUserDidLogoutNotification = @"AUXUserDidLogoutNotification";
// 通知 - 用户账号缓存过期
NSString * const AUXAccountCacheDidExpireNotification = @"AUXAccountCacheDidExpireNotification";
NSString * const AUXAccessTokenDidExpireNotification = @"AUXAccessTokenDidExpireNotification";

// 通知 - 用户账号缓存更新
NSString * const AUXAccountCacheDidUpdateNotification = @"AUXAccountCacheDidUpdateNotification";

/// 通知 - 设备选择了风速
NSString * const AUXDeviceSlectedWindSpeedNotification = @"AUXDeviceSlectedWindSpeedNotification";
/// 通知 - 设备选择了模式
NSString * const AUXDeviceSlectedAirConModeNotification = @"AUXDeviceSlectedAirConModeNotification";

// 通知 - 解绑了设备
NSString * const AUXDeviceDidUnbindNotification = @"AUXDeviceDidUnbindNotification";
// 通知 - 添加了定时
NSString * const AUXDeviceDidAddSchedulerNotification = @"AUXDeviceDidAddSchedulerNotification";
// 通知 - 删除了设备分享
NSString * const AUXDeviceDidDeleteShareNotification = @"AUXDeviceDidDeleteShareNotification";
// 通知 - 修改了设备名称
NSString * const AUXDeviceNameDidChangeNotification = @"AUXDeviceNameDidChangeNotification";
// 通知 - 修改了设备SN码
NSString * const AUXDeviceSNDidChangeNotification = @"AUXDeviceSNDidChangeNotification";
// 通知 - 首页更新
NSString * const AUXHomepageDidUpdateNotification = @"AUXHomepageDidUpdateNotification";

// 设备列表请求完成
NSString * const AUXDeviceListPostSuccessNotification = @"AUXDeviceListPostSuccessNotification";

/// 通知 - 远程推送跳转到本地但未登录
NSString * const AUXRemoteNotificationToLocalNoLogin = @"AUXRemoteNotificationToLocalNoLogin";

/// 通知 - 推出隐私声明
NSString * const AUXWebUrlNotification = @"AUXWebUrlNotification";

/// 通知 - 商城详情页
NSString * const AUXDetailStore = @"AUXDetailStore";

/// 通知 - 商城绑定手机号
NSString * const AUXStoreBindPhone = @"AUXStoreBindPhone";

/// 通知 - 商城绑定手机号
NSString * const AUXStoreBindPhoneSuccess = @"AUXStoreBindPhoneSuccess";

/// 通知 - 商城跳过绑定手机号
NSString * const AUXStoreJumpBindAccount = @"AUXStoreJumpBindAccount";

/// 通知 - 售后绑定手机号
NSString * const AUXAfterSaleBindPhone = @"AUXAfterSaleBindPhone";

/// 通知 - 售后绑定手机号成功
NSString * const AUXAfterSaleBindPhoneFromUerSuccess = @"AUXAfterSaleBindPhoneFromUerSuccess";

/// 通知 - 售后绑定手机号成功
NSString * const AUXAfterSaleBindPhoneFromControlSuccess = @"AUXAfterSaleBindPhoneFromControlSuccess";

/// 通知 - 售后创建新的联系人
NSString * const AUXAfterSaleAddNewContact = @"AUXAfterSaleAddNewContact";

/// 通知 - 场景设备添加后的状态
NSString * const AUXSceneDeviceSetSuccess = @"AUXSceneDeviceSetSuccess";

/// 通知 - 场景编辑后保存上传完成
NSString * const AUXSceneEditSaveSuccess = @"AUXSceneEditSaveSuccess";

/// 通知 - 场景取消删除状态
NSString * const AUXSceneRemoeveDeleteStatus = @"AUXSceneRemoeveDeleteStatus";

/// 通知 - 位置场景手动搜索结果
NSString * const AUXScenePlaceManualSearchPlace = @"AUXScenePlaceManualSearchPlace";

// Storyboard name

NSString * const kAUXStoryboardNameLogin = @"Login";
NSString * const kAUXStoryboardNameDeviceConfig = @"DeviceConfig";
NSString * const kAUXStoryboardNameAudio = @"Audio";
NSString * const kAUXStoryboardNameHomepage = @"Homepage";
NSString * const kAUXStoryboardNameDeviceControl = @"DeviceControl";
NSString * const kAUXStoryboardNameScene = @"Scene";
NSString * const kAUXStoryboardNameStore = @"Store";
NSString * const kAUXStoryboardNameFamily = @"Family";
NSString * const kAUXStoryboardNameAfterSale = @"AfterSale";
NSString * const kAUXStoryboardNameUserCenter = @"UserCenter";

// 二维码
NSString * const kAUXQRCodePrefix = @"QR_AUX:";


