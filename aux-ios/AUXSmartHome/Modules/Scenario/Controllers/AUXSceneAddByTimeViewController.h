//
//  AUXSceneAddByTimeViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneAddByTimeViewController : AUXBaseViewController
@property (nonatomic,assign) AUXSceneType sceneType;
@property (nonatomic,strong)NSString *markType;
@property (nonatomic, copy) void (^gobackBlock)(void);
@property (nonatomic,strong)NSString *isNewAdd;


@end

NS_ASSUME_NONNULL_END
