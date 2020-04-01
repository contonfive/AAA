//
//  AUXSceneAddLocationViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneAddLocationViewController : AUXBaseViewController
@property (nonatomic,assign) AUXSceneType sceneType;
@property (nonatomic,strong)NSString *isNewAdd;
@property (nonatomic,strong)NSString *markType;
@property (nonatomic,strong) NSString *location;


@end

NS_ASSUME_NONNULL_END
