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

#import "AUXDeviceFeature.h"

#import <YYModel/YYModel.h>

@implementation AUXDeviceFeature

+ (instancetype)virtualDeviceFeature {
    AUXDeviceFeature *feature = [[AUXDeviceFeature alloc] init];
    [feature setDefaultValueForVirtualDevice];
    return feature;
}

static AUXDeviceFeature *_multiDeviceFeature = nil;

+ (instancetype)multiDeviceFeature {
    return _multiDeviceFeature;
}

+ (void)setMultiDeviceFeature:(AUXDeviceFeature *)deviceFeature {
    _multiDeviceFeature = deviceFeature;
}

+ (AUXDeviceFeature *)createDefaultMultiDeviceFeature {
    AUXDeviceFeature *feature = [[AUXDeviceFeature alloc] init];
    [feature setDefaultValueForMultiDevice];
    return feature;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setDefaultValue];
    }
    
    return self;
}

- (instancetype)initWithJSON:(NSString *)JSONString {
    self = [super init];
    
    if (self) {
        [self setDefaultValue];
        [self setValueWithJSON:JSONString];
    }
    
    return self;
}

- (void)setDefaultValue {
    self.hasDeviceInfo = YES;
}

- (void)setDefaultValueForVirtualDevice {
    self.coolOnly = NO;
    self.frequencyConversion = YES;
    self.halfTemperature = YES;
    self.hasRoomTemperature = YES;
    self.hasFault = YES;
    self.hasScheduler = YES;
    
    self.windSpeedGear = AUXWindSpeedGearTypeSix;
    self.screenGear = AUXDeviceScreenGearThree;
    
    self.supportModes = @[@(AUXServerDeviceModeAuto),
                          @(AUXServerDeviceModeCool),
                          @(AUXServerDeviceModeHeat),
                          @(AUXServerDeviceModeDry),
                          @(AUXServerDeviceModeWind)];
    
    self.deviceSupportFuncs = @[@(AUXDeviceSupportFuncClean),
                                @(AUXDeviceSupportFuncMouldProof),
                                @(AUXDeviceSupportFuncWindSpeedMute),
                                @(AUXDeviceSupportFuncWindSpeedTurbo),
                                @(AUXDeviceSupportFuncHealth),
                                @(AUXDeviceSupportFuncECO),
                                @(AUXDeviceSupportFuncElectricalHeating),
                                @(AUXDeviceSupportFuncSleep),
                                @(AUXDeviceSupportFuncChildLock),
                                @(AUXDeviceSupportFuncSwingLeftRight),
                                @(AUXDeviceSupportFuncSwingUpDown),
                                @(AUXDeviceSupportFuncComfortWind)];
    
    self.appSupportFuncs = @[@(AUXAppSupportFuncSleepDIY),
                             @(AUXAppSupportFuncElectricityConsumptionCurve),
                             @(AUXAppSupportFuncSmartPower),
                             @(AUXAppSupportFuncPeakValley),
                             @(AUXAppSupportFuncLimitElectricity),
                             @(AUXAppSupportFuncFilter)];
}

- (void)setDefaultValueForMultiDevice {
    self.hasDeviceInfo = NO;
    
    self.coolOnly = NO;
    self.frequencyConversion = NO;
    self.halfTemperature = YES;
    self.hasRoomTemperature = NO;
    self.hasFault = NO;
    self.hasScheduler = NO;
    
    
    self.windSpeedGear = AUXWindSpeedGearTypeSix;
    self.screenGear = AUXDeviceScreenGearThree;
    
    self.supportModes = @[@(AUXServerDeviceModeAuto),
                          @(AUXServerDeviceModeCool),
                          @(AUXServerDeviceModeHeat),
                          @(AUXServerDeviceModeDry),
                          @(AUXServerDeviceModeWind)];
    
    self.deviceSupportFuncs = @[@(AUXDeviceSupportFuncClean),
                                @(AUXDeviceSupportFuncMouldProof),
                                @(AUXDeviceSupportFuncWindSpeedMute),
                                @(AUXDeviceSupportFuncWindSpeedTurbo),
                                @(AUXDeviceSupportFuncHealth),
                                @(AUXDeviceSupportFuncECO),
                                @(AUXDeviceSupportFuncSleep),
                                @(AUXDeviceSupportFuncChildLock),
                                @(AUXDeviceSupportFuncSwingLeftRight),
                                @(AUXDeviceSupportFuncSwingUpDown),
                                @(AUXDeviceSupportFuncComfortWind)];
    
    self.appSupportFuncs = @[];
}

