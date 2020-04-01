//
//  AUXAfterSaleWebViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/17.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleWebViewController.h"
#import <WebKit/WebKit.h>

@interface AUXAfterSaleWebViewController ()<WKNavigationDelegate>
@property (nonatomic,assign) AUXAfterSaleChargePolicyType  currentChargePolicyType;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation AUXAfterSaleWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *stringurl;
    if (self.webType == AUXAfterSaleWebTypeOfChargePolicy) {
        stringurl = [NSURL URLWithString:kAUXAfterSaleChargepolicyURL];
    } else {
        stringurl = [NSURL URLWithString:kAUXAfterSaleStatementURL];
    }

    self.webView.navigationDelegate = self;
    [self loadHTML:stringurl.absoluteString];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //设置webview的title
        self.navigationItem.title = @"";
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];

    [self.progressView removeFromSuperview];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context{
    self.progressView.progress = self.webView.estimatedProgress;
    if (self.progressView.progress == 1) {
        
        __weak typeof (self)weakSelf = self;
        [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
        } completion:^(BOOL finished) {
            weakSelf.progressView.hidden = YES;
            
        }];
    }
}


@end
