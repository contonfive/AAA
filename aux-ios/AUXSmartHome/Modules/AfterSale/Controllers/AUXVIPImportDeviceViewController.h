//
//  AUXVIPImportDeviceViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/12.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXVIPImportDeviceViewController : AUXBaseViewController

@property (nonatomic, copy) void (^deviceSnBlock)(NSString *deviceSN);

@end

NS_ASSUME_NONNULL_END
