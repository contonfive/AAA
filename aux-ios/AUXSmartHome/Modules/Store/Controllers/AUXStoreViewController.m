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

#import "AUXStoreViewController.h"
#import "AUXStoreMenuViewController.h"
#import "AUXStoreSearchViewController.h"
#import "AUXStoreDetailViewController.h"
#import "AUXBaseNavigationController.h"
#import "AUXNetworkManager.h"
#import "AUXUser.h"

#import "UIColor+AUXCustom.h"
#import <WebKit/WebKit.h>
#import <YYModel/YYModel.h>

@interface AUXStoreViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *searchTextfiled;

@end

@implementation AUXStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:AUXUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:AUXUserDidLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:AUXUserDidBindAccountNotification object:nil];
    
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    self.loadURL = [self.storeDomainModel getAuth:self.storeDomainModel.eshopIndex];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)initSubviews {
    [super initSubviews];
    
    [self searchTextfiled];
}

- (void)loginSuccess {
    [self deleteWebCookiesCache];
    
    self.loadURL = [[AUXStoreDomainModel sharedInstance] getAuth:self.storeDomainModel.eshopIndex];
}

- (void)loginOut {
    [self deleteWebCookiesCache];
    
    self.loadURL = self.storeDomainModel.eshopIndex;
}

#pragma mark getters

- (UITextField *)searchTextfiled {
    if (!_searchTextfiled) {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAUXScreenWidth * 0.7, 30)];
        self.navigationItem.titleView = titleView;
        titleView.layer.cornerRadius = 14;
        titleView.layer.masksToBounds = YES;
        titleView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
        
        UIImage *searchImage = [UIImage imageNamed:@"common_icon_search"];
        UIImageView *leftImageView = [[UIImageView alloc] initWithImage:searchImage];
        leftImageView.frame = CGRectMake(14, 0, searchImage.size.width, titleView.frame.size.height);
        leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        [titleView addSubview:leftImageView];
        
        _searchTextfiled = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(leftImageView.frame) + 6, 0, titleView.frame.size.width - CGRectGetMaxX(leftImageView.frame) - 6, titleView.frame.size.height)];
        [titleView addSubview:_searchTextfiled];
        _searchTextfiled.delegate = self;
        _searchTextfiled.placeholder = @"奥克斯智能空调";
        
        [_searchTextfiled setValue:[UIColor colorWithHexString:@"8E959D"] forKeyPath:@"_placeholderLabel.textColor"];
        _searchTextfiled.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
        _searchTextfiled.textColor = [UIColor colorWithHexString:@"8E959D"];
        _searchTextfiled.font = [UIFont systemFontOfSize:14];
    }
    return _searchTextfiled;
}

#pragma mark atcions
- (IBAction)moreAtcion:(id)sender {
    AUXStoreMenuViewController *storeMenuViewController = [AUXStoreMenuViewController instantiateFromStoryboard:kAUXStoryboardNameStore];
    storeMenuViewController.storeMenuType = AUXStoreMenuTypeOfButtonMenu;
    storeMenuViewController.classificationBlock = ^{
        [self pushToDetailViewControllerWithWorkUrl:self.storeDomainModel.productType];
    };
    storeMenuViewController.myOrderBlock = ^{
        
        [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.orderList];
    };
    storeMenuViewController.userCenterBlock = ^{
        [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.ucenter];
    };
    
    [self.tabBarController presentViewController:storeMenuViewController animated:YES completion:nil];
}

- (IBAction)cartAtcion:(id)sender {
    [self pushToDetailVCCheckWhtherLoginOrBindAccount:self.storeDomainModel.cart];
}

#pragma mark UITextfiledDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    AUXStoreSearchViewController *storeSearchViewController = [AUXStoreSearchViewController instantiateFromStoryboard:kAUXStoryboardNameStore];
    AUXBaseNavigationController *baseNavController = [[AUXBaseNavigationController alloc]initWithRootViewController:storeSearchViewController];
    
    [self.tabBarController presentViewController:baseNavController animated:YES completion:^{
        [self.searchTextfiled resignFirstResponder];
    }];
}

#pragma mark WKWebViewDelegate
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSString *url = webView.URL.absoluteString;
    
    NSLog(@"首页--%@--absoluteString--%@" , webView.title , url);
    
    if ([url isEqualToString:self.storeDomainModel.eshopIndex]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else if ([self.storeDomainModel whtherAuth:url]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        
        if ([self.storeDomainModel whtherLogin:url]) {
            if (![AUXUser isLogin]) {
                [self pushLoginViewController:@"" workUrl:url];
            } else if (![AUXUser isBindAccount]) {
                [self pushBindAccountViewController:@"" workUrl:url];
            }
        } else {
            
            [self pushToDetailViewControllerWithWorkUrl:[self.storeDomainModel getAuth:url]];
        }
        
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
