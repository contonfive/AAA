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

#import "AUXElectricityConsumptionCurveModel.h"

#import "NSDate+AUXCustom.h"

/// 用电曲线时间段 (波平、波峰、波谷时段)
typedef struct {
    NSInteger startHour;
    NSInteger endHour;
    AUXElectricityCurveWaveType waveType;
} AUXECCurveTimePeriod;

AUXECCurveTimePeriod AUXECCurveTimePeriodMake(NSInteger startHour, NSInteger endHour) {
    AUXECCurveTimePeriod timePeriod;
    timePeriod.startHour = startHour;
    timePeriod.endHour = endHour;
    return timePeriod;
}

const AUXECCurveTimePeriod AUXECCurveTimePeriodZero = {0};

BOOL AUXECCurveTimePeriodIsNull(AUXECCurveTimePeriod timePeriod) {
    BOOL value = NO;
    
    if (timePeriod.startHour == 0 && timePeriod.endHour == 0) {
        value = YES;
    }
    
    return value;
}

@interface NSValue (AUXECExtension)

@property (nonatomic, assign, readonly) AUXECCurveTimePeriod timePeriod;

+ (NSValue *)valueWithTimePeriod:(AUXECCurveTimePeriod)timePeriod;

@end

@implementation NSValue (AUXECExtension)

+ (NSValue *)valueWithTimePeriod:(AUXECCurveTimePeriod)timePeriod {
    NSValue *value = [NSValue value:&timePeriod withObjCType:@encode(AUXECCurveTimePeriod)];
    return value;
}

- (AUXECCurveTimePeriod)timePeriod {
    AUXECCurveTimePeriod timePeriod;
    [self getValue:&timePeriod];
    return timePeriod;
}

@end


@implementation AUXECPowerCurveData

@end


@interface AUXElectricityConsumptionCurveModel ()

@end

@implementation AUXElectricityConsumptionCurveModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"powerCurveDatas": [AUXECPowerCurveData class]};
}

- (NSMutableArray<NSValue *> *)timePeriodArray {
    if (!_timePeriodArray) {
        _timePeriodArray = [[NSMutableArray alloc] init];
    }
    
    return _timePeriodArray;
}

- (void)setCurrentDateWithComponents:(NSDateComponents *)dateComponents {
    self.currentYear = dateComponents.year;
    self.currentMonth = dateComponents.month;
    self.currentDay = dateComponents.day;
    self.currentHour = dateComponents.hour;
}

- (void)setRequestDateWithComponents:(NSDateComponents *)dateComponents {
    self.year = dateComponents.year;
    self.month = dateComponents.month;
    self.day = dateComponents.day;
    self.hour = dateComponents.hour;
}

- (void)updatePowerCurveDatasWithModel:(AUXElectricityConsumptionCurveModel *)curveModel {
    self.powerCurveDatas = curveModel.powerCurveDatas;
    
    self.timeBucket = curveModel.timeBucket;
    
    self.sumWaveFlatElectricity = curveModel.sumWaveFlatElectricity;
    self.sumPeakElectricity = curveModel.sumPeakElectricity;
    self.sumValleyElectricity = curveModel.sumValleyElectricity;
    self.total = curveModel.total;
}

- (AUXECCurveTimePeriod)getTimePeriodFromTime:(NSString *)time waveType:(AUXElectricityCurveWaveType)waveType {
    AUXECCurveTimePeriod timePeriod;
    
    NSArray *components = [time componentsSeparatedByString:@","];
    
    timePeriod.startHour = [components.firstObject integerValue];
    timePeriod.endHour = [components.lastObject integerValue] - 1;
    timePeriod.waveType = waveType;
    
    return timePeriod;
}

