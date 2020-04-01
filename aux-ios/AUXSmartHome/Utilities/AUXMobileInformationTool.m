//
//  AUXMobileInformationTool.m
//  AUXSmartHome
//
//  Created by fengchuang on 2019/3/9.
//  Copyright © 2019 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXMobileInformationTool.h"
#import <sys/sysctl.h>
NSString * const KEY_UDID_INSTEAD = @"com.auxgroup.smartac";

@implementation AUXMobileInformationTool
+ (NSString*)deviceType {
    size_t size;
    int nR = sysctlbyname("hw.machine",NULL, &size,NULL,0);
    char *machine = (char*)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size,NULL,0);
    NSString *deviceString = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if ([deviceString isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])  return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])  return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])  return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])  return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])  return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,3"])  return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])  return @"iPhone 7 plus";
    if ([deviceString isEqualToString:@"iPhone9,2"])  return @"iPhone 7 plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])  return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])  return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,5"])  return @"iPhone 8 plus";
    if ([deviceString isEqualToString:@"iPhone10,2"])  return @"iPhone 8 plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])  return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])  return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])  return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])  return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])  return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])  return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])  return @"iPhone XS Max";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])   return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])   return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])   return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])   return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])   return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])   return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])   return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])   return @"iPad mini (CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])   return @"iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])   return @"iPad 3(CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])   return @"iPad 3(4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])   return @"iPad 4 (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad3,5"])   return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])   return @"iPad 4 (CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])   return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])   return @"iPad Air 2";
    
    if ([deviceString isEqualToString:@"i386"])    return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])   return @"Simulator";
    if ([deviceString isEqualToString:@"iPad4,4"]||[deviceString isEqualToString:@"iPad4,5"]||[deviceString isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"]||[deviceString isEqualToString:@"iPad4,8"]||[deviceString isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"]||[deviceString isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    if ([deviceString isEqualToString:@"iPad6,7"])   return @"iPad Pro (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad6,8"])   return @"iPad Pro (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad6,3"])   return @"iPad Pro (9.7-inch)";
    if ([deviceString isEqualToString:@"iPad6,4"])   return @"iPad Pro (9.7-inch)";
    if ([deviceString isEqualToString:@"iPad6,11"])   return @"iPad(5G)";
    if ([deviceString isEqualToString:@"iPad6,12"])   return @"iPad(5G)";
    if ([deviceString isEqualToString:@"iPad7,2"])   return @"iPad Pro (12.9-inch, 2g)";
    if ([deviceString isEqualToString:@"iPad7,1"])   return @"iPad Pro(12.9-inch, 2g)";
    if ([deviceString isEqualToString:@"iPad7,3"])   return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,4"])   return @"iPad Pro (10.5-inch)";
    
    return  deviceString;
}

+ (NSString*)deviceVersion{
     CGFloat vsion = [[[UIDevice currentDevice] systemVersion] floatValue] ;
    return [NSString stringWithFormat:@"%f",vsion];
}

+ (NSString*)appVersion{
    NSDictionary * dicInfo = [[NSBundle mainBundle] infoDictionary];
    NSString * appVersionStr = [dicInfo objectForKey:@"CFBundleShortVersionString"];
    return appVersionStr;
}

+(NSString *)getDeviceIDInKeychain {
    NSString *getUDIDInKeychain = (NSString *)[AUXMobileInformationTool load:KEY_UDID_INSTEAD];
    if (!getUDIDInKeychain ||[getUDIDInKeychain isEqualToString:@""]||[getUDIDInKeychain isKindOfClass:[NSNull class]]) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        [AUXMobileInformationTool save:KEY_UDID_INSTEAD data:result];
        getUDIDInKeychain = (NSString *)[AUXMobileInformationTool load:KEY_UDID_INSTEAD];
    }
    return getUDIDInKeychain;
}


+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}


@end
