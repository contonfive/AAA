//
//  AUXDeviceStateInfo.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/16.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceStateInfo.h"
static AUXDeviceStateInfo *handle = nil;

@implementation AUXDeviceStateInfo
+(instancetype)shareAUXDeviceStateInfo{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[AUXDeviceStateInfo alloc] init];
        handle.dataArray = [[NSMutableArray alloc]init];
    });
    return handle;
}

@end
