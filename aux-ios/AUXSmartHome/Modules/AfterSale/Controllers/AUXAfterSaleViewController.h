//
//  AUXAfterSaleViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/18.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"

@interface AUXAfterSaleViewController : AUXBaseViewController

@property (nonatomic,assign) BOOL fromDeviceControl;
@property (nonatomic,assign) AUXAfterSaleType afterSaleType;
@property (nonatomic,copy) NSString *faultName;
@end
