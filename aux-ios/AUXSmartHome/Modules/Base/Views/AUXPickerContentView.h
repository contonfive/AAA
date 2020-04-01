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

#import "AUXBaseView.h"

/**
 带有确定、取消按钮的 pickerView
 */
@interface AUXPickerContentView : AUXBaseView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *backView;

/// 单位。默认隐藏
@property (weak, nonatomic) IBOutlet UILabel *indicateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indicateLabelLeading;

@property (weak, nonatomic) IBOutlet UILabel *leftUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightUnitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftUnitLabelCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightUnitLabelCenterX;


@end
