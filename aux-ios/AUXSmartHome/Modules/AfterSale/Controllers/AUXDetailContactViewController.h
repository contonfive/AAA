//
//  AUXDetailContactViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/26.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import "AUXTopContactModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXDetailContactViewController : AUXBaseViewController

@property (nonatomic,assign) BOOL fromDeviceControl;
@property (nonatomic,strong) AUXTopContactModel *chooseContact;
@property (nonatomic, copy) void (^chooseContactBlock)(AUXTopContactModel *contactModel);

@end

NS_ASSUME_NONNULL_END
