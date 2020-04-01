//
//  AUXAddNewContactViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import "AUXTopContactModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXAddNewContactViewController : AUXBaseViewController

@property (nonatomic,assign) BOOL fromDeviceControl;
@property (nonatomic,strong) AUXTopContactModel *topContactModel;
@property (nonatomic,assign) AUXAfterSaleAddContactType contactFromType;
@end

NS_ASSUME_NONNULL_END
