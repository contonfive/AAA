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

#import "AUXSchedulerTemperatureTableViewCell.h"

#import "AUXDefinitions.h"

@interface AUXSchedulerTemperatureTableViewCell ()

@property (nonatomic, strong) UITapGestureRecognizer *sliderTapGesture;

@end

@implementation AUXSchedulerTemperatureTableViewCell

+ (CGFloat)properHeight {
    return 100;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"device_btn_slide_small"] forState:UIControlStateNormal];
    self.sliderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapSlider:)];
    [self.sliderContentView addGestureRecognizer:self.sliderTapGesture];
}

- (void)setTemperature:(CGFloat)temperature {
    _temperature = temperature;
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°C", (int)temperature];
    
    CGFloat value = (temperature - kAUXTemperatureMin) / (kAUXTemperatureMax - kAUXTemperatureMin);
    self.slider.value = value;
}

// 滑动 slider 调节温度
- (IBAction)actionTemperatureSliderValueChanged:(id)sender {
    
    if (self.sliderTapGesture.enabled) {
        self.sliderTapGesture.enabled = NO;
    }
    
    CGFloat value = self.slider.value;
    
    CGFloat temperature = kAUXTemperatureMin + (kAUXTemperatureMax - kAUXTemperatureMin) * value;
    
    temperature = AUXAdjustFloatValue(temperature, 1.0);
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°C", (int)temperature];
    
    // 滑动结束
    if (!self.slider.isTracking) {
        
        self.sliderTapGesture.enabled = YES;
        
        if (_temperature == temperature) {
            return;
        }
        
        _temperature = temperature;
        
        if (self.didChangeTemperatureBlock) {
            self.didChangeTemperatureBlock(temperature);
        }
    }
}

// 点击 slider 调节温度
- (void)actionTapSlider:(UIGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        CGPoint point = [sender locationInView:self.sliderContentView];
        
        CGFloat minX = CGRectGetMinX(self.slider.frame);
        CGFloat maxX = CGRectGetMaxX(self.slider.frame);
        
        if (point.x < minX - 10 || point.x > maxX + 10) {
            return;
        }
        
        CGFloat width = CGRectGetWidth(self.slider.frame);
        CGFloat value = (point.x - minX) / width;
        if (value < 0) {
            value = 0;
        } else if (value > 1.0) {
            value = 1.0;
        }
        
        [self.slider setValue:value animated:YES];
        
        CGFloat temperature = kAUXTemperatureMin + (kAUXTemperatureMax - kAUXTemperatureMin) * value;
        
        temperature = AUXAdjustFloatValue(temperature, 1.0);
        
        self.temperatureLabel.text = [NSString stringWithFormat:@"%d°C", (int)temperature];
        
        _temperature = temperature;
        
        if (self.didChangeTemperatureBlock) {
            self.didChangeTemperatureBlock(temperature);
        }
    }
}

@end
