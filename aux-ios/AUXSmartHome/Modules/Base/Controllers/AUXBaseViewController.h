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

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "RACEXTScope.h"
#import "AUXDefinitions.h"
#import "AUXConstant.h"

@interface AUXBaseViewController : UIViewController

@property (nonatomic, assign) BOOL viewDidLayout;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic,assign) BOOL customBackAtcion;

/**
 正在显示账号过期弹框
 */
@property (nonatomic, assign) BOOL showingExpireMessageAlert;

/**
 用给定的 stroyboard 实例化 ViewController
 
 @param storyboardName stroyboard name
 @return ViewController
 @note ViewController 在 stroyboard 中的 identifier 需要和类名一致
 */
+ (instancetype)instantiateFromStoryboard:(NSString *)storyboardName;

/**
 subclass 可以重载该方法，写一些初始化界面的操作。该方法在 viewDidLoad 中调用
 */
- (void)initSubviews;

/**
 调用该方法会把自定义模态出控制器的lefrItem
 */
- (void)setupBackBarButtonItem;

/**
 自定义nav backItem 的返回事件
 */
- (void)backAtcion;

/**
 调用该方法后，会创建一个 titleLabel。
 @discussion navigationBar 的 title color 为白色，为了避免修改掉这个颜色，就创建一个titleView 给少数的几个界面设置自定义的 title color。
 */
- (void)createTitleLabel;

/**
 显示错误提示
 
 @param message 错误信息
 */
- (void)showErrorViewWithMessage:(NSString *)message;

/**
 显示错误提示
 
 @param error 错误
 @param defaultMessage 错误码未匹配时，显示的信息
 */
- (void)showErrorViewWithError:(NSError *)error defaultMessage:(NSString *)defaultMessage;

/**
 隐藏错误提示
 */
- (void)hideErrorView;

/**
 用户账号缓存已过期
 */
- (void)alertAccountCacheExpiredMessage;

/**
 弹出信息提示 (有且只有一个按钮)
 
 @param message 信息
 @param confirmTitle 按钮标题
 @param confirmBlock 按钮点击时回调的block
 */
- (void)alertWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock;

/**
 弹出信息提示 (有两个按钮)
 
 @param message 信息
 @param confirmTitle 【确定】按钮的标题
 @param confirmBlock 确定】按钮点击时回调的block
 @param cancelTitle 【取消】按钮的标题
 @param cancelBlock 【取消】按钮点击时回调的block
 */
- (void)alertWithMessage:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(void))cancelBlock;

/**
 短Toast弹框 3s 显示在中间
 
 @param message 提示信息
 */
-(void)showToastshortWithmessageinCenter:(NSString *)message;


/**
 短Toast弹框 3s
 
 @param error 后台返回的错误信息
 */
-(void)showToastshortWitherror:(NSError *)error;


/**
 打开相机权限
 
 @return 返回结果
 */
-(BOOL)isopenCamerapermissions;

/**
 设置富文本
 
 @param title label的text
 @param font 字体
 @param color 颜色
 @param range 位置和长度
 @return 返回富文本
 */
-(NSMutableAttributedString *)createAttributeWithTitle:(NSString *)title Font:(CGFloat)font Color:(UIColor *)color range:(NSRange)range;


/**
 编辑场景名称
 
 @param cancelBlock 取消
 @param confirmBlock 确定
 */
- (void)editSceneNameAlertViewcancelBlock:(void (^)(void))cancelBlock confirmBlock:(void (^)(NSString*name))confirmBlock;

/**
 根据字符串长度 固定高度或宽度返回宽度或h高度
 
 @param text 字符串长度
 @param fontsize 字体大小
 @param needsize 需要的size
 @return 返回宽度或高度
 */
- (CGFloat)floatWithtext:(NSString *)text fontsize:(CGFloat)fontsize needsize:(CGSize)needsize;

@end


@interface UIViewController (HUD)

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic,strong) UIImageView *progressHUDImageView;

/**
 操作成功文本弹窗提示
 
 @param text 文本信息
 */
- (void)showSuccess:(NSString *)text;

/**
 操作成功文本弹窗提示
 
 @param text 文本信息
 @param completion 弹窗消失时的回调block
 */
- (void)showSuccess:(NSString *)text completion:(void (^)(void))completion;

/**
 操作成功文本弹窗提示
 
 @param attributedString 属性文本
 */
- (void)showSuccessWithAttributedString:(NSAttributedString *)attributedString;

/**
 操作成功文本弹窗提示
 
 @param attributedString 属性文本
 @param completion 弹窗消失时的回调block
 */
- (void)showSuccessWithAttributedString:(NSAttributedString *)attributedString completion:(void (^)(void))completion;

/**
 操作失败文本弹窗提示
 
 @param text 文本信息
 */
- (void)showFailure:(NSString *)text;

/**
 操作失败文本弹窗提示
 
 @param text 文本信息
 @param completion 弹窗消失时的回调block
 */
- (void)showFailure:(NSString *)text completion:(void (^)(void))completion;

/**
 操作失败文本弹窗提示
 
 @param attributedString 属性文本
 */
- (void)showFailureWithAttributedString:(NSAttributedString *)attributedString;

/**
 操作失败文本弹窗提示
 
 @param attributedString 属性文本
 @param completion 弹窗消失时的回调block
 */
- (void)showFailureWithAttributedString:(NSAttributedString *)attributedString completion:(void (^)(void))completion;

/**
 loading 弹窗
 */
- (void)showLoadingHUD;

/**
 loading 弹窗
 
 @param text 文本信息
 */
- (void)showLoadingHUDWithText:(NSString *)text;

/**
 隐藏 loading
 */
- (void)hideLoadingHUD;

//判断相册相机权限
- (BOOL)isopencameraAndphotoalbum;

@end

