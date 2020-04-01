//
//  AUXUserWebViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/16.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXUserWebViewController.h"
#import "AUXFeedbackViewController.h"
#import <YYModel.h>
#import "AUXFeecBackRecordListViewController.h"
#import "AUXQuestionTypeViewController.h"
#import "AUXNetworkManager.h"
#import "UIBarButtonItem+AUXBadge.h"
#import "AUXElectronicSpecificationViewController.h"


@interface AUXUserWebViewController ()<WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic,assign)NSInteger noReadNumber;
@property (nonatomic,strong)UIButton *leftButton;
@property (nonatomic,strong)UIBarButtonItem *navLeftButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,strong)NSString *titleStr;
@property (nonatomic,assign) CGFloat scale;
@end
@implementation AUXUserWebViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.webView.scrollView.delegate = self;
    [self getData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isformFeaceback) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setImage:[UIImage imageNamed:@"mine_help_nav_btn_history"] forState:UIControlStateNormal];
        self.leftButton.frame = CGRectMake(0,100,self.leftButton.currentImage.size.width, self.leftButton.currentImage.size.height);
        [self.leftButton addTarget:self action:@selector(historyButtonAction) forControlEvents:UIControlEventTouchDown];
        // 添加角标
        self.navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
        self.navigationItem.rightBarButtonItem = self.navLeftButton;
    }
    
    self.webView.navigationDelegate = self;
    [self loadHTML:self.loadUrl];
    self.customBackAtcion = YES;
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)backAtcion{
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
    } else {
        if (self.isformElectronicSpecificationScan&& self.isformElectronicSpecification) {
            AUXElectronicSpecificationViewController *electronicSpecificationViewController = nil;
            for (AUXBaseViewController *tempVc in self.navigationController.viewControllers) {
                if ([tempVc isKindOfClass:[AUXElectronicSpecificationViewController class]]) {
                    electronicSpecificationViewController = (AUXElectronicSpecificationViewController*)tempVc;
                    [self.navigationController popToViewController:electronicSpecificationViewController animated:YES];
                }
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = [navigationAction.request URL].absoluteString;
    if ([url containsString:@"auxair://help/feedback"]) {
        
        if ([self.title isEqualToString:@"帮助与反馈"]) {
            AUXQuestionTypeViewController *questionTypeViewController = [AUXQuestionTypeViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            questionTypeViewController.isFormfirstpage = YES;
            [self.navigationController pushViewController:questionTypeViewController animated:YES];
        }else{
            NSString *query = [navigationAction.request URL].query;
            NSMutableDictionary *dict = [self queryToDict:query];
            AUXFeedbackViewController *feedBackViewController = [AUXFeedbackViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            feedBackViewController.typeLabel = dict[@"typeLabel"];
            feedBackViewController.feedBackType = [dict[@"type"] integerValue];
            [self.navigationController pushViewController:feedBackViewController animated:YES];
        }
        
    } else if ([url hasPrefix:@"tel:"]) {
        NSArray *telArray = [url componentsSeparatedByString:@":"];
        NSString *phone = [telArray lastObject];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", phone];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        });
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)historyButtonAction {
    AUXFeecBackRecordListViewController *feecBackRecordListViewController = [AUXFeecBackRecordListViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    [self.navigationController pushViewController:feecBackRecordListViewController animated:YES];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //设置webview的title
    if (self.isformFeaceback) {
        self.navigationItem.title = webView.title;
    }else if(self.isformElectronicSpecification){
        self.navigationItem.title = webView.title;
    }else{
        self.navigationItem.title =@"";
        if (!AUXWhtherNullString(self.title)) {
            self.navigationItem.title = self.title;
        }
    }
}


#pragma mark  获取列表
- (void)getData{
    [[AUXNetworkManager manager]getFeedbackcompltion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (error ==nil) {
            if ([dic[@"code"] integerValue]==200) {
                self.noReadNumber =0;
                for (NSDictionary *dict in dic[@"data"]) {
                    AUXFeedbackListModel *feedbackListModel = [[AUXFeedbackListModel alloc]init];
                    [feedbackListModel yy_modelSetWithDictionary:dict];
                    if (feedbackListModel.unreadNum !=0) {
                        self.noReadNumber =  self.noReadNumber + feedbackListModel.unreadNum;
                    }
                }
                if (self.isformFeaceback) {
                    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)self.noReadNumber];
                }
                
                
                
            }
        }
    }];
}


-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context{
    
    if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/"]) {
        self.title = @"帮助与反馈";
        self.titleStr = self.title;
        self.navigationItem.rightBarButtonItem = self.navLeftButton;
    }else if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/account"]){
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"账号问题";
        self.titleStr = self.title;
    }else if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/config"]){
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"设备添加";
        self.titleStr = self.title;
    }else if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/device_manager"]){
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"设备管理";
        self.titleStr = self.title;
    }else if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/function_abnormal"]){
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"功能异常";
        self.titleStr = self.title;
    }else if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/scene"]){
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"场景模式";
        self.titleStr = self.title;
    }else if ([self.webView.URL.absoluteString isEqualToString:@"https://smarthomelink.aux-home.com/auxhome_5_0/views/helpV2/center.html#/other_question"]){
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"其他问题";
        self.titleStr = self.title;
    }else{
        self.title = @"";
    }
    self.progressView.progress = self.webView.estimatedProgress;
    if (self.progressView.progress == 1) {
        
        __weak typeof (self)weakSelf = self;
        [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
        } completion:^(BOOL finished) {
            weakSelf.progressView.hidden = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.scale = self.webView.scrollView.contentSize.height/self.webView.scrollView.contentSize.width;
            });
            
            
        }];
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    [self.progressView removeFromSuperview];
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
- (void)dealloc{
    
    [self.webView removeObserver:self forKeyPath:@"URL"];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isformElectronicSpecification || self.isformElectronicSpecificationScan) {
        if (self.scale==0) {
            return;
        }
        if (self.webView.scrollView.zoomScale <= 0.7 ) {
            self.webView.scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenWidth*self.scale+30);
            [self.webView.scrollView layoutIfNeeded];
            [self.webView layoutIfNeeded];
        }
    }
}

#pragma mark 网页由于某些原因加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (self.isformElectronicSpecification || self.isformElectronicSpecificationScan) {
        [self showToastshortWithmessageinCenter:@"无法连接到服务器，请稍候再试"];
    }
}

@end





