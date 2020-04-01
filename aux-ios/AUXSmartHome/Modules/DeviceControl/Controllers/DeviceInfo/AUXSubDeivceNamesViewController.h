//
//  AUXSubDeivceNamesViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import "AUXDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSubDeivceNamesViewController : AUXBaseViewController
@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong, readonly) AUXACDevice *device;
@end

NS_ASSUME_NONNULL_END
