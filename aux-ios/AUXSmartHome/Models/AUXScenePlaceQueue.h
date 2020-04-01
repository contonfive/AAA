//
//  AUXScenePlaceQueue.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/23.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXSceneDetailModel.h"

@interface AUXScenePlaceQueue : NSObject

+ (instancetype)sharedInstance;


/**
 请求开启的位置场景 -- 程序每次进入前台加载一次
 */
- (void)requestOpenPlaceScene;

/**
 增加开启位置的任务

 @param sceneDetailModel sceneDetailModel
 */
- (void)appendTask:(AUXSceneDetailModel *)sceneDetailModel;


- (void)start;
@end

