//
//  AUXConfigSuccessGuideViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/18.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXConfigSuccessGuideViewController.h"
#import "AUXControlGuideConfirmView.h"
#import "AUXArchiveTool.h"

@interface AUXConfigSuccessGuideViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end

@implementation AUXConfigSuccessGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<NSString *> *imageNameArray = @[@"control_success_guide_01", @"control_success_guide_02", @"control_success_guide_03"];
    NSInteger count = imageNameArray.count;
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    for (NSInteger i = 0; i < count; i++) {
        NSString *imageName = imageNameArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(i * width, 0, width, height);
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(width * count, 0);
    
    CGFloat confirmViewHeight = 110;
    
    AUXControlGuideConfirmView *confirmView = [AUXControlGuideConfirmView instantiateFromNib];
    confirmView.frame = CGRectMake(width * (count - 1), height - confirmViewHeight, width, confirmViewHeight);
    [self.scrollView addSubview:confirmView];
    
    [confirmView.tipButton addTarget:self action:@selector(actionTipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [confirmView.confirmButton addTarget:self action:@selector(actionConfirm:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)actionTipButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [AUXArchiveTool setShouldShowConfigSuccessGuidePage:!sender.selected];
}

- (void)actionConfirm:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    CGFloat index = offsetX / width;
    
    self.pageControl.currentPage = (NSInteger)index;
}


@end
