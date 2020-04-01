//
//  AUXSceneSelectDeviceListViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//
/**
 选择执行设备界面
 
 */
#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXSceneDetailModel.h"
#import "AUXSceneAddModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneSelectDeviceListViewController : AUXBaseViewController
@property (nonatomic,assign) AUXSceneType sceneType;
@property (nonatomic,strong)NSString *isNewAdd;
@property (nonatomic,assign) BOOL isFromScenehomepage;
@property (nonatomic,strong)NSString *sceneName1;


@end

NS_ASSUME_NONNULL_END
