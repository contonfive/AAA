//
//  AUXDeviceSearchViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/3/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import "AUXDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceSearchViewController :AUXBaseViewController
@property (nonatomic,strong)NSArray<AUXDeviceModel *> * _Nullable deviceModelList;

@end

NS_ASSUME_NONNULL_END
