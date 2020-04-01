//
//  AUXShareDeviceModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXShareDeviceModel.h"

#import <YYModel.h>

@implementation AUXShareDeviceModel


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"deviceDescription" : @"description"};
}

@end
