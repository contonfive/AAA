//
//  AUXSceneMapViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/14.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"

@interface AUXSceneMapViewController : AUXBaseViewController
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,assign) AUXSceneType sceneType;
@property (nonatomic,strong)NSString *markType;
@property (nonatomic,strong)NSString *isNewAdd;

@property (nonatomic,assign) NSInteger actionType;



@end