- (void)setValueWithJSON:(NSString *)JSONString {
    [self yy_modelSetWithJSON:JSONString];
    
    if (self.coolType.count == 2) {
        self.coolOnly = (self.coolType.firstObject.integerValue == 0) ? YES : NO;
    }
    
    if (self.frenquency.count == 2) {
        self.frequencyConversion = (self.frenquency.firstObject.integerValue == 1) ? YES : NO;
    }
    
    if (self.tempInterval.count == 2) {
        self.halfTemperature = (self.tempInterval.firstObject.integerValue == 0) ? YES : NO;
    }
    
    if (self.roomTempDisplay.count == 2) {
        self.hasRoomTemperature = (self.roomTempDisplay.firstObject.integerValue == 1) ? YES : NO;
    }
    
    if (self.faultSupport.count == 2) {
        self.hasFault = (self.faultSupport.firstObject.integerValue == 0) ? YES : NO;
    }
    
    if (self.timing.count == 2) {
        self.hasScheduler = (self.timing.firstObject.integerValue == 0) ? YES : NO;
    }
    
    if (self.windSpeed.count == 2) {
        self.windSpeedGear = self.windSpeed.firstObject.integerValue;
    }
    
    if (self.screen.count == 2) {
        self.screenGear = self.screen.firstObject.integerValue;
    }
    
    if (self.mode.count == 2) {
        NSString *modeString = self.mode.firstObject;
        self.supportModes = [self integerValueArrayFromString:modeString];
    }
    
    if (self.deviceSupport.count == 2) {
        NSString *funcString = self.deviceSupport.firstObject;
        self.deviceSupportFuncs = [self integerValueArrayFromString:funcString];
    }
    
    if (self.appSupport.count == 2) {
        NSString *funcString = self.appSupport.firstObject;
        self.appSupportFuncs = [self integerValueArrayFromString:funcString];
    }
}

- (NSArray<NSNumber *> *)integerValueArrayFromString:(NSString *)string {
    if ([string length] == 0) {
        return nil;
    }
    
    NSArray *components = [string componentsSeparatedByString:@","];
    NSMutableArray<NSNumber *> *numberArray = [[NSMutableArray alloc] init];
    
    for (NSString *intString in components) {
        if ([intString length] == 0) {
            continue;
        }
        
        [numberArray addObject:@(intString.integerValue)];
    }
    
    return numberArray;
}

- (NSArray <NSNumber *> *)convertToAirConFunctionModeList {
    NSMutableArray <NSNumber *>*modes = [NSMutableArray array];
    
    for (NSNumber *mode in self.supportModes) {
        if ([mode isEqual:@(AUXServerDeviceModeAuto)]) {
            [modes addObject:@(AirConFunctionAuto)];
        }
        if ([mode isEqual:@(AUXServerDeviceModeDry)]) {
            [modes addObject:@(AirConFunctionVentilate)];
        }
        if ([mode isEqual:@(AUXServerDeviceModeCool)]) {
            [modes addObject:@(AirConFunctionCool)];
        }
        if ([mode isEqual:@(AUXServerDeviceModeHeat)]) {
            [modes addObject:@(AirConFunctionHeat)];
        }
        if ([mode isEqual:@(AUXServerDeviceModeWind)]) {
            [modes addObject:@(AirConFunctionDehumidify)];
        }
    }
    
    
    return modes;
}

- (NSArray<NSNumber *> *)convertToOnSectionList {
    NSMutableArray<NSNumber *> *sectionArray = [[NSMutableArray alloc] init];
    
    // 定时
    if (self.hasScheduler) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeScheduler)];
    }
    // 用电曲线
    if ([self.appSupportFuncs containsObject:@(AUXAppSupportFuncElectricityConsumptionCurve)]) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeElectricityConsumptionCurve)];
    }
    // 用电限制
    if ([self.appSupportFuncs containsObject:@(AUXAppSupportFuncLimitElectricity)]) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeLimitElectricity)];
    }
    // 峰谷节电
    if ([self.appSupportFuncs containsObject:@(AUXAppSupportFuncPeakValley)]) {
        [sectionArray addObject:@(AUXDeviceFunctionTypePeakValley)];
    }
    // 睡眠DIY
    if ([self.appSupportFuncs containsObject:@(AUXAppSupportFuncSleepDIY)]) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeSleepDIY)];
    }
    // 智能用电
    if ([self.appSupportFuncs containsObject:@(AUXAppSupportFuncSmartPower)]) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeSmartPower)];
    }
    
    return sectionArray;
}

