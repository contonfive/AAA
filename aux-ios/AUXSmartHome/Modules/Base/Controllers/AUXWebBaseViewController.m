//
//  AUXWebBaseViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWebBaseViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXMobileInformationTool.h"
@interface NSURLRequest (InvalidSSLCertificate)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;


@end

@interface AUXWebBaseViewController ()

@property (nonatomic, strong) NSURLRequest *request;
//判断是否是HTTPS的
@property (nonatomic, assign) BOOL isAuthed;

//返回按钮
@property (nonatomic, strong) UIBarButtonItem *backItem;
//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;

//下面的三个属性是添加进度条的
@property (nonatomic, assign) BOOL theBool;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AUXWebBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = kAUXLocalizedString(@"Loading");
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *phoneType = [AUXMobileInformationTool deviceType];
    if ([phoneType isEqualToString:@"iPhone X"]||[phoneType isEqualToString:@"iPhone XR"]||[phoneType isEqualToString:@"iPhone XS"]||[phoneType isEqualToString:@"iPhone XS Max"]) {
        if (@available(iOS 11.0, *)) {
            self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        } else {
            self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kAUXNavAndStatusHight, kScreenWidth, kScreenHeight-kAUXNavAndStatusHight)];
        }
        
        UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-34, kScreenWidth, 34)];
        tmpView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.webView];
        [self.view addSubview:tmpView];
    }else{
        if (@available(iOS 11.0, *)) {
            self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        } else {
            self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kAUXNavAndStatusHight, kScreenWidth, kScreenHeight-kAUXNavAndStatusHight)];
        }
        [self.view addSubview:self.webView];
    }
    
    
    
    [self addLeftButton];
    
    //添加进度条（如果没有需要，可以注释掉
    [self addProgressBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

//加载URL
- (void)loadHTML:(NSString *)htmlString
{
    NSURL *url = [NSURL URLWithString:htmlString];
    self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    [self.webView loadRequest:self.request];
}


#pragma mark kvo 监听进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
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
    //    NSLog(@"开始加载网页");
    //    NSLog(@"开始加载网页---absoluteString--%@" , webView.URL.absoluteString);
    
    
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
}

#pragma mark - 添加关闭按钮

- (void)addLeftButton
{
    self.navigationItem.leftBarButtonItem = self.backItem;
}

//点击返回的方法
- (void)backNative
{
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        if (self.navigationController.viewControllers.count == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self closeNative];
        }
    }
}

//关闭H5页面，直接回到原生页面
- (void)closeNative
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - init

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        
        _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //这是一张“<”的图片，可以让美工给切一张
        UIImage *image = [UIImage imageNamed:@"common_btn_back_black"];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [btn setTintColor:[UIColor colorWithHexString:@"333333"]];
        [btn addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        //字体的多少为btn的大小
        [btn sizeToFit];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //让返回按钮内容继续向左边偏移15，如果不设置的话，就会发现返回按钮离屏幕的左边的距离有点儿大，不美观
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        btn.frame = CGRectMake(0, 0, 40, 40);
        _backItem.customView = btn;
    }
    return _backItem;
}

- (UIBarButtonItem *)closeItem
{
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeNative)];
    }
    return _closeItem;
}

#pragma mark - 下面所有的方法是添加进度条

- (void)addProgressBar {
    //进度条初始化
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kAUXNavAndStatusHight, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor blueColor];
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)dealloc{
    
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end

