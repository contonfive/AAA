//
//  AUXUserprofileModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/11.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXUserprofileModel.h"

@implementation AUXUserprofileModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"guid" : @"Id"};
}

- (NSString *)description
{
    return [self yy_modelDescription];
}
@end
