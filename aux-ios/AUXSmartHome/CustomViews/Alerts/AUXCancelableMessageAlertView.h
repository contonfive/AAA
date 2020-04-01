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

#import "AUXButton.h"

/**
 一个取消按钮、一个确认按钮的消息弹窗
 */
@interface AUXCancelableMessageAlertView : UIView

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet AUXButton *confirmButton;
@property (weak, nonatomic) IBOutlet AUXButton *cancelButton;

@property (nonatomic, copy) void (^confirmBlock)(void);
@property (nonatomic, copy) void (^cancelBlock)(void);

/**
 创建消息弹窗

 @param message 信息
 @param cancelTitle 取消按钮的title
 @param cancelBlock 点击取消按钮时调用的block
 @param confirmTitle 确认按钮的title
 @param confirmBlock 点击确认按钮时调用的block
 @return AUXCancelableMessageAlertView
 */
+ (instancetype)messageAlertViewWithMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(void))cancelBlock confirmTitle:(NSString *)confirmTitle confirmBlock:(void (^)(void))confirmBlock;

@end
