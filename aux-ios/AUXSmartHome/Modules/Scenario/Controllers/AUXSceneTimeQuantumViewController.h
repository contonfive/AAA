//
//  AUXSceneTimeQuantumViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/11.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneTimeQuantumViewController : AUXBaseViewController
@property (nonatomic, copy) void (^gobackBlock)(NSDictionary*dic);
@property (nonatomic,strong)NSString *isNewAdd;

@end

NS_ASSUME_NONNULL_END
