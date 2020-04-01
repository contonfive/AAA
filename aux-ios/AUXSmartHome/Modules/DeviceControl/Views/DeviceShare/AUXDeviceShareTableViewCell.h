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

#import "AUXBaseTableViewCell.h"
#import "AUXUserCenterDeviceSharePersonViewController.h"
#import "AUXDeviceShareListViewController.h"
#import "AUXButton.h"

/**
 设备分享子用户列表 cell
 */
@interface AUXDeviceShareTableViewCell : AUXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet AUXButton *relieveButton;  // 解除分享
@property (weak, nonatomic) IBOutlet UIImageView *relieveIcon;

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *delectImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleLabelTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleLabelTriling;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *relieveBtnCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titlabelCenterY;

@property (nonatomic,assign) AUXDeviceShareType type;

@property (nonatomic,assign) BOOL showIndicatorImageView;
@property (nonatomic,assign) BOOL showIconImageView;

@property (nonatomic,assign) NSTimeInterval expiredTimerInterval;
@property (nonatomic,strong) AUXUserCenterDeviceSharePersonViewController *viewController;
@property (nonatomic,strong) AUXDeviceShareListViewController *deviceShareViewController;
@property (copy, nonatomic) NSIndexPath *indexPath;

/// 点击解除分享按钮的回调block
@property (nonatomic, copy) void (^relieveBlock)(void);

@end
