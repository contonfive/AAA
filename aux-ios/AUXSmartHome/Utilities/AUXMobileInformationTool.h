//
//  AUXMobileInformationTool.h
//  AUXSmartHome
//
//  Created by fengchuang on 2019/3/9.
//  Copyright © 2019 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>


NS_ASSUME_NONNULL_BEGIN

@interface AUXMobileInformationTool : NSObject
/**
 获取手机机型

 @return 手机机型
 */
+ (NSString*)deviceType;

/**
 获取手机系统版本号

 @return 手机系统版本号
 */
+ (NSString*)deviceVersion;

/**
 获取app版本号

 @return app版本号
 */
+ (NSString*)appVersion;


/**
 本方法是得到 UUID 后存入系统中的 keychain 的方法
 不用添加 plist 文件
 程序删除后重装,仍可以得到相同的唯一标示
 但是当系统升级或者刷机后,系统中的钥匙串会被清空,此时本方法失效
 */
+(NSString *)getDeviceIDInKeychain;
@end

NS_ASSUME_NONNULL_END
