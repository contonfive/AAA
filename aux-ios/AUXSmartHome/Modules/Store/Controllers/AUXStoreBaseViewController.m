//
//  AUXStoreBaseViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXStoreBaseViewController.h"
#import "AUXStoreMenuViewController.h"
#import "AUXLoginViewController.h"
#import "AUXBindAccountViewController.h"
#import "AUXStoreDomainModel.h"
#import "AUXNetworkManager.h"
#import "AUXLocalNetworkTool.h"

@interface AUXStoreBaseViewController ()

@property(copy, nonatomic) NSString *redirectUrl;
@property (nonatomic,copy) NSString *classString;
@property (nonatomic,copy) NSString *workUrl;
@end

@implementation AUXStoreBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissBindAccountVCNotification) name:AUXStoreJumpBindAccount object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addProgressView];
    
    if (AUXWhtherNullString(self.storeDomainModel.domain)) {
        [[AUXNetworkManager manager] getStoreConfigurationModelWithCompletion:^(AUXStoreDomainModel * _Nonnull storeModel, NSError * _Nonnull error) {
            if (!AUXWhtherNullString(self.storeDomainModel.domain)) {
                [self viewDidLoad];
            } else {
                [self showErrorViewWithMessage:error.userInfo[NSLocalizedDescriptionKey]];
            }
        }];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
    
}

- (void)dealloc {
    @try {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    } @catch (NSException *exception) {
        NSLog(@"多次删除kvo");
    } @finally {
        NSLog(@"多次删除kvo");
    }
}
- (void)setWebViewLoadUrl:(NSString *)url {
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)deleteWebCookiesCache {
    
    if (@available(iOS 9.0, *)) {//iOS9及以上
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                             for (WKWebsiteDataRecord *record in records)
                             {
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                        forDataRecords:@[record]
                                     completionHandler:^{
//                                         NSLog(@"Cookies for %@ deleted successfully",record.displayName);     
                                     }];
                             }
        }];
        
        // 清除所有
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
            NSLog(@"清楚缓存完毕");
            
        }];
    }else { //iOS9以下
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    }
}

- (void)configWebViewWithLoadURl:(NSString *)url {
    [self setWebViewLoadUrl:url];
}

#pragma mark setter
- (void)setLoadURL:(NSString *)loadURL {
    
    if ([_loadURL isEqualToString:loadURL]) {
        return ;
    }
    
    _loadURL = loadURL;
    if (_loadURL) {
        [self setWebViewLoadUrl:_loadURL];
    }
}

#pragma mark getters
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight - kAUXNavAndStatusHight)];
        [self.view addSubview:_wkWebView];
    }
    return _wkWebView;
}

- (AUXStoreDomainModel *)storeDomainModel {
    return [AUXStoreDomainModel sharedInstance];
}

#pragma mark atcion
- (void)addProgressView {
    //进度条初始化
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kAUXNavAndStatusHight, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor blueColor];
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.wkWebView.estimatedProgress == 1) {
        self.progressView.hidden = YES;
    }
}