- (NSArray<NSValue *> *)getTimePeriodsFromTime:(NSString *)time waveType:(AUXElectricityCurveWaveType)waveType {
    NSMutableArray<NSValue *> *timePeriodArray = [[NSMutableArray alloc] init];;
    
    if ([time containsString:@"_"]) {
        NSArray *components = [time componentsSeparatedByString:@"_"];
        
        AUXECCurveTimePeriod timePeriod1 = [self getTimePeriodFromTime:components.firstObject waveType:waveType];
        AUXECCurveTimePeriod timePeriod2 = [self getTimePeriodFromTime:components.lastObject waveType:waveType];
        
        if (!AUXECCurveTimePeriodIsNull(timePeriod1)) {
            NSValue *value = [NSValue valueWithTimePeriod:timePeriod1];
            [timePeriodArray addObject:value];
        }
        
        if (!AUXECCurveTimePeriodIsNull(timePeriod2)) {
            NSValue *value = [NSValue valueWithTimePeriod:timePeriod2];
            [timePeriodArray addObject:value];
        }
    } else {
        AUXECCurveTimePeriod timePeriod = [self getTimePeriodFromTime:time waveType:waveType];
        
        if (!AUXECCurveTimePeriodIsNull(timePeriod)) {
            NSValue *value = [NSValue valueWithTimePeriod:timePeriod];
            [timePeriodArray addObject:value];
        }
    }
    
    return timePeriodArray;
}

/// 解析波峰波谷时间段
- (void)analyseTimeBucket {
    [self.timePeriodArray removeAllObjects];
    
    if (self.timeBucket.length == 0) {
        return;
    }
    
    /**
     // 波峰波谷时间段，格式：num1,num2_num3,num4|num5,num6 日用电曲线需用到
     // 如：10,15|0,4_20,23 表示波峰时段为 10~15，波谷时段为 0~4、20~23 (波谷时段跨天)
     @property (nonatomic, strong) NSString *timeBucket;
     */
    NSArray *components = [self.timeBucket componentsSeparatedByString:@"|"];
    
    // 波峰或波谷时段，其中一个有可能跨天，一天内有两个波峰或波谷时间段
    // 波峰时段
    NSArray<NSValue *> *peakTimePeriodArray = [self getTimePeriodsFromTime:components.firstObject waveType:AUXElectricityCurveWaveTypePeak];
    if (peakTimePeriodArray && peakTimePeriodArray.count > 0) {
        [self.timePeriodArray addObjectsFromArray:peakTimePeriodArray];
    }
    
    // 波谷时段
    NSArray<NSValue *> *valleyTimePeriodArray = [self getTimePeriodsFromTime:components.lastObject waveType:AUXElectricityCurveWaveTypeValley];
    if (valleyTimePeriodArray && valleyTimePeriodArray.count > 0) {
        [self.timePeriodArray addObjectsFromArray:valleyTimePeriodArray];
    }
    
    NSInteger count = self.timePeriodArray.count;
    
    if (count > 0) {
        // 时间段按开始时间从小到大排序
        [self.timePeriodArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSValue *value1 = (NSValue *)obj1;
            NSValue *value2 = (NSValue *)obj2;
            
            AUXECCurveTimePeriod timePeriod1 = value1.timePeriod;
            AUXECCurveTimePeriod timePeriod2 = value2.timePeriod;
            
            NSComparisonResult result = timePeriod1.startHour < timePeriod2.startHour ? NSOrderedAscending : NSOrderedDescending;
            return result;
        }];
        
        // 将空缺的时段填充为波平时段
        NSInteger hour = 0;
        
        for (NSInteger i = 0; i < count; i++) {
            NSValue *value = self.timePeriodArray[i];
            AUXECCurveTimePeriod timePeriod = value.timePeriod;
            
            if (timePeriod.startHour == hour) {
                hour = timePeriod.endHour + 1;
                continue;
            }
            
            AUXECCurveTimePeriod normalTimePeriod = AUXECCurveTimePeriodMake(hour, timePeriod.startHour - 1);
            normalTimePeriod.waveType = AUXElectricityCurveWaveTypeNormal;
            
            NSValue *normalValue = [NSValue valueWithTimePeriod:normalTimePeriod];
            if (normalValue !=nil) {
                [self.timePeriodArray insertObject:normalValue atIndex:i];
            }
            
            hour = timePeriod.endHour + 1;
            count += 1;
            i += 1;
        }
        
        if (hour < 24) {
            AUXECCurveTimePeriod normalTimePeriod = AUXECCurveTimePeriodMake(hour, 23);
            normalTimePeriod.waveType = AUXElectricityCurveWaveTypeNormal;
            
            NSValue *normalValue = [NSValue valueWithTimePeriod:normalTimePeriod];
            [self.timePeriodArray addObject:normalValue];
        }
    }
}

