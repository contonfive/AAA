//
//  AUXSceneMapSearchHistory.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AUXSceneMapSearchHistory : UIView

@property (weak, nonatomic) IBOutlet UIButton *clearButton;


@property (nonatomic, copy) void (^clearBlock)(void);

@end
