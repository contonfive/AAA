//
//  AUXProduct.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXProduct.h"

@implementation AUXProduct

-(instancetype)init {
    self = [super init];
    if (self) {
        self.ProductGroupType = [[AUXPickListModel alloc]init];
//        self.ProgressList = [[AUXProgressListModel alloc]init];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"ProductGroupType":[AUXPickListModel class] , @"ProgressList" : [AUXProgressListModel class]};
}



- (NSString *)description
{
    return [self yy_modelDescription];
}
@end