/// 服务器返回的日、月、年用电曲线，不是每小时、每日、每月都有，将漏掉的数据补上。
- (void)fillPowerCurveDatas {
    NSInteger maxCount;
    NSInteger (^indexConvertor)(NSInteger index);
    
    switch (self.dateType) {
        case AUXElectricityCurveDateTypeDay: {
            maxCount = 24;
            indexConvertor = ^(NSInteger index) {
                return index;
            };
        }
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            maxCount = [NSDate numberOfDaysInMonth:self.month forYear:self.year];
            indexConvertor = ^(NSInteger index) {
                return index + 1;
            };
            break;
            
        default:
            maxCount = 12;
            indexConvertor = ^(NSInteger index) {
                return index + 1;
            };
            break;
    }
    
    self.powerCurveDatas = [self.powerCurveDatas sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AUXECPowerCurveData *data1 = (AUXECPowerCurveData *)obj1;
        AUXECPowerCurveData *data2 = (AUXECPowerCurveData *)obj2;
        
        NSComparisonResult result = data1.timeShaft > data2.timeShaft ? NSOrderedDescending : NSOrderedAscending;
        return result;
    }];
    
    // 无需填充
    if (self.powerCurveDatas.count == maxCount) {
        return;
    }
    
    NSMutableArray<AUXECPowerCurveData *> *powerCurveDatas = [[NSMutableArray alloc] initWithArray:self.powerCurveDatas];
    
    for (NSInteger index = 0; index < maxCount; index++) {
        
        if (index < powerCurveDatas.count) {
            AUXECPowerCurveData *curveData = powerCurveDatas[index];
            
            if (curveData.timeShaft == indexConvertor(index)) {
                continue;
            }
        }
        
        // 该 index 没有数据，填充一个数据
        AUXECPowerCurveData *anotherCurveData = [[AUXECPowerCurveData alloc] init];
        anotherCurveData.waveFlatElectricity = 0;
        anotherCurveData.peakElectricity = 0;
        anotherCurveData.valleyElectricity = 0;
        anotherCurveData.timeShaft = indexConvertor(index);
        if (anotherCurveData !=nil) {
            [powerCurveDatas insertObject:anotherCurveData atIndex:index];
        }
        
    }
    
    self.powerCurveDatas = powerCurveDatas;
}
/**
 将用电曲线数据 powerCurveDatas 解析为 波平、波峰、波谷数据。
 */
- (void)analysePowerCurveDatas {
    
    // 填充数据
    [self fillPowerCurveDatas];
    
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = [[NSMutableArray alloc] init];
    
    for (AUXECPowerCurveData *curveData in self.powerCurveDatas) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = curveData.waveFlatElectricity;
        pointModel.peakElectricity = curveData.peakElectricity;
        pointModel.valleyElectricity = curveData.valleyElectricity;
        pointModel.xValue = curveData.timeShaft;
        pointModel.waveType = AUXElectricityCurveWaveTypeNone;
        [pointModelArray addObject:pointModel];
    }
    
    self.pointModelList = pointModelArray;
    
    if (self.dateType == AUXElectricityCurveDateTypeDay) {
        // 解析波峰、波谷时间段
        [self analyseTimeBucket];
        
        for (NSValue *value in self.timePeriodArray) {
            AUXECCurveTimePeriod timePeriod = value.timePeriod;
            
            for (NSInteger hour = timePeriod.startHour; hour <= timePeriod.endHour; hour++) {
                if (hour >= self.pointModelList.count) {
                    break;
                }
                
                AUXElectricityConsumptionCurvePointModel *pointModel = self.pointModelList[hour];
                pointModel.waveType = timePeriod.waveType;
            }
        }
    }
}

