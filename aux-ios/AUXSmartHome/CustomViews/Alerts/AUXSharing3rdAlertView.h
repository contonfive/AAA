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

@interface AUXSharing3rdAlertView : UIView

@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, copy) void (^weChatBlock)(void);
@property (nonatomic, copy) void (^qqBlock)(void);

+ (instancetype)sharing3rdAlertViewWithCancelBlock:(void (^)(void))ignoreBlock weChatBlock:(void (^)(void))weChatBlock qqBlock:(void (^)(void))qqBlock;

- (void)weChatAction;

- (void)qqAction;

@end
