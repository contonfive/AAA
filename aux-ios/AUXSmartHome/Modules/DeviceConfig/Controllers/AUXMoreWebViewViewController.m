//
//  AUXMoreWebViewViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXMoreWebViewViewController.h"
#import "AUXFeedbackViewController.h"
#import <YYModel.h>

@interface AUXMoreWebViewViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *morwebView;

@end

@implementation AUXMoreWebViewViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.navigationDelegate = self;
    [self loadHTML:kAUXHelpcenterUrl];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = [navigationAction.request URL].absoluteString;
    if ([url containsString:@"auxair://help/feedback"]) {
        
        NSString *query = [navigationAction.request URL].query;
        NSMutableDictionary *dict = [self queryToDict:query];
        
        AUXFeedbackViewController *feedBackViewController = [AUXFeedbackViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        feedBackViewController.typeLabel = dict[@"typeLabel"];
        feedBackViewController.feedBackType = [dict[@"type"] integerValue];
        [self.navigationController pushViewController:feedBackViewController animated:YES];
    }    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (NSMutableDictionary *)queryToDict:(NSString *)query {
    NSArray *subArray = [query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (int j = 0 ; j < subArray.count; j++)
    {
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
        NSString *value = dicArray[1];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [tempDic setObject:value forKey:dicArray[0]];
    }
    return tempDic;
}

@end
