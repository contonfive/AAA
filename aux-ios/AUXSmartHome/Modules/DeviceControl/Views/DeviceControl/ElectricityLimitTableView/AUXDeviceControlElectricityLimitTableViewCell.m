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

#import "AUXDeviceControlElectricityLimitTableViewCell.h"

@interface AUXDeviceControlElectricityLimitTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backContentView;
@property (weak, nonatomic) IBOutlet UIView *percentageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *persentageViewWidth;


@property (nonatomic, assign) NSInteger minPercentage;
@property (nonatomic, assign) NSInteger maxPercentage;

@end

@implementation AUXDeviceControlElectricityLimitTableViewCell

+ (CGFloat)properHeight {
    return 58.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backContentView.layer.masksToBounds = YES;
    self.percentageView.layer.masksToBounds = YES;
    self.backContentView.layer.cornerRadius = 4;
    self.percentageView.layer.cornerRadius = 4;
    
    self.minPercentage = kAUXElectricityLimitPercentageMin;
    self.maxPercentage = kAUXElectricityLimitPercentageMax;
    
    _percentage = self.minPercentage;
    self.percentageLabel.text = [NSString stringWithFormat:@"%@%%", @(_percentage)];
    self.leftImageView.highlighted = YES;
}

- (void)setPercentage:(NSInteger)percentage {
    if (percentage < self.minPercentage) {
        percentage = self.minPercentage;
    } else if (percentage > self.maxPercentage) {
        percentage = self.maxPercentage;
    }
    
    self.leftImageView.highlighted = YES;
    self.rightImageView.highlighted = (percentage == self.maxPercentage);
    
    _percentage = percentage;
    self.percentageLabel.text = [NSString stringWithFormat:@"%@%%", @(percentage)];
    
    CGFloat value = (self.percentage - self.minPercentage) / (CGFloat)(self.maxPercentage - self.minPercentage);
    
    CGFloat width = value * self.backContentView.frame.size.width;
    self.persentageViewWidth.constant = width;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutIfNeeded];
    });
    
}


@end
