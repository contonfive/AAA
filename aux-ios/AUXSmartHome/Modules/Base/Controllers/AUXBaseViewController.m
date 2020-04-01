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

#import "AUXBaseViewController.h"
#import "AUXConfirmOnlyMessageAlertView.h"
#import "UIColor+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"
#import "AUXAlertCustomView.h"
#import "AppDelegate.h"

#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <objc/runtime.h>
#import "UIView+Toast.h"

@interface AUXBaseViewController ()<QMUINavigationControllerDelegate , QMUINavigationControllerTransitionDelegate>

@end

@implementation AUXBaseViewController

+ (instancetype)instantiateFromStoryboard:(NSString *)storyboardName {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customBackAtcion = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertAccountCacheExpiredMessage) name:AUXAccessTokenDidExpireNotification object:nil];
    
    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    
    if (self.navigationController.viewControllers.count > 1 || [self isKindOfClass:NSClassFromString(@"AUXLoginViewController")] || [self isKindOfClass:NSClassFromString(@"AUXBindAccountViewController")]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_btn_back_black"] style:UIBarButtonItemStyleDone target:self action:@selector(backAtcion)];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    NSString *loadPageName = NSStringFromClass([self class]);
    
    if (loadPageName) {
        [MobClick beginLogPageView:loadPageName];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.navigationController.viewControllers.count > 1 && !self.customBackAtcion) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *loadPageName = NSStringFromClass([self class]);
    
    if (loadPageName) {
        [MobClick endLogPageView:loadPageName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark  设置状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)backAtcion {
    
    if (!self.customBackAtcion) {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)initSubviews {
    
}

- (void)createTitleLabel {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.titleLabel = titleLabel;
    self.navigationItem.titleView = titleLabel;
}

- (void)setTitle:(NSString *)title {
    
    if ([title length] == 0) {
        title = @" ";
    }
    
    if (self.titleLabel) {
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
    }
    
    [super setTitle:title];
}

- (void)setupBackBarButtonItem {
    self.customBackAtcion = YES;
}

#pragma mark - QMUINavigationControllerDelegate
- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (UIImage *)navigationBarBackgroundImage {
    return [UIImage qmui_imageWithColor:[UIColor whiteColor]];
}

- (UIImage *)navigationBarShadowImage {
    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
}

- (UIColor *)navigationBarTintColor {
    return [UIColor blackColor];
}

#pragma mark - Error view

- (void)showErrorViewWithMessage:(NSString *)message {
    
    if (![NSStringFromClass([self class]) isEqual:NSStringFromClass([[self currentViewController] class])]) {
        return ;
    }
                                                                                                     
    if (kAUXApplecation.showingErrorView) {
        return ;
    }
    kAUXApplecation.showingErrorView = YES;
    
    [kAUXWindowView makeToast:message duration:kToastAnimationTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
        kAUXApplecation.showingErrorView = NO;
    }];
}

- (void)showErrorViewWithError:(NSError *)error defaultMessage:(NSString *)defaultMessage {
    NSString *message;
    if (error) {
        message = [AUXNetworkManager getErrorMessageWithCode:error.code];
    }
    
    if (!message && error.userInfo[NSLocalizedDescriptionKey]) {
        message = error.userInfo[NSLocalizedDescriptionKey];
    }
    
    if (!message) {
        message = defaultMessage;
    }
    
    if (message) {
        [self showErrorViewWithMessage:message];
    }
}

#pragma mark 当前显示的页面
- (AUXBaseViewController *)currentViewController {
    UITabBarController *tabBarController = (UITabBarController *)kAUXApplecation.window.rootViewController;
    UINavigationController *navigationController = tabBarController.viewControllers[tabBarController.selectedIndex];
    AUXBaseViewController *baseViewController = navigationController.viewControllers.lastObject;
    
    return baseViewController;
}


#pragma mark 推出登录界面
- (void)alertAccountCacheExpiredMessage {
    [self hideLoadingHUD];
    
    if (kAUXApplecation.showingExpireMessage) {
        return;
    }
    
    kAUXApplecation.showingExpireMessage = YES;
#warning 5.2.0 一定要改为下面的代码
    [kAUXWindowView makeToast:@"请重新登录" duration:kToastAnimationTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
        kAUXApplecation.showingExpireMessage = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
    }];
    
//    [kAUXWindowView makeToast:kAUXLocalizedString(@"AccountCacheExpiredMessage") duration:kToastAnimationTime position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
//
//        kAUXApplecation.showingExpireMessage = NO;
//        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccountCacheDidExpireNotification object:nil];
//    }];
}

- (void)alertWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock {
    
    AUXAlertCustomView *alertView = [AUXAlertCustomView alertViewWithMessage:message confirmAtcion:confirmBlock cancleAtcion:nil];
    alertView.confirmTitle = confirmTitle;
    alertView.onlyShowSureBtn = YES;
    
}

- (void)alertWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(void))cancelBlock {
    
    AUXAlertCustomView *alertView = [AUXAlertCustomView alertViewWithMessage:message confirmAtcion:confirmBlock cancleAtcion:cancelBlock];
    alertView.confirmTitle = confirmTitle;
    alertView.cancleTitle = cancelTitle;
    
}

#pragma mark   短Toast弹框 3s
-(void)showToastshortWitherror:(NSError *)error
{
    NSString *message;
    if (error) {
        message = [AUXNetworkManager getErrorMessageWithCode:error.code];
    }
    if (!message && error.userInfo[NSLocalizedDescriptionKey]) {
        message = error.userInfo[NSLocalizedDescriptionKey];
    }
    if (message) {
        UIApplication *app = [UIApplication sharedApplication];
        [app.keyWindow makeToast:message duration:kToastAnimationTime position:CSToastPositionCenter style:nil];
    }
}

