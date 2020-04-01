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

#import "AUXAudioDevice.h"
#import "AUXDeviceInfo.h"

@implementation AUXAudioDevice

- (NSString *)getSupportFuncWithFeature:(AUXDeviceFeature *)deviceFeature {
    NSString *supportFunc;
    
    // 设备支持的模式
    if (deviceFeature) {
        NSMutableArray<NSString *> *modeArray = [[NSMutableArray alloc] init];
        for (NSNumber *number in deviceFeature.supportModes) {
            switch (number.integerValue) {
                case AUXServerDeviceModeAuto:
                    [modeArray addObject:@"0"];
                    break;
                    
                case AUXServerDeviceModeCool:
                    [modeArray addObject:@"1"];
                    break;
                    
                case AUXServerDeviceModeDry:
                    [modeArray addObject:@"2"];
                    break;
                    
                case AUXServerDeviceModeHeat:
                    [modeArray addObject:@"4"];
                    break;
                    
                case AUXServerDeviceModeWind:
                    [modeArray addObject:@"6"];
                    break;
                    
                default:
                    break;
            }
        }
        
        if (modeArray.count > 0) {
            [modeArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSString *mode1 = (NSString *)obj1;
                NSString *mode2 = (NSString *)obj2;
                NSComparisonResult result = mode1.integerValue > mode2.integerValue ? NSOrderedDescending : NSOrderedAscending;
                return result;
            }];
            supportFunc = [modeArray componentsJoinedByString:@""];
        } else {
            supportFunc = @"";
        }
    } else {
        supportFunc = @"01246";
    }
    
    return supportFunc;
}

- (void)setValueWithDeviceInfo:(AUXDeviceInfo *)deviceInfo deviceControl:(AUXACControl *)deviceControl deviceStatus:(AUXACStatus *)deviceStatus {
    
    self.mac = deviceInfo.mac;
    
    self.onOff = deviceControl.onOff;
    
    // 设备支持的模式
    self.supportFunc = [self getSupportFuncWithFeature:deviceInfo.deviceFeature];
    
    self.airConFunc = deviceControl.airConFunc;
    
    self.temperature = deviceControl.temperature;
    self.half = deviceControl.half;
    
    switch (deviceInfo.windGearType) {
        case WindGearType1:
            self.windSpeedGear = 3;
            break;
            
        default:
            self.windSpeedGear = 5;
            break;
    }
    self.windSpeed1 = deviceControl.windSpeed1;
    self.turbo = deviceControl.turbo;
    self.silence = deviceControl.silence;
    
    self.upDownSwing = deviceControl.upDownSwing == 0 || deviceControl.upDownSwing == 6 ? true : false;
    self.leftRightSwing = deviceControl.leftRightSwing == 0 || deviceControl.leftRightSwing ==  4 ? true : false;
    self.sleepMode = deviceControl.sleepMode;
    self.electricHeating = deviceControl.electricHeating;
    self.eco = deviceControl.eco;
    self.clean = deviceControl.clean;
    self.healthy = deviceControl.healthy;
    self.autoScreen = deviceControl.autoScreen;
    self.screenOnOff = deviceControl.screenOnOff;
    self.electricLock = deviceControl.electricLock;
    self.antiFungus = deviceControl.antiFungus;
    
    NSString *roomTempreture = [NSString stringWithFormat:@"%hhd.%hhd" , deviceStatus.roomTemperature , deviceStatus.roomTemperatureDecimal];
    // 室内温度
    self.roomTemperature = roomTempreture.floatValue;
    
    self.faultCode = deviceStatus.fault ? deviceStatus.fault.code : 0;
    self.moduleProtectFault = deviceStatus.moduleProtectFault;
}

- (void)updateDeviceControl:(AUXACControl *)deviceControl {
    
    deviceControl.onOff = self.onOff;
    
    deviceControl.airConFunc = self.airConFunc;
    deviceControl.temperature = self.temperature;
    deviceControl.half = self.half;
    deviceControl.windSpeed1 = self.windSpeed1;
    deviceControl.turbo = self.turbo;
    deviceControl.silence = self.silence;
    deviceControl.upDownSwing = self.upDownSwing;
    deviceControl.leftRightSwing = self.leftRightSwing;
    deviceControl.sleepMode = self.sleepMode;
    deviceControl.electricHeating = self.electricHeating;
    deviceControl.eco = self.eco;
    deviceControl.clean = self.clean;
    deviceControl.healthy = self.healthy;
    deviceControl.electricLock = self.electricLock;
    deviceControl.autoScreen = self.autoScreen;
    deviceControl.screenOnOff = self.screenOnOff;
    deviceControl.antiFungus = self.antiFungus;
}


- (char)upDownSwing {
    if ((int)_upDownSwing == 6 || (int)_upDownSwing == 0) {
        return 1;
    }
    return 0;
}

- (char)leftRightSwing {
    if ((int)_leftRightSwing == 0 || (int)_leftRightSwing == 4) {
        return 1;
    }
    return 0;
}


- (NSString *)description
{
    return [self yy_modelDescription];
}

@end


@implementation AUXAnswerAudioDevice

@end
