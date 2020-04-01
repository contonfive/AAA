//
//  AUXSubmitWorkOrderModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSubmitWorkOrderModel.h"

@implementation AUXSubmitWorkOrderModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.TopContact = [[AUXTopContactModel alloc]init];
        self.Product = [[AUXProduct alloc]init];
        
        self.Memo = @"";
        self.LogisticsType = 1;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"TopContact":[AUXTopContactModel class] , @"Product":[AUXProduct class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"purchase_date" : @"new_purchase_date" , @"channeltype" : @"new_channeltypeText" , @"name" : @"new_name"};
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
