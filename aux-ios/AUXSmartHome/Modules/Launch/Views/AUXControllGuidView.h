//
//  AUXControllGuidView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXControllGuidView : UIView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic,assign) BOOL isControlDetailGuid;

@property (nonatomic, copy) void (^hideBlock)(void);

@end

NS_ASSUME_NONNULL_END