- (void)clearAllPointModels {
    self.pointModelList = nil;
    
    self.sumWaveFlatElectricity = 0;
    self.sumPeakElectricity = 0;
    self.sumValleyElectricity = 0;
    self.total = 0;
}

- (void)removeUnnecessaryPointModels {
    switch (self.dateType) {
        case AUXElectricityCurveDateTypeYear:
            if (self.year == self.currentYear) {
                self.pointModelList = [self filterMonthInvalidPointModelForArray:self.pointModelList];
            }
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            if (self.year == self.currentYear && self.month == self.currentMonth) {
                self.pointModelList = [self filterDayInvalidPointModelForArray:self.pointModelList];
            }
            break;
            
        default:
            if (self.year == self.currentYear && self.month == self.currentMonth && self.day == self.currentDay) {
                self.pointModelList = [self filterHourInvalidPointModelForArray:self.pointModelList];
            }
            break;
    }
}

/// 过滤数据。去掉超过当前月份的数据。
- (NSArray<AUXElectricityConsumptionCurvePointModel *> *)filterMonthInvalidPointModelForArray:(NSArray<AUXElectricityConsumptionCurvePointModel *> *)pointModelArray {
    
    if (!pointModelArray || pointModelArray.count < self.currentMonth) {
        return pointModelArray;
    }
    
    return [pointModelArray subarrayWithRange:NSMakeRange(0, self.currentMonth)];
}

/// 过滤数据。去掉超过当前天数的数据。(截取到前一天的数据)
- (NSArray<AUXElectricityConsumptionCurvePointModel *> *)filterDayInvalidPointModelForArray:(NSArray<AUXElectricityConsumptionCurvePointModel *> *)pointModelArray {
    
    if (!pointModelArray || pointModelArray.count < self.currentDay) {
        return pointModelArray;
    }
    
    return [pointModelArray subarrayWithRange:NSMakeRange(0, self.currentDay)];
}

/// 过滤数据。去掉超过当前小时的数据。
- (NSArray<AUXElectricityConsumptionCurvePointModel *> *)filterHourInvalidPointModelForArray:(NSArray<AUXElectricityConsumptionCurvePointModel *> *)pointModelArray {
    
    if (!pointModelArray || pointModelArray.count < self.currentHour + 1) {
        return pointModelArray;
    }
    
    return [pointModelArray subarrayWithRange:NSMakeRange(0, self.currentHour + 1)];
}

- (CGFloat)calculateTotalDegrees {
    
    CGFloat totalDegree = 0;
    
    switch (self.source) {
        case AUXDeviceSourceBL: {   // 旧设备没有波峰波谷数据
            totalDegree = [self getTotalDegreeFromPointArray:self.pointModelList];
            self.sumWaveFlatElectricity = totalDegree;
        }
            break;
            
        default:
            totalDegree = self.sumWaveFlatElectricity + self.sumPeakElectricity + self.sumValleyElectricity;
            break;
    }
    
    return totalDegree;
}

/**
 计算曲线的总用电量
 
 @param pointModelArray 用电曲线节点列表
 @return 总用电量
 */
