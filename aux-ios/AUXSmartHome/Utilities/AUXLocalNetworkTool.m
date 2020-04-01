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

#import "AUXLocalNetworkTool.h"
#import "RACEXTScope.h"

#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

#import <SystemConfiguration/CaptiveNetwork.h>

@implementation AUXLocalNetworkTool

+ (instancetype)defaultTool {
    static AUXLocalNetworkTool *_tool = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[AUXLocalNetworkTool alloc] init];
    });
    
    return _tool;
}

- (void)startMonitoringNetwork {
    self.networkReachability = [AFNetworkReachabilityManager sharedManager];
    [self.networkReachability startMonitoring];
    
    @weakify(self);
    [self.networkReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        if (self.networkStatusChangeBlock) {
            self.networkStatusChangeBlock(status);
        }
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"=================== 网络状态变更: 网络不可达");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"=================== 网络状态变更: 无线广域网");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"=================== 网络状态变更: WiFi");
                break;
                
            default:
                NSLog(@"=================== 网络状态变更: Unknown");
                break;
        }
    }];
}

+ (BOOL)isReachable {
    AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
    return tool.networkReachability.isReachable;
}

+ (BOOL)isReachableViaWifi {
    AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
    return tool.networkReachability.isReachableViaWiFi;
}


+ (NSString *)getCurrentWiFiSSID {
    NSArray *interfaces = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    for (NSString *interface in interfaces) {
        NSDictionary *ssidInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
        NSString *ssid = ssidInfo[(__bridge_transfer NSString *)kCNNetworkInfoKeySSID];
        if ([ssid length] > 0) {
            return ssid;
        }
    }
    return @"";
}

//获取下行速度
- (NSString *)getCurrentNetWorkSpeed {
    
    long long int rate;
    
    long long int currentBytes = [self getInterfaceBytes];
    
    //用上当前的下行总流量减去上一秒的下行流量达到下行速录
    rate = currentBytes - self.lastBytes;
    
    //保存上一秒的下行总流量
    self.lastBytes= [self getInterfaceBytes];
    
    //格式化一下
    NSString *rateStr = [self formatNetWork:rate];
    
    NSLog(@"当前网速%@",rateStr);
    return rateStr;
}
//获取数据流量详情
- (long long int)getInterfaceBytes {
    
    struct ifaddrs*ifa_list =0, *ifa;
    
    if(getifaddrs(&ifa_list) == -1) {
        
        return 0;
    }
    
    uint32_t iBytes =0;//下行
    
    uint32_t oBytes =0;//上行
    
    for(ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        
        if(AF_LINK!= ifa->ifa_addr->sa_family)
            
            continue;
        
        if(!(ifa->ifa_flags&IFF_UP) && !(ifa->ifa_flags&IFF_RUNNING))
            
            continue;
        
        if(ifa->ifa_data==0)
            
            continue;
        
        if(strncmp(ifa->ifa_name,"lo",2)) {
            
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            
            oBytes += if_data->ifi_obytes;
        }
    }
    
    freeifaddrs(ifa_list);
    //返回下行的总流量
    return iBytes;
}

- (NSString*)formatNetWork:(long long int)rate {
    
    if(rate <1024) {
        
        return[NSString stringWithFormat:@"%lldB/秒", rate];
        
    } else if(rate >=1024 && rate <1024*1024) {
        
        return[NSString stringWithFormat:@"%.1fKB/秒", (double)rate /1024];
        
    }else if(rate >=1024*1024 && rate <1024*1024*1024){
        
        return[NSString stringWithFormat:@"%.2fMB/秒", (double)rate / (1024*1024)];
        
    }else{
        return@"10Kb/秒";
    };
}

@end
