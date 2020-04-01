//
//  AUXAddressView.m
//  ChooseLocation
//
//  Created by Sekorm on 16/8/25.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "AUXAddressView.h"
#import "UIView+MIExtensions.h"

static  CGFloat  const  HYBarItemMargin = 20;
@interface AUXAddressView ()
@property (nonatomic,strong) NSMutableArray * btnArray;
@end

@implementation AUXAddressView

- (void)layoutSubviews{
   
    [super layoutSubviews];
    
    if (self.btnArray.count == 0) {
        return ;
    }
    
    for (NSInteger i = 0; i <= self.btnArray.count - 1 ; i++) {
        
        UIView * view = self.btnArray[i];
        if (i == 0) {
            view.left = HYBarItemMargin;
        }
        if (i > 0) {
            UIView * preView = self.btnArray[i - 1];
            view.left = HYBarItemMargin  + preView.right;
        }
    }
    
    UIView * view = self.btnArray.lastObject;
    self.contentSize = CGSizeMake(view.right, self.bounds.size.height);
}

- (NSMutableArray *)btnArray{
    
    NSMutableArray * mArray  = [NSMutableArray array];
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [mArray addObject:view];
        }
    }
    _btnArray = mArray;
    return _btnArray;
}

@end