#pragma mark  短Toast弹框 3s 显示在中间
-(void)showToastshortWithmessageinCenter:(NSString *)message
{
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow makeToast:message duration:kToastAnimationTime position:CSToastPositionCenter style:nil];
}

-(BOOL)isopenCamerapermissions
{
    //    iOS 判断应用是否有使用相机的权限
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [self alertWithMessage:@"您关闭了相机权限，是否前往设置中打开相机使用权限?" confirmTitle:@"打开" confirmBlock:^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        } cancelTitle:@"不了" cancelBlock:nil];
        return NO;
    }
    return YES;
}

#pragma mark  设置富文本
-(NSMutableAttributedString *)createAttributeWithTitle:(NSString *)title Font:(CGFloat)font Color:(UIColor *)color range:(NSRange)range
{
    NSMutableAttributedString *atttibuted = [[NSMutableAttributedString alloc]initWithString:title];
    NSDictionary *attributeDictNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont systemFontOfSize:font],NSFontAttributeName,
                                         color,NSForegroundColorAttributeName,nil];
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:font],NSFontAttributeName,
                                   color,NSForegroundColorAttributeName,nil];
    [atttibuted addAttributes:attributeDictNormal range:range];
    [atttibuted addAttributes:attributeDict range:range];
    return atttibuted;
}

- (CGFloat)floatWithtext:(NSString *)text fontsize:(CGFloat)fontsize needsize:(CGSize)needsize {
    UIFont * tfont = [UIFont systemFontOfSize:fontsize];
    CGSize size = needsize;
    //    获取当前文本的属性
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    CGFloat maxFloat = needsize.width;
    if (maxFloat == MAXFLOAT) {
        return actualsize.width;
    }else{
        return actualsize.height;
    }
    
}

@end

@implementation UIViewController (HUD)

const void * AUXViewControllerProgressHUD = &AUXViewControllerProgressHUD;
const void * AUXViewControllerProgressHUDImageView = &AUXViewControllerProgressHUDImageView;

- (void)setProgressHUD:(MBProgressHUD *)progressHUD {
    objc_setAssociatedObject(self, AUXViewControllerProgressHUD, progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)progressHUD {
    return objc_getAssociatedObject(self, AUXViewControllerProgressHUD);
}

- (void)setProgressHUDImageView:(UIImageView *)progressHUDImageView {
    objc_setAssociatedObject(self, AUXViewControllerProgressHUDImageView, progressHUDImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)progressHUDImageView {
    return objc_getAssociatedObject(self, AUXViewControllerProgressHUDImageView);
}

- (MBProgressHUD *)createProgressHUD {

    MBProgressHUD *progressHUD;
    
    progressHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    progressHUD.backgroundView.backgroundColor = [UIColor clearColor];
    progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    progressHUD.bezelView.color = [UIColor blackColor];
    progressHUD.contentColor = [UIColor whiteColor];
//    progressHUD.minSize = CGSizeMake(230, 100);
    progressHUD.removeFromSuperViewOnHide = YES;
    
    return progressHUD;
}

- (void)showSuccess:(NSString *)text {
    [self showSuccess:text completion:nil];
}

- (void)showSuccess:(NSString *)text completion:(void (^)(void))completion {
    self.progressHUDImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_icon_success"]];
    [self showSuccess:text attributedString:nil completion:completion];
}

- (void)showSuccessWithAttributedString:(NSAttributedString *)attributedString {
    [self showSuccessWithAttributedString:attributedString completion:nil];
    
}

- (void)showSuccessWithAttributedString:(NSAttributedString *)attributedString completion:(void (^)(void))completion {
    self.progressHUDImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_icon_success"]];
    [self showSuccess:nil attributedString:attributedString completion:completion];
}

- (void)showFailure:(NSString *)text {
    [self showFailure:text completion:nil];
}

- (void)showFailure:(NSString *)text completion:(void (^)(void))completion {
    self.progressHUDImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_fail"]];
    [self showSuccess:text attributedString:nil completion:completion];
}

- (void)showFailureWithAttributedString:(NSAttributedString *)attributedString {
    [self showFailureWithAttributedString:attributedString completion:nil];
}

- (void)showFailureWithAttributedString:(NSAttributedString *)attributedString completion:(void (^)(void))completion {
    self.progressHUDImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_fail"]];
    [self showSuccess:nil attributedString:attributedString completion:completion];
}

- (void)showSuccess:(NSString *)text attributedString:(NSAttributedString *)attributedString completion:(void (^)(void))completion {
    
    kAUXWindowView.userInteractionEnabled = NO;
    [kAUXWindowView makeToast:text duration:1.0 position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
        kAUXWindowView.userInteractionEnabled = YES;
        if (completion) {
            completion();
        }
    }];
}

- (void)showLoadingHUD {
    MBProgressHUD *loadingHUD = [self createProgressHUD];
    self.progressHUD = loadingHUD;
    
    loadingHUD.mode = MBProgressHUDModeIndeterminate;
    
}

- (void)showLoadingHUDWithText:(NSString *)text {
    
    [kAUXWindowView makeToast:text duration:kToastAnimationTime position:CSToastPositionCenter style:nil];
}

- (void)hideLoadingHUD {
    if (self.progressHUD) {
        [self.progressHUD hideAnimated:YES];
        self.progressHUD = nil;
    }
}

- (BOOL)isopencameraAndphotoalbum{
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        return NO;
    }else{
        return YES;
    }
}

@end


