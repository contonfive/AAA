//
//  AUXDeviceListViewModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/4.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceListViewModel.h"

#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXArchiveTool.h"
#import "AUXDeviceDiscoverManager.h"
#import "AUXConfiguration.h"
#import "AUXLocalNetworkTool.h"
#import "AUXConstant.h"

#import "NSString+AUXCustom.h"

@interface AUXDeviceListViewModel()<AUXACNetworkProtocol, AUXACDeviceProtocol, AUXNetworkManagerDelegate>

// VC加载时，先显示服务器的设备列表，设备是否在线根据SDK是否找到对应的AUXACDevice来进行判断。
@property (nonatomic, strong) NSTimer *discoverTimer;       // 搜索设备 2s * 2次
@property (nonatomic, assign) NSInteger currentDiscoverCount;
@property (nonatomic,strong) NSTimer *reloadTimer;

@property (nonatomic, strong) NSTimer *discoverTimerOfDiscoverFail;       // 搜索设备 2s * 5次
@property (nonatomic, assign) NSInteger currentDiscoverCountOfDiscoverFail;
@end

@implementation AUXDeviceListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoginNotification:) name:AUXUserDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogoutNotification:) name:AUXUserDidLogoutNotification object:nil];
        [[AUXACNetwork sharedInstance].delegates addObject:self];
        
        if (self.deviceInfoArray.count > 0) {
            
            AUXUser *user = [AUXUser defaultUser];
            AUXDeviceDiscoverManager *discoverManager = [AUXDeviceDiscoverManager defaultManager];
            
            if (discoverManager.discoveringDevices) {
                [discoverManager stopDiscoverDevice];
            }
            
            [user addDevicesDelegate:self];
            [self startDiscoverWithTimer];
        }
        
    }
    return self;
}

- (void)requestDeviceList {
    
    if (self.discoverTimerOfDiscoverFail) {
        [self.discoverTimerOfDiscoverFail invalidate];
        self.discoverTimerOfDiscoverFail = nil;
    }
    
    if ([AUXUser isLogin]) {
        
        [self showLoading];
        
        if (!self.reloadTimer) {
            self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(reloadAUXdeviceInfo) userInfo:nil repeats:YES];
        }
        
        [self getSaasDeviceList];
        [self getBoundDevices];
    }
}

- (void)startDiscoverWithTimer {
    
    if (self.discoverTimer && self.discoverTimer.isValid) {
        return;
    }
    
    self.currentDiscoverCount = 1;
    [self getBoundDevices];
    self.discoverTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(discoverACDeviceTimeout) userInfo:nil repeats:YES];
}

- (void)discoverACDeviceTimeout {
    if (self.currentDiscoverCount >= 2) {
        [self.discoverTimer invalidate];
        self.discoverTimer = nil;
        
        [[AUXUser defaultUser] createOldDevicesIfNeededWithDeviceDelegate:self];

        return;
    }
    
    self.currentDiscoverCount += 1;
    [self getBoundDevices];
}

- (void)discoverACDeviceTimerOfDiscoverFail {
    
    if (self.currentDiscoverCountOfDiscoverFail >= 5) {
        [self.discoverTimerOfDiscoverFail invalidate];
        self.discoverTimerOfDiscoverFail = nil;
        
        return ;
    }
    
    self.currentDiscoverCountOfDiscoverFail++;
    
    AUXUser *user = [AUXUser defaultUser];
    [[AUXACNetwork sharedInstance] getBoundDevicesWithUid:user.uid token:user.token type:AUXACNetworkDeviceWifiTypeAll];
}

/// 调用 SDK 搜索设备
- (void)getBoundDevices {
    AUXUser *user = [AUXUser defaultUser];
    
    // 用户已登录，直接获取设备列表
    if ([AUXUser isLogin]) {
        if (user.deviceInfoArray.count > 0) {
            [[AUXACNetwork sharedInstance] getBoundDevicesWithUid:user.uid token:user.token type:AUXACNetworkDeviceWifiTypeAll];
        } else {
            [self hideLoading];
        }
    }
}

#pragma mark 查询服务器的设备列表
- (void)getSaasDeviceList {
    if ([AUXUser isLogin]) {
        [[AUXNetworkManager manager] getDeviceListWithCompletion:^(NSArray<AUXDeviceInfo *> * _Nullable deviceInfoList, NSError * _Nonnull error) {
            [self didGetDeviceList:deviceInfoList error:error];
        }];
    }
}

- (void)reloadAUXdeviceInfo{
    [self refrashDeviceStatus];
}

#pragma mark AUXNetworkManagerDelegate

