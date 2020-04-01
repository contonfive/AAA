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

#import "AUXSchedulerModel.h"
#import "AUXConfiguration.h"

@implementation AUXSchedulerModel

#pragma mark - YYModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"schedulerId": @"id",
             @"hour": @"hourSetting",
             @"minute": @"minuteSetting",
             @"temperature": @"temperatureSetting"};
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"repeatValue", @"repeatDescription", @"timeString", @"cycleTimer"];
}

- (NSString *)yy_modelToJSONString {
    _repeatRule = [self convertRepeatValueToRule];
    
    return [super yy_modelToJSONString];
}

- (id)yy_modelToJSONObject {
    _repeatRule = [self convertRepeatValueToRule];
    
    return [super yy_modelToJSONObject];
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

#pragma mark - init

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXSchedulerModel *schedulerModel = [[[self class] allocWithZone:zone] init];
    
    [schedulerModel yy_modelSetWithDictionary:[self yy_modelToJSONObject]];
    
    schedulerModel.repeatValue = self.repeatValue;
    schedulerModel.cycleTimer = self.cycleTimer;
    
    return schedulerModel;
}

#pragma mark - Setters & Getters

- (void)setRepeatRule:(NSString *)repeatRule {
    _repeatRule = repeatRule;
    
    self.repeatValue = 0;
    
    if (repeatRule && repeatRule.length > 0) {
        NSArray *components = [repeatRule componentsSeparatedByString:@","];
        
        for (NSString *weekdayString in components) {
            NSInteger weekday = weekdayString.integerValue;
            
            if (weekday < 1 || weekday > 7) {
                continue;
            }
            
            self.repeatValue |= (1 << (weekday - 1));
        }
    }
}

- (NSString *)repeatDescription {
    NSString *description = @"";
    
    if (self.repeatValue == 0b1111111) {
        description = @"每天";
    } else if (self.repeatValue == 0b0011111) {
        description = @"工作日";
    } else if (self.repeatValue == 0b1100000) {
        description = @"双休日";
    } else if (self.repeatValue == 0b0000000) {
        description = @"不重复";
    } else {
        NSMutableArray<NSString *> *weekdayArray = [@[@"一", @"二", @"三", @"四", @"五", @"六", @"日"] mutableCopy];
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        for (int i = 0; i < weekdayArray.count; i++) {
            
            if ((self.repeatValue & 1 << i) == 0) {
                [indexSet addIndex:i];
            }
        }
        
        [weekdayArray removeObjectsAtIndexes:indexSet];
        if (weekdayArray.count > 0) {
            description = [weekdayArray componentsJoinedByString:@" "];
            description = [@"周" stringByAppendingString:description];
        }
    }
    
    return description;
}

- (NSString *)timeString {
    return [NSString stringWithFormat:@"%02d:%02d", (int)self.hour, (int)self.minute];
}

#pragma mark - 转换方法

- (NSString *)convertRepeatValueToRule {
    NSMutableArray<NSString *> *weekdayArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; i++) {
        if ((self.repeatValue & (1 << i)) == 0) {
            continue;
        }
        
        NSString *weekdayString = [NSString stringWithFormat:@"%d", (i+1)];
        [weekdayArray addObject:weekdayString];
    }
    
    NSString *repeatRule = @"";
    
    if (weekdayArray.count > 0) {
        repeatRule = [weekdayArray componentsJoinedByString:@","];
    }
    
    return repeatRule;
}

- (AUXACBroadlinkCycleTimer *)convertToSDKCycleTimer {
    AUXACBroadlinkCycleTimer *cycleTimer = [[AUXACBroadlinkCycleTimer alloc] init];
    
    self.cycleTimer = cycleTimer;
    [self updateCycleTimer];
    
    return cycleTimer;
}

- (AUXACControl *)getControlWithGearType:(WindGearType)gearType currentControl:(AUXACControl *)currentControl {
    AUXACControl *control = [currentControl copy];
    
    switch (self.cycleTimer.windSpeed) {
        case WindSpeedTurbo:
            control.turbo = YES;
            control.silence = NO;
            break;
            
        case WindSpeedSilence:
            control.turbo = NO;
            control.silence = YES;
            break;
            
        default:
            control.turbo = NO;
            control.silence = NO;
            [control setWindSpeed:self.cycleTimer.windSpeed WithType:gearType];
            break;
    }
    
    control.half = NO;
    control.onOff = self.cycleTimer.onOff;
    control.acTimer = 0;
    
    // 定时关机时，需要将模式设置为当前设备的模式
    if (self.cycleTimer.onOff) {
        control.airConFunc = self.cycleTimer.airConFunc;
        control.temperature = self.cycleTimer.temperature;
    } else {
        control.airConFunc = currentControl.airConFunc;
        control.temperature = currentControl.temperature;
    }
    
    return control;
}

- (void)setValueWithSDKCycleTimer:(AUXACBroadlinkCycleTimer *)cycleTimer {
    self.on = cycleTimer.enabled;
    self.deviceOperate = cycleTimer.onOff;
    self.temperature = cycleTimer.temperature;
    self.mode = [AUXConfiguration getServerModeWithSDKMode:cycleTimer.airConFunc];
    self.windSpeed = [AUXConfiguration getServerWindSpeedWithSDKWindSpeed:cycleTimer.windSpeed];
    self.hour = cycleTimer.hour;
    self.minute = cycleTimer.minute;
    
    NSMutableArray <NSNumber *> *weekArray = [NSArray arrayWithArray:cycleTimer.week].reverseObjectEnumerator.allObjects.mutableCopy;
    
    NSInteger value = 0b0000000;
    for (int i = 0 ; i < weekArray.count; i++) {
        NSNumber *number = weekArray[i];
        if (number.integerValue == 0) {
            number = @(7);
        }
        value |= 1 << (number.integerValue - 1);
    }
    self.repeatValue = value;
    self.schedulerId = [NSString stringWithFormat:@"%@", @(cycleTimer.index)];
}

- (void)updateCycleTimer {
    self.cycleTimer.enabled = self.on;
    self.cycleTimer.onOff = self.deviceOperate;
    self.cycleTimer.temperature = self.temperature;
    self.cycleTimer.airConFunc = [AUXConfiguration getSDKModeWithServerMode:self.mode];;
    self.cycleTimer.windSpeed = [AUXConfiguration getSDKWindSpeedWithServerWindSpeed:self.windSpeed];;
    self.cycleTimer.hour = self.hour;
    self.cycleTimer.minute = self.minute;
    
    NSInteger week = 0;
    NSMutableArray *weekArray = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        
        if (self.repeatValue & (1 << i)) {
            week = i + 1;
            if (week == 7) {
                week = 0;
            }
            [weekArray addObject:@(week)];
        }
    }
    
    
    self.cycleTimer.week = weekArray;
}

+ (NSMutableArray<AUXSchedulerModel *> *)schedulerListFromSDKCycleTimerList:(NSArray<AUXACBroadlinkCycleTimer *> *)cycleTimerList {
    NSMutableArray<AUXSchedulerModel *> *schedulerList = [[NSMutableArray alloc] init];
    
    for (AUXACBroadlinkCycleTimer *cycleTimer in cycleTimerList) {
        
        AUXSchedulerModel *schedulerModel = [[AUXSchedulerModel alloc] init];
        
        [schedulerModel setValueWithSDKCycleTimer:cycleTimer];
        schedulerModel.cycleTimer = cycleTimer;
        
        [schedulerList addObject:schedulerModel];
    }
    
    return schedulerList;
}

@end
