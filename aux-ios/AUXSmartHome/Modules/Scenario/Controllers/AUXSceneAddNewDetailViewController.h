//
//  AUXSceneAddNewDetailViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AUXBaseViewController.h"
#import "AUXDeviceInfo.h"
#import "AUXSceneDeviceModel.h"
#import "AUXSceneAddModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneAddNewDetailViewController : AUXBaseViewController
@property (nonatomic,assign) AUXSceneType sceneType;
@property (nonatomic, copy) void (^gobackBlock)(NSString *deviceId,NSString*index);
@property (nonatomic,copy) NSString *titleStr;
@property (nonatomic,copy) NSString *from;
@property (nonatomic,strong)NSString *isNewAdd;
@property (nonatomic,strong)NSString *sceneName;
@end

NS_ASSUME_NONNULL_END