- (void)didGetDeviceList:(NSArray<AUXDeviceInfo *> *)deviceInfoList error:(NSError *)error {
    
    [self hideLoading];
    
    switch (error.code) {
        case AUXNetworkErrorNone:
            if (deviceInfoList && deviceInfoList.count >= 0) {
                [AUXUser defaultUser].deviceInfoArray = [NSMutableArray arrayWithArray:deviceInfoList];
                
                NSArray *existDeviceIdArray = [[AUXUser defaultUser].deviceDictionary allKeys];
                NSArray *boundDeviceIdArray = [deviceInfoList valueForKey:@"deviceId"];
                
                for (NSString *deviceId in existDeviceIdArray) {
                    if (![boundDeviceIdArray containsObject:deviceId]) {
                        [[AUXUser defaultUser].deviceDictionary removeObjectForKey:deviceId];
                    }
                }
                
                [self startDiscoverWithTimer];
            } else {
                [[AUXUser defaultUser].deviceInfoArray removeAllObjects];
            }
            break;
        default:
            [self error:error];
            break;
    }
    
    [self getDeviceListStatus:error];
}

#pragma mark - AUXACNetworkProtocol
- (void)auxACNetworkDidDiscoveredDeviceList:(NSArray *)deviceList success:(BOOL)success withError:(NSError *)error {
    
    [self hideLoading];
    
    if (success) {
        
        if (self.discoverTimerOfDiscoverFail) {
            [self.discoverTimerOfDiscoverFail invalidate];
            self.discoverTimerOfDiscoverFail = nil;
        }
        
        if ([deviceList count] == 0) {
            return;
        }
        
        AUXUser *user = [AUXUser defaultUser];
        
        // 更新设备列表
        BOOL hasNewDevice = [user updateDeviceDictionaryWithDeviceArray:deviceList deviceDelegate:self];
        
        if (hasNewDevice) {
            [self refrashDeviceStatus];
        }
    } else {
//        [self errorMessage:[NSString stringWithFormat:@"发现设备失败 user.uid--%@ ,\n user.token--%@\n error --%@ \n 设备代理--%@" , [AUXUser defaultUser].uid , [AUXUser defaultUser].token , error , [AUXACNetwork sharedInstance].delegates]];
        
        if (!self.discoverTimerOfDiscoverFail) {

            self.discoverTimerOfDiscoverFail = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(discoverACDeviceTimerOfDiscoverFail) userInfo:nil repeats:YES];
        }
    }
}

#pragma mark - AUXACDeviceProtocol

- (void)auxACNetworkDidQueryWifiOfDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
    
    NSString *mac;
    NSString *typeString;
    
    if (device.bLDevice) {
        mac = device.bLDevice.mac;
        typeString = @"【古北】";
    } else {
        mac = device.gizDevice.macAddress;
        typeString = @"【机智云】";
    }
    
}

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
//        NSLog(@"设备列表界面 设备 %@: %@ 订阅成功", typeString, mac);
        [self refrashDeviceStatus];
    } else {
//        NSLog(@"设备列表界面 设备 %@ %@ 订阅失败 %@", typeString, mac, error);
    }
}

- (void)auxACNetworkDidQueryDevice:(AUXACDevice *)device atAddress:(NSArray *)address success:(BOOL)success withError:(NSError *)error type:(AUXACNetworkQueryType)type {
    
    NSString *mac;
    NSString *typeString;
    
    if (device.bLDevice) {
        mac = device.bLDevice.mac;
        typeString = @"【古北】";
    } else {
        mac = device.gizDevice.macAddress;
        typeString = @"【机智云】";
    }
    
    switch (type) {
        case AUXACNetworkQueryTypeControl:
            //                NSLog(@"设备列表界面 设备 %@ %@ 控制状态上报: %@", typeString, mac, device.controlDic);
            break;
            
        case AUXACNetworkQueryTypeStatus:
//                            NSLog(@"设备列表界面 设备 %@ %@ 运行状态上报: %@", typeString, mac, device.statusDic);
            break;
            
        case AUXACNetworkQueryTypeSubDevices:
            //                NSLog(@"设备列表界面 设备 %@ %@ 子设备列表: %@", typeString, mac, device.aliasDic);
            break;
            
        default:
            break;
    }
}

#pragma mark Notifications
/// 用户登录成功
- (void)userDidLoginNotification:(NSNotification *)notification {
    [self getSaasDeviceList];
}

- (void)userDidLogoutNotification:(NSNotification *)notification {
    if (self.reloadTimer) {
        [self.reloadTimer invalidate];
        self.reloadTimer = nil;
    }
}

#pragma mark getters
- (NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    return [AUXUser defaultUser].deviceInfoArray;
}

- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}

#pragma mark 私有方法
- (void)showLoading {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModelDelegateOfShowLoading)]) {
        [self.delegate viewModelDelegateOfShowLoading];
    }
}

- (void)hideLoading {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModelDelegateOfHideLoading)]) {
        [self.delegate viewModelDelegateOfHideLoading];
    }
}

- (void)error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModelDelegateOfError:)]) {
        [self.delegate viewModelDelegateOfError:error];
    }
}

- (void)errorMessage:(NSString *)message {

    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModelDelegateOfMessage:)]) {
        [self.delegate viewModelDelegateOfMessage:message];
    }
}

- (void)getDeviceListStatus:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModelDelegateOfGetDeviceListStatus:)]) {
        [self.delegate viewModelDelegateOfGetDeviceListStatus:error];
    }
}

- (void)refrashDeviceStatus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModelDelegateOfRefrashDeviceStatus)]) {
        [self.delegate viewModelDelegateOfRefrashDeviceStatus];
    }
}

@end
