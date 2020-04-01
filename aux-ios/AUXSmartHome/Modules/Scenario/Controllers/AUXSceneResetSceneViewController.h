//
//  AUXSceneResetSceneViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXSceneDetailModel.h"
#import "AUXDeviceInfo.h"
#import "AUXSceneAddModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneResetSceneViewController : AUXBaseViewController
@property (nonatomic,assign) AUXSceneType sceneType;
@property (nonatomic,strong) AUXSceneAddModel *sceneAddModel;
@property (nonatomic,copy) NSString *from;
@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *titleStr;
@property (nonatomic, copy) void (^goBlock)(void);
@property (nonatomic,strong)NSString *isNewAdd;

@property (nonatomic,assign)NSString * index;

@property (nonatomic,assign)NSString * sceneName;
@property (nonatomic,strong)NSString *addnewDevice;
@property (nonatomic,assign)BOOL delectLastobject;


@end

NS_ASSUME_NONNULL_END
