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

#import "AUXAdvertisementViewController.h"
#import "AUXControlGuideViewController.h"
#import "AUXArchiveTool.h"
#import "AUXPrivacyStatementView.h"
#import "AUXControllGuidSubview.h"

#import "UIView+MIExtensions.h"
#import "AUXUserWebViewController.h"


@interface AUXAdvertisementViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation AUXAdvertisementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initSubviews {
    [super initSubviews];
    
    NSArray<NSString *> *imageNameArray = @[@"guide_img1", @"guide_img2" , @"guide_img3"];
    
    NSInteger count = imageNameArray.count;
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    for (NSInteger i = 0; i < count; i++) {
        NSString *imageName = imageNameArray[i];
        AUXControllGuidSubview *guidSubview = [[NSBundle mainBundle] loadNibNamed:@"AUXControllGuidSubview" owner:nil options:nil].firstObject;
        guidSubview.frame = CGRectMake(i * kAUXScreenWidth , 0 , kAUXScreenWidth, kAUXScreenHeight);

        guidSubview.imageView.image = [UIImage imageNamed:imageName];
        guidSubview.index = i;
        [self.scrollView addSubview:guidSubview];
        
        guidSubview.nextAtcionBlock = ^{
            if (self.advertismentViewControllerShowBlock) {
                self.advertismentViewControllerShowBlock();
            }
            
            [self.navigationController popViewControllerAnimated:NO];
        };
    }
    
    self.scrollView.contentSize = CGSizeMake(width * count, 0);
    
    if ([AUXArchiveTool shouldShowPrivacy]) {
        AUXPrivacyStatementView *privacyView = [[NSBundle mainBundle] loadNibNamed:@"AUXPrivacyStatementView" owner:nil options:nil].firstObject;
        privacyView.frame = self.view.bounds;
        [self.view addSubview:privacyView];
        
        privacyView.jumpBlock = ^{
        
            AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            userWebViewController.loadUrl = kAUXPrivacyStatement;
            [self.navigationController pushViewController:userWebViewController animated:YES];
        };
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
