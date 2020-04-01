//
//  AUXTouchRemoteOrShareLink.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/19.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AUXDeviceListViewController.h"
#import "AUXRemoteNotificationModel.h"

@interface AUXTouchRemoteOrShareLink : NSObject

+ (instancetype)sharedInstance;


/**
 点击广告页跳转

 @param contentModel 广告模型
 */
- (void)touchAdvertisingWithRemoteNotificationModel:(AUXRemoteNotificationModel *)contentModel;

/**
 点击了推送的通知消息

 @param info 推送消息的内容,可设为nil(跳转到小组件页面)
 */
- (void)touchRemoteNotificationWithInfo:(NSDictionary *)info remoteNotificationModel:(AUXRemoteNotificationModel *)contentModel;

/**
 处理分享的内容

 @param clipboardShareData 分享链接携带的参数
 */
- (void)handleDidRecvQRcontent:(NSString *)clipboardShareData;

/**
 根据widget传递的deviceID跳转到指定的设备控制页面

 @param deviceID widget传递的deviceID
 */
- (void)pushToDeviceControllerWithDeviceID:(NSString *)deviceID;

/**
 跳转到小组件页面
 */
- (void)pushToWidgetViewController;

/**
 跳转到设备列表

 @return 设备列表
 */
- (AUXDeviceListViewController *)pushToDeviceListViewController;

- (BOOL)shouldLogoutWithUserInfo:(NSDictionary *)userInfo;

@end