- (CGFloat)getTotalDegreeFromPointArray:(NSArray<AUXElectricityConsumptionCurvePointModel *> *)pointModelArray {
    CGFloat totalDegree = 0;
    
    if ([pointModelArray count] == 0) {
        return totalDegree;
    }
    
    for (AUXElectricityConsumptionCurvePointModel *pointModel in pointModelArray) {
        totalDegree += pointModel.totalElectricity;
    }
    
    return totalDegree;
}

#pragma mark - 测试数据

- (void)setYearTestData {
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = [[NSMutableArray alloc] init];
    
    self.sumWaveFlatElectricity = 0;
    self.sumPeakElectricity = 0;
    self.sumValleyElectricity = 0;
    
    for (int i = 1; i < 13; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = random() % 100 + 0.1;
        pointModel.peakElectricity = random() % 100 + 0.01;
        pointModel.valleyElectricity = random() % 100;
        pointModel.xValue = i;
        
        [pointModelArray addObject:pointModel];
        
        self.sumWaveFlatElectricity += pointModel.waveFlatElectricity;
        self.sumPeakElectricity += pointModel.peakElectricity;
        self.sumValleyElectricity += pointModel.valleyElectricity;
    }
    
    self.pointModelList = pointModelArray;
}

- (void)setMonthTestData {
    NSInteger numberOfDays = [NSDate numberOfDaysInMonth:self.month forYear:self.year];
    
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = [[NSMutableArray alloc] init];
    
    self.sumWaveFlatElectricity = 0;
    self.sumPeakElectricity = 0;
    self.sumValleyElectricity = 0;
    
    for (int i = 1; i <= numberOfDays; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = random() % 10 + 0.24;
        pointModel.peakElectricity = random() % 10 + 0.5;
        pointModel.valleyElectricity = random() % 10;
        pointModel.xValue = i;
        
        [pointModelArray addObject:pointModel];
        
        self.sumWaveFlatElectricity += pointModel.waveFlatElectricity;
        self.sumPeakElectricity += pointModel.peakElectricity;
        self.sumValleyElectricity += pointModel.valleyElectricity;
    }
    
    self.pointModelList = pointModelArray;
}

- (void)setDayTestData {
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = [[NSMutableArray alloc] init];
    
    self.sumWaveFlatElectricity = 0;
    self.sumPeakElectricity = 0;
    self.sumValleyElectricity = 0;
    
    for (int i = 0; i <= 4; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = random() % 5 + 0.15;
        pointModel.xValue = i;
        pointModel.waveType = AUXElectricityCurveWaveTypeNormal;
        [pointModelArray addObject:pointModel];
        
        self.sumWaveFlatElectricity += pointModel.waveFlatElectricity;
    }
    
    for (int i = 5; i <= 10; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.peakElectricity = random() % 5 + 0.2;
        pointModel.xValue = i;
        pointModel.waveType = AUXElectricityCurveWaveTypePeak;
        [pointModelArray addObject:pointModel];
        
        self.sumPeakElectricity += pointModel.peakElectricity;
    }
    
    for (int i = 11; i <= 14; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = random() % 5 + 0.05;
        pointModel.xValue = i;
        pointModel.waveType = AUXElectricityCurveWaveTypeNormal;
        [pointModelArray addObject:pointModel];
        
        self.sumWaveFlatElectricity += pointModel.waveFlatElectricity;
    }
    
    for (int i = 15; i <= 20; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.valleyElectricity = random() % 5 + 0.4;
        pointModel.xValue = i;
        pointModel.waveType = AUXElectricityCurveWaveTypeValley;
        [pointModelArray addObject:pointModel];
        
        self.sumValleyElectricity += pointModel.valleyElectricity;
    }
    
    for (int i = 21; i <= 23; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = random() % 5;
        pointModel.xValue = i;
        pointModel.waveType = AUXElectricityCurveWaveTypeNormal;
        [pointModelArray addObject:pointModel];
        
        self.sumWaveFlatElectricity += pointModel.waveFlatElectricity;
    }
    
    self.pointModelList = pointModelArray;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
