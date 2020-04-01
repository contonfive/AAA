//
//  AUXPushLimitModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/22.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXPushLimitModel.h"

@implementation AUXPushLimitModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"guid" : @"id"};
}

- (NSString *)description
{
    return [self yy_modelDescription];
}
@end