- (NSArray<NSNumber *> *)convertToOffSectionList {
    NSMutableArray<NSNumber *> *sectionArray = [[NSMutableArray alloc] init];
    
    // 定时
    if (self.hasScheduler) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeScheduler)];
    }
    // 用电曲线
    if ([self.appSupportFuncs containsObject:@(AUXAppSupportFuncElectricityConsumptionCurve)]) {
        [sectionArray addObject:@(AUXDeviceFunctionTypeElectricityConsumptionCurve)];
    }
    
    return sectionArray;
}

- (NSArray<NSNumber *> *)convertToOnFunctionList {
    // 当前设备可用的功能列表 (开机状态下)
    NSMutableArray<NSNumber *> *enableFuncList = [[NSMutableArray alloc] init];
   
    //开关
    [enableFuncList addObject:@(AUXDeviceFunctionTypePower)];
    //制冷
    [enableFuncList addObject:@(AUXDeviceFunctionTypeCold)];
    //制热
    [enableFuncList addObject:@(AUXDeviceFunctionTypeHot)];
    // 风速
    [enableFuncList addObject:@(AUXDeviceFunctionTypeWindSpeed)];
    // 模式
    [enableFuncList addObject:@(AUXDeviceFunctionTypeMode)];
    // 上下摆风
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncSwingUpDown)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeSwingUpDown)];
    }
    // 左右摆风
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncSwingLeftRight)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeSwingLeftRight)];
    }
    
    // 屏显
    [enableFuncList addObject:@(AUXDeviceFunctionTypeDisplay)];
    
    // ECO
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncECO)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeECO)];
    }
    // 电加热
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncElectricalHeating)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeElectricalHeating)];
    }
    // 睡眠
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncSleep)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeSleep)];
    }
    // 健康
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncHealth)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeHealth)];
    }
    // 童锁
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncChildLock)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeChildLock)];
    }
    // 舒适风
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncComfortWind)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeComfortWind)];
    }
    
    return enableFuncList;
}

- (NSArray<NSNumber *> *)convertToOffFunctionList {
    // 当前设备可用的功能列表
    NSMutableArray<NSNumber *> *enableFuncList = [[NSMutableArray alloc] init];
    
    //开关
    [enableFuncList addObject:@(AUXDeviceFunctionTypePower)];
    //制冷
    [enableFuncList addObject:@(AUXDeviceFunctionTypeCold)];
    //制热
    [enableFuncList addObject:@(AUXDeviceFunctionTypeHot)];
    // 屏显
    [enableFuncList addObject:@(AUXDeviceFunctionTypeDisplay)];
    // 清洁
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncClean)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeClean)];
    }
    // 防霉
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncMouldProof)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeMouldProof)];
    }
    
    return enableFuncList;
}

- (NSArray<NSNumber *> *)convertToModeList {
    // 当前设备可用的功能列表
    NSMutableArray<NSNumber *> *enableFuncList = [[NSMutableArray alloc] init];
    
    //开关
    [enableFuncList addObject:@(AUXDeviceFunctionTypePower)];
    //制冷
    [enableFuncList addObject:@(AUXDeviceFunctionTypeCold)];
    //制热
    [enableFuncList addObject:@(AUXDeviceFunctionTypeHot)];
    // 屏显
    [enableFuncList addObject:@(AUXDeviceFunctionTypeDisplay)];
    // 清洁
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncClean)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeClean)];
    }
    // 防霉
    if ([self.deviceSupportFuncs containsObject:@(AUXDeviceSupportFuncMouldProof)]) {
        [enableFuncList addObject:@(AUXDeviceFunctionTypeMouldProof)];
    }
    
    return enableFuncList;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
