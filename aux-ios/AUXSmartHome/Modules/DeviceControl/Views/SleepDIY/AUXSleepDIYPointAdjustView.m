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

#import "AUXSleepDIYPointAdjustView.h"

#import "AUXConfiguration.h"

#import "UIColor+AUXCustom.h"

@interface AUXSleepDIYPointAdjustView ()

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@property (weak, nonatomic) IBOutlet UIButton *temperatureDecreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *temperatureIncreaseButton;

@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UIButton *windSpeedDecreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *windSpeedIncreaseButton;

@property (nonatomic, assign) CGFloat temperatureStep;
@end

@implementation AUXSleepDIYPointAdjustView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.halfTemperature = NO;
    
    self.temperature = 27.0;
    self.windSpeed = AUXServerWindSpeedAuto;
    
}

#pragma mark - Getters & Setters

- (void)setHalfTemperature:(BOOL)halfTemperature {
    _halfTemperature = halfTemperature;
    
    self.temperatureStep = halfTemperature ? 0.5 : 1.0;
}

- (void)setTemperature:(CGFloat)temperature {
    _temperature = temperature;
    
    if (self.halfTemperature) {
        self.temperatureLabel.text = [NSString stringWithFormat:@"%.1f°C", (float)temperature];
    } else {
        self.temperatureLabel.text = [NSString stringWithFormat:@"%d°C", (int)temperature];
    }
}

- (void)setWindSpeed:(AUXServerWindSpeed)windSpeed {
    _windSpeed = windSpeed;
    
    self.windSpeedLabel.text = [AUXConfiguration getServerWindSpeedName:windSpeed];
}

#pragma mark - Actions

- (IBAction)actionDecreaseTemperature:(id)sender {
    if (self.temperature > kAUXTemperatureMin) {
        self.temperature -= self.temperatureStep;
        
        if (self.temperatureChangedBlock) {
            self.temperatureChangedBlock(self.temperature);
        }
    }
}

- (IBAction)actionIncreaseTemperature:(id)sender {
    if (self.temperature < kAUXTemperatureMax) {
        self.temperature += self.temperatureStep;
        
        if (self.temperatureChangedBlock) {
            self.temperatureChangedBlock(self.temperature);
        }
    }
}

- (IBAction)actionDecreaseWindSpeed:(id)sender {
    
    NSInteger index = [self.windSpeedArray indexOfObject:@(self.windSpeed)];
    
    if (index == 0) {
        index = self.windSpeedArray.count - 1;
    } else {
        index -= 1;
    }
    
    self.windSpeed = (AUXServerWindSpeed)[self.windSpeedArray[index] integerValue];
    
    if (self.windSpeedChangedBlock) {
        self.windSpeedChangedBlock(self.windSpeed);
    }
}

- (IBAction)actionIncreaseWindSpeed:(id)sender {
    NSInteger index = [self.windSpeedArray indexOfObject:@(self.windSpeed)];
    
    if (index == self.windSpeedArray.count - 1) {
        index = 0;
    } else {
        index += 1;
    }
    
    self.windSpeed = (AUXServerWindSpeed)[self.windSpeedArray[index] integerValue];
    
    if (self.windSpeedChangedBlock) {
        self.windSpeedChangedBlock(self.windSpeed);
    }
}

@end
