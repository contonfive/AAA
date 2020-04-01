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

#import "AUXMessageLinkViewController.h"

@interface AUXMessageLinkViewController () <WKNavigationDelegate>

@end

@implementation AUXMessageLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight - kAUXNavAndStatusHight);
    self.webView.navigationDelegate = self;
    [self loadHTML:self.loadUrl];
    
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *schemeURL = webView.URL;
    NSString *scheme = webView.URL.scheme;
    
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"] && [[UIApplication sharedApplication] canOpenURL:schemeURL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:schemeURL options:@{} completionHandler:^(BOOL success) {    
            }];
        } else {
            [[UIApplication sharedApplication] openURL:schemeURL];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
