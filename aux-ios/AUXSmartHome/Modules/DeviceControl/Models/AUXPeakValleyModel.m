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

#import "AUXPeakValleyModel.h"

@implementation AUXPeakValleyModel

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"addTime", @"peakTimePeriod", @"valleyTimePeriod"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXPeakValleyModel *peakValleyModel = [[AUXPeakValleyModel allocWithZone:zone] init];
    
    [peakValleyModel yy_modelSetWithDictionary:[self yy_modelToJSONObject]];
    peakValleyModel.addTime = self.addTime;
    
    return peakValleyModel;
}

- (void)setDefaultValue {
    self.on = NO;
    
    self.peakStartHour = 9;
    self.peakStartMinute = 0;
    self.peakEndHour = 10;
    self.peakEndMinute = 0;
    
    self.valleyStartHour = 1;
    self.valleyStartMinute = 0;
    self.valleyEndHour = 2;
    self.valleyEndMinute = 0;
}

- (AUXACPeakValleyPower *)convertToSDKPeakValleyPower {
    AUXACPeakValleyPower *peakValleyPower = [[AUXACPeakValleyPower alloc] init];
    
    peakValleyPower.enabled = self.on;
    
    peakValleyPower.peakStartTime = [self timeStringWithHour:self.peakStartHour minute:self.peakStartMinute];
    peakValleyPower.peakEndTime = [self timeStringWithHour:self.peakEndHour minute:self.peakEndMinute];
    peakValleyPower.valleyStartTime = [self timeStringWithHour:self.valleyStartHour minute:self.valleyStartMinute];
    peakValleyPower.valleyEndTime = [self timeStringWithHour:self.valleyEndHour minute:self.valleyEndMinute];
    
    return peakValleyPower;
}

- (NSString *)peakTimePeriod {
    return [NSString stringWithFormat:@"%02d:%02d-%02d:%02d", (int)self.peakStartHour, (int)self.peakStartMinute, (int)self.peakEndHour, (int)self.peakEndMinute];
}

- (NSString *)valleyTimePeriod {
    return [NSString stringWithFormat:@"%02d:%02d-%02d:%02d", (int)self.valleyStartHour, (int)self.valleyStartMinute, (int)self.valleyEndHour, (int)self.valleyEndMinute];
}

- (void)setValueWithSDKPeakValleyPower:(AUXACPeakValleyPower *)peakValleyPower {
    if (!peakValleyPower) {
        return;
    }
    
    self.on = peakValleyPower.enabled;
    self.addTime = peakValleyPower.addTime;
    
    NSInteger hour = 0, minute = 0;
    
    [self getTimeFromTimeString:peakValleyPower.peakStartTime hour:&hour minute:&minute];
    
    self.peakStartHour = hour;
    self.peakStartMinute = minute;
    
    [self getTimeFromTimeString:peakValleyPower.peakEndTime hour:&hour minute:&minute];
    
    self.peakEndHour = hour;
    self.peakEndMinute = minute;
    
    [self getTimeFromTimeString:peakValleyPower.valleyStartTime hour:&hour minute:&minute];
    
    self.valleyStartHour = hour;
    self.valleyStartMinute = minute;
    
    [self getTimeFromTimeString:peakValleyPower.valleyEndTime hour:&hour minute:&minute];
    
    self.valleyEndHour = hour;
    self.valleyEndMinute = minute;
}

- (NSString *)timeStringWithHour:(NSInteger)hour minute:(NSInteger)minute {
    return [NSString stringWithFormat:@"%@:%@", @(hour), @(minute)];
}

- (void)getTimeFromTimeString:(NSString *)timeString hour:(out NSInteger *)hour minute:(out NSInteger *)minute {
    
    if ([timeString containsString:@":"]) {
        
        NSArray<NSString *> *components = [timeString componentsSeparatedByString:@":"];
        
        *hour = components.firstObject.integerValue;
        *minute = components.lastObject.integerValue;
    }
}

@end
