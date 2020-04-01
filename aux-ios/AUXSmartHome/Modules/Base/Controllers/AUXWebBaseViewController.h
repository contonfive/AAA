//
//  AUXWebBaseViewController.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXBaseViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXWebBaseViewController : AUXBaseViewController<UIWebViewDelegate, NSURLConnectionDelegate>

//定义一个属性，方便外接调用
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic,copy) NSString *loadUrl;

//声明一个方法，外接调用时，只需要传递一个URL即可
- (void)loadHTML:(NSString *)htmlString;

@end

NS_ASSUME_NONNULL_END
