//
//  AUXQuestionTypeViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface AUXQuestionTypeViewController : AUXBaseViewController
@property (nonatomic,assign) NSInteger feedBackType;
@property (nonatomic, copy) void (^goBlock)(NSDictionary *dic);
@property (nonatomic,assign) BOOL isFormfirstpage;
@end

NS_ASSUME_NONNULL_END
