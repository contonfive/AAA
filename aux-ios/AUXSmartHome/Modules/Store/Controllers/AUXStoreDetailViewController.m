//
//  AUXStoreDetailViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/6.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXStoreDetailViewController.h"
#import "AUXStoreMenuViewController.h"

@interface AUXStoreDetailViewController ()

@end

@implementation AUXStoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:AUXUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:AUXUserDidLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:AUXUserDidBindAccountNotification object:nil];
    
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    self.loadURL = self.loadURL;
    
    self.customBackAtcion = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.fromSearchStoreVC) {
        self.navigationController.navigationBarHidden = NO;
        self.wkWebView.frame = CGRectMake(0, 0, kAUXScreenWidth, kAUXScreenHeight - kAUXNavAndStatusHight);
        self.progressView.frame = CGRectMake(0, 0, kAUXScreenWidth, 2);

    }
}

- (void)loginSuccess {
    [self deleteWebCookiesCache];
    
    self.loadURL = [[AUXStoreDomainModel sharedInstance] getAuth:self.loadURL];
}

- (void)loginOut {
    [self deleteWebCookiesCache];
    
    self.loadURL = self.loadURL;
}

#pragma mark atcions

- (void)backAtcion {
    if ([self.wkWebView canGoBack]) {
        WKBackForwardListItem *backItem = self.wkWebView.backForwardList.backItem;
        WKBackForwardListItem *currentItem = self.wkWebView.backForwardList.currentItem;
        if ([backItem.URL.absoluteString isEqualToString:currentItem.URL.absoluteString]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.wkWebView goBack];
        }
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)closeAtcion:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)moreAtcion:(id)sender {
    AUXStoreMenuViewController *storeMenuViewController = [AUXStoreMenuViewController instantiateFromStoryboard:kAUXStoryboardNameStore];
    storeMenuViewController.storeMenuType = AUXStoreMenuTypeOfDetailButtonMenu;
    storeMenuViewController.classificationBlock = ^{
        [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.productType];
    };
    storeMenuViewController.myOrderBlock = ^{
        [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.orderList];
    };
    storeMenuViewController.userCenterBlock = ^{
        
        [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.ucenter];
    };
    storeMenuViewController.cartBlock = ^{
        
        [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.cart];
    };
    
    [self.tabBarController presentViewController:storeMenuViewController animated:YES completion:nil];
}


// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSString *url = webView.URL.absoluteString;
    if (![self.storeDomainModel whtherAuth:url]) {
        url = [self.storeDomainModel getAuth:url];
    }
    
//    NSLog(@"在收到响应后，决定是否跳转");
    NSLog(@"详情页--%@--absoluteString--%@" , webView.title , url);
    if ([self.storeDomainModel whtherLogin:url]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (![AUXUser isLogin]) {
                self.loadFail = YES;
                [self pushLoginViewController:@"AUXStoreDetailViewController" workUrl:url];
            } else if (![AUXUser isBindAccount]) {
                self.loadFail = YES;
                [self pushBindAccountViewController:@"AUXStoreDetailViewController" workUrl:url];
            }
        });
        decisionHandler(WKNavigationResponsePolicyCancel);
        
    } else if ([self.storeDomainModel whtherPoint:url]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (![AUXUser isLogin]) {
                self.loadFail = YES;
                [self pushLoginViewController:@"AUXStoreDetailViewController" workUrl:url];
                decisionHandler(WKNavigationResponsePolicyCancel);
            } else if (![AUXUser isBindAccount]) {
                self.loadFail = YES;
                [self pushBindAccountViewController:@"AUXStoreDetailViewController" workUrl:url];
                decisionHandler(WKNavigationResponsePolicyCancel);
            } else {
                decisionHandler(WKNavigationResponsePolicyAllow);
            }
        });
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
