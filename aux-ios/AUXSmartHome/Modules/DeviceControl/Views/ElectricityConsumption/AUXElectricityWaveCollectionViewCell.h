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
 用电曲线 - 波平、波峰、波谷总用电量显示界面 (UI在 DeviceControl.storyboard中)
 */
@interface AUXElectricityWaveCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *indicateView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (nonatomic, assign) NSInteger value;

@property (nonatomic, strong) UIColor *indicateColor;

@end
