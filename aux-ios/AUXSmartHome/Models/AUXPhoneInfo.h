//
//  AUXPhoneInfo.h
//  AUXSmartHome
//
//  Created by 奥克斯家研--张海昌 on 2018/5/23.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
#import "AUXDefinitions.h"

@interface AUXPhoneInfo : NSObject

/**
 消息id(用来标识唯一性 uid+,+时间戳),string
 */
@property (nonatomic,copy) NSString *message_id;

/**
 配网方式,int
 */
@property (nonatomic,assign) NSInteger config_type;

/**
 配网方式对应值,string
 */
@property (nonatomic,copy) NSString *config_type_value;

/**
 wifi的id,string
 */
@property (nonatomic,copy) NSString *wifi_ssid;

/**
 路由器mac,string
 */
@property (nonatomic,copy) NSString *bssid;

/**
 "频率,string",   ios无法获得
 */
@property (nonatomic,copy) NSString *frequency;

/**
 隐藏ssid,boolean
 */
@property (nonatomic,assign) BOOL hidden_ssid;

/**
 当前连接手机的IP
 */
@property (nonatomic,copy) NSString *ip;

/**
 网络id,string
 */
@property (nonatomic,copy) NSString *net_id;

/**
 手机系统版本,string
 */
@property (nonatomic,copy) NSString *os_version;

/**
 手机型号,string
 */
@property (nonatomic,copy) NSString *phone_model;

/**
 信号强度,string
 */
@property (nonatomic,copy) NSString *rssi;

/**
 当前网速
 */
@property (nonatomic,copy) NSString *speed;

/**
 配网连接成功/失败标记,string
 */
@property (nonatomic,copy) NSString *connect_tag;

/**
 成功失败码 
 */
@property (nonatomic,assign) NSInteger connect_code;


/**
 APP版本号
 */
@property (nonatomic,copy) NSString *app_version;


/**
 配网的机型
 */
@property (nonatomic,copy) NSString *device_type;


@end
