//
//  AUXSceneDetailModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/7.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneDetailModel.h"

#import <CoreLocation/CoreLocation.h>

@implementation AUXSceneDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"whetherInitFlag" : @"initFlag"};
}

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"deviceActionVoList" : [AUXSceneDeviceModel class]};
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
