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

@interface AUXSchedulerTemperatureTableViewCell : AUXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIView *sliderContentView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (weak, nonatomic) IBOutlet UILabel *minLabel;

@property (weak, nonatomic) IBOutlet UILabel *maxLabel;

@property (nonatomic, assign) CGFloat temperature;

@property (nonatomic, copy) void (^didChangeTemperatureBlock)(CGFloat temperature);

@end
