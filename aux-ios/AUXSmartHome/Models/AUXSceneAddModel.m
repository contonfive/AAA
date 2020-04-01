//
//  AUXSceneAddModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/7.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneAddModel.h"


@implementation AUXSceneAddModel

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"deviceAction" : [AUXSceneDeviceModel class]};
}

- (BOOL)homePageFlag {
    return YES;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
