//
//  AUXStoreBaseViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseViewController.h"
#import <WebKit/WebKit.h>
#import "AUXStoreDomainModel.h"
#import "AUXUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXStoreBaseViewController : AUXBaseViewController <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic,strong) AUXStoreDomainModel *storeDomainModel;

@property (nonatomic,copy) NSString *loadURL;

@property (nonatomic,copy) NSString *needURL;

@property (nonatomic,assign) BOOL loadFail;

/**
 未登录账号登录

 @param classString 登录后需要继续跳转的界面
 @param workUrl 登录后需要继续跳转的界面加载的URL
 */
- (void)pushLoginViewController:(NSString *)classString workUrl:(NSString *)workUrl;

/**
 推出详情页前，检查是否登录或绑定账号

 @param workUrl 完成操作后，需要加载的url
 */
- (void)pushToDetailVCCheckWhtherLoginOrBindAccount:(NSString *)workUrl;
/**
 推出详情界面

 @param workUrl 详情界面加载的URL
 */
- (void)pushToDetailViewControllerWithWorkUrl:(NSString *)workUrl;

/**
 退出到绑定手机号的页面

 @param classString 绑定手机号后继续跳转的页面
 @param workUrl 绑定手机号后继续跳转的页面加载的URL
 */
- (void)pushBindAccountViewController:(NSString *)classString workUrl:(NSString *)workUrl;

/**
 页面开始加载时调用
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

/**
 在收到响应后，决定是否跳转
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

- (void)deleteWebCookiesCache;

- (void)loginSuccess;

- (void)loginOut;

@end

NS_ASSUME_NONNULL_END
