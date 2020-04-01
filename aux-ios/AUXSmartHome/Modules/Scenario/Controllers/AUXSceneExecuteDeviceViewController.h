//
//  AUXSceneExecuteDeviceViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneExecuteDeviceViewController : AUXBaseViewController
@property (nonatomic,copy)NSString *form;
@property (nonatomic, copy) void (^backBlock)(NSArray *tmpArray);
@property (nonatomic,strong)NSDictionary *tmpDict;
@end

NS_ASSUME_NONNULL_END
