//
//  AUXControllGuidView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXControllGuidView.h"
#import "AUXControlGuideConfirmView.h"
#import "AUXArchiveTool.h"

@interface AUXControllGuidView ()<UIScrollViewDelegate>

@end

@implementation AUXControllGuidView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSubviews {
    
    NSArray<NSString *> *imageNameArray;
    
    if (self.isControlDetailGuid) {
        imageNameArray = @[@"control_detail_guid_1", @"control_detail_guid_2"];
        if (kAUXIphoneX) {
            imageNameArray = @[ @"control_detail_guid_1_iphone_x" , @"control_detail_guid_2_iphone_x"];
        }
    }
    NSInteger count = imageNameArray.count;
    
    self.pageControl.numberOfPages = count;
    
    for (NSInteger i = 0; i < count; i++) {
        NSString *imageName = imageNameArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(i * kAUXScreenWidth, 0, kAUXScreenWidth, kAUXScreenHeight);
        [self.scrollerView addSubview:imageView];
    }
    
    self.scrollerView.contentSize = CGSizeMake(kAUXScreenWidth * count, 0);
    
    CGFloat confirmViewHeight = 50;
    CGRect frame = CGRectMake(kAUXScreenWidth * (count - 1), kAUXScreenHeight - kAUXScreenHeight * 0.23, kAUXScreenWidth, confirmViewHeight);
    
    if (kAUXIphoneX) {
        frame = CGRectMake(kAUXScreenWidth * (count - 1), kAUXScreenHeight - kAUXScreenHeight * 0.23 - confirmViewHeight, kAUXScreenWidth, confirmViewHeight);
    }
    
    
    AUXButton *button = [[AUXButton alloc]initWithFrame:frame];
    [self.scrollerView addSubview:button];
    
    [button addTarget:self action:@selector(actionConfirm) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAtcion:)];
    [self.scrollerView addGestureRecognizer:tap];
}

- (void)setIsControlDetailGuid:(BOOL)isControlDetailGuid {
    _isControlDetailGuid = isControlDetailGuid;
    
    [self setSubviews];
}

- (void)actionConfirm {
    
    self.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        if (self.hideBlock) {
            self.hideBlock();
        }
    }];
}

- (void)tapAtcion:(UITapGestureRecognizer *)sender {
    if (self.pageControl.numberOfPages == 2) {
        if (self.scrollerView.contentOffset.x == 0) {
            [self.scrollerView setContentOffset:CGPointMake(kAUXScreenWidth, 0) animated:YES];
            self.pageControl.currentPage = 1;
        } else {
            [self actionConfirm];
        }
    }
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = kAUXScreenWidth;
    
    CGFloat index = offsetX / width;
    
    self.pageControl.currentPage = (NSInteger)index;
}

@end
