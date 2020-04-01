//
//  NSUserDefaults+AUXCuxtom.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/1.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "NSUserDefaults+AUXCuxtom.h"

@implementation NSUserDefaults (AUXCuxtom)
+ (NSUserDefaults *)shareDefaults {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.auxgroup.smartac.group"];
    [defaults synchronize];
    return defaults;
}
@end
