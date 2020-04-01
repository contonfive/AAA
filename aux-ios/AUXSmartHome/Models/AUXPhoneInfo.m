//
//  AUXPhoneInfo.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/5/23.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUXPhoneInfo.h"
#import "AUXUser.h"
#import "NSDate+AUXCustom.h"
#import <GizWifiSDK/GizWifiSDK.h>

#import <NetworkExtension/NetworkExtension.h> //此框架用来获取所连接wifi的某些信息

#import <SystemConfiguration/CaptiveNetwork.h>

@implementation AUXPhoneInfo

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.message_id = [NSString stringWithFormat:@"%@%@" , [AUXUser defaultUser].uid , [NSDate cNowTimestamp]];
        
        [self getWifiInfo];
        [self getWifiList];
        
        self.frequency = nil;
        self.hidden_ssid = NO;
        self.ip = [UIDevice localIP];
        self.net_id = nil;
        self.os_version = [self getOSInfo];
        self.app_version = APP_VERSION;
        self.device_type = @"";
        self.phone_model = [[UIDevice currentDevice] model];
        self.speed = nil;
    }
    return self;
}

- (void)setConfig_type:(NSInteger)config_type {
    _config_type = config_type;
    
    self.config_type_value = [self getConfigTypeValue:config_type];
}

- (NSString *)getConfigTypeValue:(AUXDeviceConfigType)config_type {
    switch (config_type) {
        case AUXDeviceConfigTypeBLDevice:
            return @"古北";
            break;
        case AUXDeviceConfigTypeMXDevice:
            return @"庆科";
            break;
        case AUXDeviceConfigTypeGizDevice:
            return @"古北(机智云)";
            break;
        default:
            return @"古北";
            break;
    }
}

#pragma mark - 获取手机附近所有WIFI
- (void)getWifiList {
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)) {return;}
    dispatch_queue_t queue = dispatch_queue_create("com.leopardpan.HotspotHelper", 0);
    [NEHotspotHelper registerWithOptions:nil queue:queue handler: ^(NEHotspotHelperCommand * cmd) {
        if(cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
            for (NEHotspotNetwork* network  in cmd.networkList) {
                
                if ([network.SSID isEqualToString:self.wifi_ssid]) {
                    self.rssi = [NSString stringWithFormat:@"%.1f" , network.signalStrength];
                }
                
            }
        }
    }];
}

#pragma mark - 获取wifi的名字和mac
- (void)getWifiInfo {
    CFArrayRef myArray = CNCopySupportedInterfaces();
    NSDictionary *networkInfo = (__bridge NSDictionary *) CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    
    if (networkInfo) {
        self.wifi_ssid = [networkInfo objectForKey:@"SSID"];
        self.bssid = [self standardFormateMAC:[networkInfo objectForKey:@"BSSID"]];
        
    } else {
        self.wifi_ssid = @"4G";
        self.bssid = @"4G";
    }
    
}

#pragma mark - wifi mac少头0预防
- (NSString *)standardFormateMAC:(NSString *)MAC {
    NSArray * subStr = [MAC componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":-"]];
    NSMutableArray * subStr_M = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString * str in subStr) {
        if (1 == str.length) {
            NSString * tmpStr = [NSString stringWithFormat:@"0%@", str];
            [subStr_M addObject:tmpStr];
        } else {
            [subStr_M addObject:str];
        }
    }
    
    NSString * formateMAC = [subStr_M componentsJoinedByString:@":"];
    return [formateMAC uppercaseString];
}

#pragma mark - 获取手机系统版本号
- (NSString *)getOSInfo
{
    NSString *versionStr = [[UIDevice currentDevice] systemVersion];
    return versionStr;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}


@end
