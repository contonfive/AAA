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

static NSInteger const kAUXPopupMenuButtonTag = 100;

typedef void (^AUXPopupMenuSelectBlock)(NSInteger index);

/**
 导航栏右边按钮弹出的菜单界面
 */
@interface AUXPopupMenuViewController : AUXBaseViewController

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIImageView *menuBackgroundImageView;

/**
 菜单 button 集合。(请在 storyboard 中建立关联)
 
 @note button.tag 必需从 100 开始，按顺序递增。
 */
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButtonCollection;

@property (nonatomic, copy) AUXPopupMenuSelectBlock menuSelectBlock;

/**
 子类重写手势方法

 @param sender sender
 */
- (void)actionTapToDismiss:(UIGestureRecognizer *)sender;

@end
