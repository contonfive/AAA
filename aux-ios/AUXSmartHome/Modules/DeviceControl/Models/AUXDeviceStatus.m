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

#import "AUXDeviceStatus.h"

@implementation AUXDeviceStatus

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXDeviceStatus *deviceStatus = [[[self class] allocWithZone:zone] init];
    
    [deviceStatus yy_modelSetWithDictionary:[self yy_modelToJSONObject]];
    
    return deviceStatus;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.windGearType = WindGearType1;
        [self initializeValues];
    }
    
    return self;
}

- (instancetype)initWithGearType:(WindGearType)gearType {
    self = [super init];
    
    if (self) {
        self.windGearType = gearType;
        [self initializeValues];
    }
    
    return self;
}

- (void)initializeValues {
    self.powerOn = YES;
    self.mode = AirConFunctionCool;
    self.windSpeed = WindSpeedMin;
    self.turbo = NO;
    self.silence = NO;
    self.temperature = 27.0;
    self.roomTemperature = 26.0;
    self.swingUpDown = NO;
    self.swingLeftRight = NO;
    self.eco = NO;
    self.electricHeating = NO;
    self.clean = NO;
    self.healthy = NO;
    self.airFreshing = NO;
    self.sleepDIY = NO;
    self.powerLimit = NO;
    self.powerLimitPercent = 30;
    self.screenOnOff = YES;
    self.autoScreen = NO;
    self.comfortWind = NO;
}

- (void)setConvenientWindSpeed:(WindSpeed)convenientWindSpeed {
    
    switch (convenientWindSpeed) {
        case WindSpeedTurbo:
            self.turbo = YES;
            self.silence = NO;
            break;
            
        case WindSpeedSilence:
            self.turbo = NO;
            self.silence = YES;
            break;
            
        default:
            self.turbo = NO;
            self.silence = NO;
            self.windSpeed = convenientWindSpeed;
            break;
    }
}

- (void)setSilence:(BOOL)silence {
    _silence = silence;
    
    if (_silence) {
        self.windSpeed = WindSpeedMin;
    }
}

-  (void)setTurbo:(BOOL)turbo {
    _turbo = turbo;
    
    if (_turbo) {
        self.windSpeed = WindSpeedMax;
    }
}

- (WindSpeed)convenientWindSpeed {
    if (self.turbo) {
        return WindSpeedTurbo;
    }
    
    if (self.silence) {
        return WindSpeedSilence;
    }
    
    return self.windSpeed;
}

- (void)updateWithControl:(AUXACControl *)deviceControl {
    CGFloat temperature = (CGFloat)deviceControl.temperature;
    if (deviceControl.half) {
        temperature += 0.5;
    }
    
    self.temperature = temperature;
    self.mode = deviceControl.airConFunc;
    self.comfortWind = deviceControl.comfortWind;
    
    if (self.comfortWind == NO) {
        self.windSpeed = [deviceControl getWindSpeedWithType:self.windGearType];
        self.silence = deviceControl.silence;
        self.turbo = deviceControl.turbo;
        self.swingUpDown = deviceControl.upDownSwing == 0 || deviceControl.upDownSwing == 6 ? true : false;
        self.swingLeftRight = deviceControl.leftRightSwing == 0 || deviceControl.leftRightSwing == 4 ? true : false;
    } else {
        self.windSpeed = WindSpeedAuto;
        self.silence = NO;
        self.turbo = NO;
        self.swingUpDown = NO;
        self.swingLeftRight = NO;
    }
    
    self.eco = deviceControl.eco;
    self.electricHeating = deviceControl.electricHeating;
    self.clean = deviceControl.clean;
    self.healthy = deviceControl.healthy;
    self.airFreshing = deviceControl.airFreshing;
    self.screenOnOff = deviceControl.screenOnOff;
    self.autoScreen = deviceControl.autoScreen;
    self.sleepMode = deviceControl.sleepMode;
    self.childLock = deviceControl.electricLock;
    self.antiFungus = deviceControl.antiFungus;
    self.sleepDIY = deviceControl.sleepDiy;
    self.powerLimit = deviceControl.powerLimit;
    self.powerLimitPercent = deviceControl.powerLimitPercent;
}

- (void)updateValueForControl:(AUXACControl *)deviceControl {
    [self updateValueForControl:deviceControl withWindGear:self.windGearType];
}

- (void)updateValueForControl:(AUXACControl *)deviceControl withWindGear:(WindGearType)gearType {
    deviceControl.onOff = self.powerOn;
    
    NSInteger nTemperature = self.temperature;
    deviceControl.temperature = nTemperature;
    deviceControl.half = (self.temperature != nTemperature);
    
    deviceControl.airConFunc = self.mode;
    
    deviceControl.turbo = self.turbo;
    deviceControl.silence = self.silence;
    [deviceControl setWindSpeed:self.windSpeed WithType:gearType];
    
    deviceControl.upDownSwing = self.swingUpDown;
    deviceControl.leftRightSwing = self.swingLeftRight;
    deviceControl.eco = self.eco;
    deviceControl.electricHeating = self.electricHeating;
    deviceControl.clean = self.clean;
    deviceControl.healthy = self.healthy;
    deviceControl.airFreshing = self.airFreshing;
    deviceControl.screenOnOff = self.screenOnOff;
    deviceControl.autoScreen = self.autoScreen;
    deviceControl.sleepMode = self.sleepMode;
    deviceControl.electricLock = self.childLock;
    deviceControl.comfortWind = self.comfortWind;
}

- (BOOL)canAdjustTemperature:(NSString *__autoreleasing *)message {
    
    // 童锁开启中，不能调节温度
    if (self.childLock) {
        NSString *errorMessage = @"空调处于锁定状态，解锁之后才能进行相应操作";
        if (message) {
            *message = errorMessage;
        }
        return NO;
    }
    
    // 睡眠DIY开启中，不能调节温度
    if (self.sleepDIY) {
        NSString *errorMessage = @"请关闭睡眠DIY后进行操作";
        if (message) {
            *message = errorMessage;
        }
        return NO;
    }
    
    return YES;
}


@end
