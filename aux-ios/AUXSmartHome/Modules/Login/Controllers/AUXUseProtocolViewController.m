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

#import "AUXUseProtocolViewController.h"
#import "UIColor+AUXCustom.h"

#import "AUXButton.h"

#import <WebKit/WebKit.h>

@interface AUXUseProtocolViewController () <UIWebViewDelegate,WKNavigationDelegate, WKUIDelegate,QMUINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet AUXButton *exitButton;     // 退出
@property (weak, nonatomic) IBOutlet AUXButton *agreeButton;    // 同意
@property (nonatomic,assign)BOOL backType;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AUXUseProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backType = YES;
    self.bottomView.hidden = YES;
    self.webView.delegate = self;

    //设置同意按钮的圆角
    self.agreeButton.layer.masksToBounds = YES;
    self.agreeButton.layer.cornerRadius = self.agreeButton.frame.size.height/2;
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kAUXUserProtocol]]];
    self.webView.scalesPageToFit = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Actions
- (IBAction)actionExit:(id)sender {
    self.backType = NO;;
    if (self.exitBlock) {
        //为了保证前面的动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.exitBlock();
        });
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionAgree:(id)sender {
    self.backType = NO;;
    if (self.agreeBlock) {
        self.agreeBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewDidDisappear:(BOOL)animated{
    if (self.backType) {
         self.backBlock();
    }
    self.backType = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.isLoading) {
        self.bottomView.hidden = NO;
    }
}

@end
