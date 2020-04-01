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

#import "AUXDeviceDiscoverManager.h"

#import "AUXUser.h"
#import "RACEXTScope.h"

@interface AUXDeviceDiscoverManager () 

// 搜索设备3次，间隔2秒
@property (nonatomic, strong) NSTimer *discoverTimer;
@property (nonatomic, assign) NSInteger discoverCount;

@end

@implementation AUXDeviceDiscoverManager

+ (instancetype)defaultManager {
    static AUXDeviceDiscoverManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUXDeviceDiscoverManager alloc] init];
    });
    
    return manager;
}

- (void)startDiscoverDevice {
    
    if (![AUXUser isLogin]) {
        return;
    }
    
    if (self.discoverTimer && self.discoverTimer.isValid) {
        return;
    }
    
    self.discoverCount = 1;
    self.discoveringDevices = YES;
    
    self.discoverTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(discoverTimeout) userInfo:nil repeats:YES];
    
    [[AUXACNetwork sharedInstance].delegates addObject:self];
    
    [self startSDKDiscover];
}

- (void)stopDiscoverDevice {
    if (!self.discoverTimer) {
        return;
    }
    
    [self.discoverTimer invalidate];
    self.discoverTimer = nil;
    
    self.discoveringDevices = NO;
    
    [self removeDevicesDelegate];
}

- (void)startSDKDiscover {
    AUXUser *user = [AUXUser defaultUser];
    
    if (![AUXUser isLogin]) {
        return;
    }
    
    [[AUXACNetwork sharedInstance] getBoundDevicesWithUid:user.uid token:user.token type:AUXACNetworkDeviceWifiTypeAll];
}

- (void)discoverTimeout {
    
    if (self.discoverCount > 3) {
        [self stopDiscoverDevice];
        AUXUser *user = [AUXUser defaultUser];
        [user createOldDevicesIfNeededWithDeviceDelegate:nil];
        return;
    }
    
    self.discoverCount += 1;
    [self startSDKDiscover];
}

- (void)removeDevicesDelegate {
    [[AUXACNetwork sharedInstance].delegates removeObject:self];
    [[AUXUser defaultUser] removeDevicesDelegate:self];
}

#pragma mark - AUXACNetworkProtocol

- (void)auxACNetworkDidDiscoveredDeviceList:(NSArray *)deviceList success:(BOOL)success withError:(NSError *)error {
    
    if (success) {
        if ([deviceList count] == 0) {
            return;
        }
        
        AUXUser *user = [AUXUser defaultUser];
        
        // 更新设备列表
        [user updateDeviceDictionaryWithDeviceArray:deviceList deviceDelegate:self];
    }
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidSubscribeDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    
    NSString *mac;
    NSString *typeString;
    
    if (device.bLDevice) {
        mac = device.bLDevice.mac;
        typeString = @"【古北】";
    } else {
        mac = device.gizDevice.macAddress;
        typeString = @"【机智云】";
    }
    
    if (success) {
//        NSLog(@"设备搜索管理 设备 %@: %@ 订阅成功", typeString, mac);
    } else {
//        NSLog(@"设备搜索管理 设备 %@: %@ 订阅失败 %@", typeString, mac, error);
    }
}

- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSString *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type {
    
    NSString *mac;
    NSString *typeString;
    
    if (device.bLDevice) {
        mac = device.bLDevice.mac;
        typeString = @"【古北】";
    } else {
        mac = device.gizDevice.macAddress;
        typeString = @"【机智云】";
    }
    
    if (success) {
        switch (type) {
            case AUXACNetworkQueryTypeControl:
//                NSLog(@"设备搜索管理 设备 %@ %@ 上报控制状态", typeString, mac);
                break;
                
            case AUXACNetworkQueryTypeStatus:
//                NSLog(@"设备搜索管理 设备 %@ %@ 上报运行状态", typeString, mac);
                break;
                
            case AUXACNetworkQueryTypeSubDevices:
//                NSLog(@"设备搜索管理 设备 %@ %@ 子设备列表: %@", typeString, mac, device.aliasDic);
                break;
                
            default:
                break;
        }
    } else {
//        NSLog(@"设备搜索管理 设备 %@ %@ 状态上报错误 %@ %@", typeString, mac, @(type), error);
    }
}

@end
