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

/**
 设备控制界面 table section header view
 */
@interface AUXDeviceControlHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (class, nonatomic, assign, readonly) CGFloat properHeight;

@property (nonatomic, assign) BOOL showsDisclosureIndicator; // 默认为 NO

@property (nonatomic, copy) void (^tapHeaderViewBlock)(void);

@end
