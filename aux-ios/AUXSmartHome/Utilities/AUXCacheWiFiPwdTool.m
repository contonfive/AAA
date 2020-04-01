//
//  AUXCacheWiFiPwdTool.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXCacheWiFiPwdTool.h"


static AUXCacheWiFiPwdTool *handle = nil;
@implementation AUXCacheWiFiPwdTool
+(instancetype)shareAUXAUXCacheWiFiPwdTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[AUXCacheWiFiPwdTool alloc] init];
       handle.dataDic = [[NSMutableDictionary alloc]init];

    });
    return handle;
}

@end
