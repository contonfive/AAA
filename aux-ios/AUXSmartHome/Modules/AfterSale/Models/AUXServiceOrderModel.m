//
//  AUXServiceOrderModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXServiceOrderModel.h"

@implementation AUXServiceOrderModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"guid" : @"Id"};
}

- (NSString *)description
{
    return [self yy_modelDescription];
}
@end
