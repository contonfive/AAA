//
//  AUXSceneCommonModel.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneCommonModel.h"
static AUXSceneCommonModel *handle = nil;
@implementation AUXSceneCommonModel
+(instancetype)shareAUXSceneCommonModel{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[AUXSceneCommonModel alloc] init];
    });
    return handle;
}

- (void)reSetValue {
    self.actionDescription = @"";
    self.actionTime = @"";
    self.actionType =0;
    self.deviceActionDtoList = @[].mutableCopy;
    self.distance =0;
    self.effectiveTime = @"";
    self.homePageFlag = 0;
    self.location = @"";
    self.address = @"";
    self.repeatRule = @"";
    self.sceneName = @"";
     self.sceneId = @"";
    self.isEdit = NO;
    self.whetherInitFlag =0;
    
}

@end
