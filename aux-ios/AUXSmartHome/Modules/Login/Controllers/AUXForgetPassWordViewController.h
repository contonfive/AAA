//
//  AUXForgetPassWordViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXForgetPassWordViewController : AUXBaseViewController
@property(nonatomic,copy)NSString *phoneNumber;
@property(nonatomic,copy)NSString *getCodeType;
@property(nonatomic,copy)NSString *code;

@end

NS_ASSUME_NONNULL_END
