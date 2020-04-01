//
//  AUXStoreSearchViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXStoreSearchViewController.h"
#import "UIColor+AUXCustom.h"
#import <MessageThrottle.h>
#import "AUXStoreDetailViewController.h"
#import "AUXStoreSearchView.h"

static NSString* const kSearch = @"&a=search&keywords";
@interface AUXStoreSearchViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) AUXStoreSearchView *searchView;

@end

@implementation AUXStoreSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    NSString *urlString = [self.storeDomainModel searchUrlWithKeywords:@""];
    self.loadURL = urlString;
    [self mt_limitSelector:@selector(searchAtcion:) oncePerDuration:0.5];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, kAUXScreenWidth, 36)];
    [self.view addSubview:titleView];
    
    self.searchView.frame = titleView.bounds;
    [titleView addSubview:self.searchView];
    
    self.wkWebView.frame = CGRectMake(0, CGRectGetMaxY(titleView.frame) + 12, kAUXScreenWidth, kAUXScreenHeight - CGRectGetMaxY(titleView.frame) + 12);
    self.progressView.frame = CGRectMake(0, CGRectGetMaxY(titleView.frame) + 12, kAUXScreenWidth, 2);
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark getter

- (AUXStoreSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[[NSBundle mainBundle]  loadNibNamed:@"AUXStoreSearchView" owner:nil options:nil] firstObject];
        
        @weakify(self);
        _searchView.cancleBlock = ^{
            @strongify(self);
            [self cancleAtcion];
        };
        
        _searchView.searchBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            [self searchAtcion:text];
        };
    }
    return _searchView;
}

#pragma mark atcion
- (void)searchAtcion:(NSString *)text {
    
    NSString *keywords = text;
    keywords = [keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [self.storeDomainModel searchUrlWithKeywords:keywords];
    self.loadURL = urlString;
}

- (void)cancleAtcion {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSString *url = webView.URL.absoluteString;
    
    if ([url containsString:kSearch]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {

        AUXStoreDetailViewController *storeDetailViewController = [AUXStoreDetailViewController instantiateFromStoryboard:kAUXStoryboardNameStore];

        storeDetailViewController.loadURL = [self.storeDomainModel getAuth:url];
        storeDetailViewController.fromSearchStoreVC = YES;
        [self.navigationController pushViewController:storeDetailViewController animated:YES];
        
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

@end
