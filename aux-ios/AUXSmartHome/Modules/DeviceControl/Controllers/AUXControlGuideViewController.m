/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXControlGuideViewController.h"

#import "AUXControlGuideConfirmView.h"

#import "AUXArchiveTool.h"

@interface AUXControlGuideViewController () <UIScrollViewDelegate>

@property (nonatomic,assign) AUXDeviceListType deviceListType;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation AUXControlGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<NSString *> *imageNameArray;
    
    if (self.deviceListType == AUXDeviceListTypeOfGrid) {
        imageNameArray = @[@"control_guide_02", @"control_guide_03"];
        if (kAUXIphoneX) {
            imageNameArray = @[ @"control_guide_02_iphone_x" , @"control_guide_03_iphone_x"];
        }
    } else if (self.deviceListType == AUXDeviceListTypeOfList) {
        imageNameArray = @[@"control_guide_01"];
        if (kAUXIphoneX) {
            imageNameArray = @[@"control_guide_01_iphone_x"];
        }
    }
    
    if (self.isControlDetailGuid) {
        imageNameArray = @[@"control_detail_guid_1", @"control_detail_guid_2"];
        if (kAUXIphoneX) {
            imageNameArray = @[ @"control_detail_guid_1_iphone_x-x" , @"control_detail_guid_2_iphone_x-x"];
        }
    }
    
    NSInteger count = imageNameArray.count;
    
    self.pageControl.numberOfPages = count;
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    for (NSInteger i = 0; i < count; i++) {
        NSString *imageName = imageNameArray[i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = CGRectMake(i * width, 0, width, height);
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(width * count, 0);
    
    CGFloat confirmViewHeight = 50;
    CGRect frame = CGRectMake(width * (count - 1), height - height * 0.23, width, confirmViewHeight);
    
    if (kAUXIphoneX) {
        frame = CGRectMake(width * (count - 1), height - height * 0.23 - confirmViewHeight, width, confirmViewHeight);
    }
    
    
    AUXButton *button = [[AUXButton alloc]initWithFrame:frame];
    [self.scrollView addSubview:button];
    
    [button addTarget:self action:@selector(actionConfirm) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAtcion:)];
    [self.scrollView addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (AUXDeviceListType)deviceListType {
    return [AUXArchiveTool readDeviceListType];
}

- (void)actionTipButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [AUXArchiveTool setShouldShowControlGuidePage:!sender.selected];
}

- (void)actionConfirm {
    [AUXArchiveTool setShouldShowControlGuidePage:self.deviceListType];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)tapAtcion:(UITapGestureRecognizer *)sender {
    
    if (self.deviceListType == AUXDeviceListTypeOfGrid) {
        if (self.scrollView.contentOffset.x == 0) {
            [self.scrollView setContentOffset:CGPointMake(kAUXScreenWidth, 0) animated:YES];
            self.pageControl.currentPage = 1;
        } else {
            [self actionConfirm];
        }
    } else  {
        [self actionConfirm];
    }
    
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    CGFloat index = offsetX / width;
    
    self.pageControl.currentPage = (NSInteger)index;
}

@end
