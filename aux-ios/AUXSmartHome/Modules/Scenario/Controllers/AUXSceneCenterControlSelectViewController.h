//
//  AUXSceneCenterControlSelectViewController.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/18.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneCenterControlSelectViewController : AUXBaseViewController
@property (nonatomic, assign) BOOL isCreatCentrol;
@property (nonatomic, assign) BOOL isfromHomepage;
@property (nonatomic,strong)NSString *isNewAdd;
@property (nonatomic,assign) BOOL isEdicenterol;

@property (nonatomic,strong)NSDictionary *tmpDict;
@end

NS_ASSUME_NONNULL_END
