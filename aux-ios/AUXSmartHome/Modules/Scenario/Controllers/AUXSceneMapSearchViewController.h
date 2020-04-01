//
//  AUXSceneMapSearchViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface AUXSceneMapSearchViewController : AUXBaseViewController

@property (nonatomic, copy) void (^cellSelcetedBlock)(AMapTip *tip);

@end
