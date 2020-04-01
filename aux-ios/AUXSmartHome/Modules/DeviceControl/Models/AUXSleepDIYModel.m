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

#import "AUXSleepDIYModel.h"
#import "AUXConfiguration.h"

@implementation AUXSleepDIYPointModel

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"hour"];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXSleepDIYPointModel *pointModel = [[[self class] allocWithZone:zone] init];
    
    pointModel.temperature = self.temperature;
    pointModel.windSpeed = self.windSpeed;
    pointModel.hour = self.hour;
    
    return pointModel;
}

- (BOOL)isEqualToSleepDIYPointModel:(AUXSleepDIYPointModel *)sleepDIYPointModel {
    if (self.temperature != sleepDIYPointModel.temperature) {
        return NO;
    }
    
    if (self.windSpeed != sleepDIYPointModel.windSpeed) {
        return NO;
    }
    
    return YES;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end


@implementation AUXSleepDIYModel

#pragma mark - YYModel

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"pointModelList"];
}

- (NSString *)yy_modelToJSONString {
    _electricControl = [self.pointModelList yy_modelToJSONString];
    
    return [super yy_modelToJSONString];
}

- (id)yy_modelToJSONObject {
    _electricControl = [self.pointModelList yy_modelToJSONString];
    
    return [super yy_modelToJSONObject];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXSleepDIYModel *model = [[[self class] allocWithZone:zone] init];
    
    [model yy_modelSetWithJSON:[self yy_modelToJSONString]];
    
    return model;
}

#pragma mark - Setters

- (void)setElectricControl:(NSString *)electricControl {
    _electricControl = electricControl;
    
    if (electricControl && electricControl.length > 0) {
        _pointModelList = [NSArray yy_modelArrayWithClass:[AUXSleepDIYPointModel class] json:electricControl];
    } else {
        _pointModelList = nil;
    }
}

- (void)setPointModelList:(NSArray<AUXSleepDIYPointModel *> *)pointModelList {
    _pointModelList = pointModelList;
    
    if (pointModelList && pointModelList.count > 0) {
        _electricControl = [pointModelList yy_modelToJSONString];
    } else {
        _electricControl = nil;
    }
}

#pragma mark - Public methods

- (NSString *)timePeriod {
    NSInteger endHour = (self.startHour + self.definiteTime) % 24;
    NSInteger endMinute = self.endMinute;
    return [NSString stringWithFormat:@"%02d:%02d-%02d:%02d", (int)self.startHour, (int)self.startMinute, (int)endHour, (int)endMinute];
}

- (NSArray<AUXACSleepDIYPoint *> *)convertToACSleepDIYPointArray {
    NSMutableArray<AUXACSleepDIYPoint *> *acSleepDIYPointArray = [[NSMutableArray alloc] init];
    
    for (AUXSleepDIYPointModel *pointModel in self.pointModelList) {
        
        WindSpeed windSpeed = [AUXConfiguration getSDKWindSpeedWithServerWindSpeed:pointModel.windSpeed];
        
        for (int i = 0; i < 6; i++) {
            AUXACSleepDIYPoint *acSleepDIYPoint = [[AUXACSleepDIYPoint alloc] init];
            acSleepDIYPoint.temperature = pointModel.temperature;
            acSleepDIYPoint.windSpeed = windSpeed;
            [acSleepDIYPointArray addObject:acSleepDIYPoint];
        }
    }
    
    NSLog(@"睡眠DIY App 节点列表: %@", [self.pointModelList yy_modelToJSONString]);
    NSLog(@"睡眠DIY SDK 节点列表: %@", [acSleepDIYPointArray yy_modelToJSONString]);
    
    return acSleepDIYPointArray;
}

- (BOOL)isEqualToACSleepDIYPointArray:(NSArray<AUXACSleepDIYPoint *> *)acSleepDIYPointArray {
    BOOL value = NO;
    
    if (self.pointModelList && acSleepDIYPointArray && self.pointModelList.count * 6 == acSleepDIYPointArray.count) {
        
        NSInteger count = self.pointModelList.count;
        
        value = YES;
        
        for (int i = 0; i < count; i++) {
            AUXSleepDIYPointModel *pointModel = self.pointModelList[i];
            AUXACSleepDIYPoint *acPoint = acSleepDIYPointArray[i * 6];
            
            if (pointModel.temperature != (int)acPoint.temperature) {
                value = NO;
                break;
            }
            
            WindSpeed windSpeed = [AUXConfiguration getSDKWindSpeedWithServerWindSpeed:pointModel.windSpeed];
            
            if (windSpeed != acPoint.windSpeed) {
                value = NO;
                break;
            }
        }
    }
    
    return value;
}

- (BOOL)isEqualToSleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel {
//    if (self.mode != sleepDIYModel.mode) {
//        return NO;
//    }
    
    if (self.windSpeed != sleepDIYModel.windSpeed) {
        return NO;
    }
    
    if (self.startHour != sleepDIYModel.startHour) {
        return NO;
    }
    
    if (self.definiteTime != sleepDIYModel.definiteTime) {
        return NO;
    }
    
    for (int i = 0; i < self.definiteTime; i++) {
        AUXSleepDIYPointModel *pointModel1 = self.pointModelList[i];
        AUXSleepDIYPointModel *pointModel2 = sleepDIYModel.pointModelList[i];
        
        if (![pointModel1 isEqualToSleepDIYPointModel:pointModel2]) {
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
