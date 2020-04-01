//
//  AUXWorkOrderModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderModel.h"

@implementation AUXWorkOrderModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"guid" : @"Id" , @"workNumber" : @"new_name"};
}

- (BOOL)isHomeWorkOrder {
    return [self.EntityName isEqualToString:@"new_home_workorder"];
}

- (BOOL)isSrvWorkOrder {
    return [self.EntityName isEqualToString:@"new_srv_workorder"];
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
