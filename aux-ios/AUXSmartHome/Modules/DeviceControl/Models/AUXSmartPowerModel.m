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

#import "AUXSmartPowerModel.h"

@implementation AUXSmartPowerModel

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"addTime", @"timePeriod"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXSmartPowerModel *smartPowerModel = [[AUXSmartPowerModel allocWithZone:zone] init];
    
    [smartPowerModel yy_modelSetWithDictionary:[self yy_modelToJSONObject]];
    smartPowerModel.addTime = self.addTime;
    
    return smartPowerModel;
}

- (void)setDefaultValue {
    self.on = NO;
    self.startHour = 0;
    self.startMinute = 0;
    self.endHour = 0;
    self.endMinute = 0;
    self.totalElec = 0;
    self.mode = AUXSmartPowerModeFast;
    self.executeCycle = AUXSmartPowerCycleOnce;
}

- (AUXACSmartPower *)convertToSDKSmartPower {
    AUXACSmartPower *smartPower = [[AUXACSmartPower alloc] init];
    
    smartPower.mode = [self getSDKSmartPowerModeWithMode:self.mode];
    smartPower.quantity = (int)self.totalElec;
    smartPower.enabled = self.on;
    
    smartPower.startTime = [self timeStringWithHour:self.startHour minute:self.startMinute];
    smartPower.endTime = [self timeStringWithHour:self.endHour minute:self.endMinute];
    
    return smartPower;
}

- (void)setValueWithSDKSmartPower:(AUXACSmartPower *)smartPower {
    if (!smartPower) {
        return;
    }
    
    self.mode = [self getSmartPowerModeWithSDKMode:smartPower.mode];
    self.totalElec = smartPower.quantity;
    self.on = smartPower.enabled;
    
    NSInteger hour = 0, minute = 0;
    
    [self getTimeFromTimeString:smartPower.startTime hour:&hour minute:&minute];
    
    self.startHour = hour;
    self.startMinute = minute;
    
    [self getTimeFromTimeString:smartPower.endTime hour:&hour minute:&minute];
    
    self.endHour = hour;
    self.endMinute = minute;
}

- (SmartPowerMode)getSDKSmartPowerModeWithMode:(AUXSmartPowerMode)mode {
    SmartPowerMode sdkMode;
    
    switch (mode) {
        case AUXSmartPowerModeFast:
            sdkMode = SmartPowerModeQuick;
            break;
            
        case AUXSmartPowerModeBalance:
            sdkMode = SmartPowerModeBalance;
            break;
            
        default:
            sdkMode = SmartPowerModeEconomize;
            break;
    }
    
    return sdkMode;
}

- (AUXSmartPowerMode)getSmartPowerModeWithSDKMode:(SmartPowerMode)sdkMode {
    AUXSmartPowerMode mode;
    
    switch (sdkMode) {
        case SmartPowerModeQuick:
            mode = AUXSmartPowerModeFast;
            break;
            
        case SmartPowerModeBalance:
            mode = AUXSmartPowerModeBalance;
            break;
            
        default:
            mode = AUXSmartPowerModeStandard;
            break;
    }
    
    return mode;
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

- (NSString *)timePeriod {
    return [NSString stringWithFormat:@"%02d:%02d-%02d:%02d", (int)self.startHour, (int)self.startMinute, (int)self.endHour, (int)self.endMinute];
}

@end
