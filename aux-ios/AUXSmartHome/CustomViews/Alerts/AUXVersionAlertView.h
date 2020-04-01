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

@interface AUXVersionAlertView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (nonatomic, copy) void (^confirmBlock)(void);
@property (nonatomic, copy) void (^cancelBlock)(void);

+ (instancetype)versionAlertViewWithVersion:(NSString*)Version cancelBlock:(void (^)(void))cancelBlock confirmBlock:(void (^)(void))confirmBlock;


@end