- (void)pushLoginViewController:(NSString *)classString workUrl:(NSString *)workUrl {
    self.classString = classString;
    self.workUrl = workUrl;
    
    AUXLoginViewController *loginViewController = [AUXLoginViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
    loginViewController.fromType = AUXPushToLoginViewControllerTypeOfFromStore;
    loginViewController.loginSuccessBlock = ^{
        
        if ([AUXUser isBindAccount]) {
            [self haveBindAccount:classString workUrl:workUrl];
        } else {
            AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
            bindAccountViewController.bindAccountType = AUXBindAccountTypeOfStore;
            [self.navigationController pushViewController:bindAccountViewController animated:YES];
        }
    };
    
    loginViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)pushBindAccountViewController:(NSString *)classString workUrl:(NSString *)workUrl {
    
    AUXBaseViewController *lastVC = (AUXBaseViewController *)self.navigationController.viewControllers.lastObject;
    if ([lastVC isKindOfClass:[AUXBindAccountViewController class]]) {
        return ;
    }
    
    if (![AUXUser isBindAccount]) {
        AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
        bindAccountViewController.bindAccountType = AUXBindAccountTypeOfStore;
        [self.navigationController pushViewController:bindAccountViewController animated:YES];
    }
}

- (void)pushToDetailViewControllerWithWorkUrl:(NSString *)workUrl {
    
    Class class = NSClassFromString(@"AUXStoreDetailViewController");
    AUXStoreBaseViewController *viewController = [class instantiateFromStoryboard:kAUXStoryboardNameStore];
    viewController.loadURL = workUrl;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushToDetailVCCheckWhtherLoginOrBindAccount:(NSString *)workUrl {
    
    if ([self.storeDomainModel whtherProductType:workUrl]) {
        [self pushToDetailViewControllerWithWorkUrl:workUrl];
    } else if (![AUXUser isLogin]) {
        [self pushLoginViewController:@"AUXStoreDetailViewController" workUrl:workUrl];
        
    } else if (![AUXUser isBindAccount]) {
        [self pushBindAccountViewController:@"AUXStoreDetailViewController" workUrl:workUrl];
        
    } else {
        [self pushToDetailViewControllerWithWorkUrl:workUrl];
    }
    
}

- (void)haveBindAccount:(NSString *)classString workUrl:(NSString *)workUrl {
    
    if (AUXWhtherNullString(classString)) {
        [self.navigationController popViewControllerAnimated:YES];
        return ;
    }
    
    Class class = NSClassFromString(classString);
    AUXStoreBaseViewController *viewController = [class instantiateFromStoryboard:kAUXStoryboardNameStore];
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    
    NSInteger lastIndex = 0;
    for (int i = 0; i < viewControllers.count - 1; i++) {
        AUXBaseViewController *vc = (AUXBaseViewController *)viewControllers[i];
        if ([vc isKindOfClass:[AUXStoreBaseViewController class]]) {
            lastIndex = i + 1;
        }
    }
    
    AUXStoreBaseViewController *lastVC = viewControllers[lastIndex - 1];

    if ([AUXStoreDomainModel.sharedInstance whtherLogin:workUrl]) {
        NSString *url;
        if ([lastVC isKindOfClass:[AUXStoreBaseViewController class]]) {
            url = lastVC.wkWebView.backForwardList.backItem.URL.absoluteString;
            if (AUXWhtherNullString(url)) {
                url = lastVC.wkWebView.URL.absoluteString;
            }
        }
        
        if (AUXWhtherNullString(url)) {
            url = self.needURL;
        }
        if (AUXWhtherNullString(url)) {
            url = self.storeDomainModel.eshopIndex;
        }
        viewController.loadURL = [AUXStoreDomainModel.sharedInstance getAuth:url];
    } else {
        viewController.loadURL = [AUXStoreDomainModel.sharedInstance getAuth:workUrl];
    }
    
    BOOL containMessageVC = NO;
    for (AUXBaseViewController *baseVC in viewControllers) {
        if ([baseVC isKindOfClass:NSClassFromString(@"AUXMessageManagerViewController")]) {
            containMessageVC = YES;
        }
    }
    
    viewControllers = [[viewControllers subarrayWithRange:NSMakeRange(0, lastIndex)] mutableCopy];
    lastVC = (AUXStoreBaseViewController *)viewControllers.lastObject;
    if (lastVC.loadFail) {
        [viewControllers removeLastObject];
    }
    
    [viewControllers addObject:viewController];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)dismissBindAccountVCNotification {
    
    if (AUXWhtherNullString(self.classString)) {
        return ;
    }
    
    if (AUXWhtherNullString(self.workUrl)) {
        return ;
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark kvo 监听进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.wkWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark ====== WKWebViewDelegate ======
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    self.navigationItem.title = kAUXLocalizedString(@"Loading");
    
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.progressView];
    
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //设置webview的title
    self.navigationItem.title = webView.title;
    
    NSArray *nCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];NSHTTPCookie *cookie;
    for (id c in nCookies){
        if ([c isKindOfClass:[NSHTTPCookie class]]){
            cookie=(NSHTTPCookie *)c;
//            NSLog(@"cookie.name--%@: cookie.value--%@", cookie.name, cookie.value);
        }
    }
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"网络不给力");
    self.loadFail = YES;
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {

}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"在发送请求之前，决定是否跳转--absoluteString--%@" , navigationAction.request.URL.absoluteString);
    NSString *absoluteString = navigationAction.request.URL.absoluteString;
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    if ([absoluteString containsString:kWXPre] && [absoluteString containsString:@"&redirect_url="]) {
        NSRange range = [absoluteString rangeOfString:@"&redirect_url="];
        NSURL *url = [[NSURL alloc] initWithString:[absoluteString substringToIndex:range.location]];
        self.redirectUrl = [absoluteString substringFromIndex:range.location + range.length];
        self.redirectUrl = [AUXStoreDomainModel.sharedInstance decodeString:self.redirectUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:@"www.auxshop.com://" forHTTPHeaderField:@"Referer"];
        [webView loadRequest:request];
        actionPolicy = WKNavigationActionPolicyCancel;
    }
    if ([absoluteString containsString:kAUXSchemesAlipays]) {
        [[UIApplication sharedApplication]openURL:navigationAction.request.URL];
    } else if ([absoluteString containsString:kAUXSchemesWeXin]) {
        [[UIApplication sharedApplication]openURL:navigationAction.request.URL];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.redirectUrl]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [webView loadRequest:request];
        });
    } else if ([absoluteString containsString:kAUXSchemesTaoBao]) {
        
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication]openURL:navigationAction.request.URL];
        }
    } else if ([absoluteString containsString:kAUXSchemesTmall]) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication]openURL:navigationAction.request.URL];
        }
    }
    
    decisionHandler(actionPolicy);
}


@end
