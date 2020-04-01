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

#import "AUXDeviceInfo.h"
#import "AUXDeviceModel.h"

#import "AUXConfiguration.h"

#import "NSString+AUXCustom.h"

@implementation AUXDeviceInfo {
    AUXDeviceFeature *_deviceFeature;
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"windGearType", @"device", @"deviceFeature", @"addressArray", @"virtualDevice"];
}

+ (instancetype)virtualDeviceInfo {
    AUXDeviceInfo *deviceInfo = [[AUXDeviceInfo alloc] init];
    
    deviceInfo.virtualDevice = YES;
    deviceInfo.alias = @"虚拟体验";
    deviceInfo.suitType = AUXDeviceSuitTypeAC;
    deviceInfo.useType = AUXDeviceMachineTypeStand;
    deviceInfo.source = AUXDeviceSourceGizwits;
    
    return deviceInfo;
}

- (instancetype)initWithACDevice:(AUXACDevice *)acDevice model:(AUXDeviceModel *)model deviceSN:(NSString *)deviceSN {
    self = [super init];
    
    if (self) {
        if (acDevice.bLDevice) {
            self.source = AUXDeviceSourceBL;
            self.mac = acDevice.bLDevice.mac;
            self.alias = acDevice.bLDevice.alias;
            self.deviceKey = acDevice.bLDevice.key;
            self.type = acDevice.bLDevice.type;
            self.deviceLock = [NSString stringWithFormat:@"%d", acDevice.bLDevice.lock];
            self.password = [NSString stringWithFormat:@"%u", acDevice.bLDevice.password];
            self.terminalId = acDevice.bLDevice.terminal_id;
            self.subDevice = acDevice.bLDevice.sub_device;
            self.dataOne = acDevice.bLDevice.dataOne;
            self.dataTwo = acDevice.bLDevice.dataTwo;
            self.dataThree = acDevice.bLDevice.dataThree;
        } else {
            self.source = AUXDeviceSourceGizwits;
            self.mac = acDevice.gizDevice.macAddress;
            self.did = acDevice.gizDevice.did;
            self.productKey = acDevice.gizDevice.productKey;
            self.alias = acDevice.gizDevice.alias;
        }
        
        self.modelId = model.modelId;
        self.sn = deviceSN;
        self.suitType = model.suitType;
        self.useType = model.useType;
    }
    
    return self;
}

- (NSString *)alias {
    if (!_alias || _alias.length == 0) {
        _alias = @"奥克斯空调";
    }
    
    return _alias;
}

- (WindGearType)windGearType {
    return [AUXConfiguration getSDKWindGearTypeWithMachineType:self.useType];
}

- (AUXDeviceFeature *)deviceFeature {
    if (!_deviceFeature) {
        _deviceFeature = [[AUXDeviceFeature alloc] initWithJSON:self.feature];
    }
    
    return _deviceFeature;
}

//- (NSString *)description {
//    NSString *string = [NSString stringWithFormat:@"<AUXDeviceInfo: %p>, mac: %@, alias: %@", self, self.mac, self.alias];
//    return string;
//}

- (BOOL)isDefaultName:(NSString *)name {
    if (name && [name hasPrefix:@"AC-"]) {
        return YES;
    }
    
    return NO;
}

- (void)updateDeviceFeature:(AUXDeviceFeature *)deviceFeature {
    _deviceFeature = deviceFeature;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
