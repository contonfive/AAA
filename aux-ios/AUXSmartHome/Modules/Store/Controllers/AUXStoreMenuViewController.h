//
//  AUXStoreMenuViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXPopupMenuViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXStoreMenuViewController : AUXPopupMenuViewController

@property (nonatomic, copy) void (^classificationBlock)(void);
@property (nonatomic, copy) void (^myOrderBlock)(void);
@property (nonatomic, copy) void (^userCenterBlock)(void);
@property (nonatomic, copy) void (^cartBlock)(void);

@property (nonatomic,assign) AUXStoreMenuType storeMenuType;
@end

NS_ASSUME_NONNULL_END
