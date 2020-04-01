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

#import "AUXUser.h"
#import "AppDelegate.h"
#import "AUXArchiveTool.h"
#import "AUXConstant.h"
#import "JPUSHService.h"
#import "AUXNetworkManager.h"
#import "NSUserDefaults+AUXCuxtom.h"

static NSString * const kAUXUserUid = @"kAUXUserUid";
static NSString * const kAUXUserToken = @"kAUXUserToken";
static NSString * const kAUXAccessToken = @"kAUXAccessToken";
static NSString * const kAUXAccessTokenExpireDate = @"kAUXAccessTokenExpireDate";
static NSString * const kAUXUserMacArray = @"kAUXUserMacArray";
static NSString * const kAUXUserJustRegister = @"kAUXUserJustRegister";
static NSString * const kAUXUserNeedBindInFirstTime = @"kAUXUserNeedBindInFirstTime";

static NSString * const kAUXUserNickName = @"kAUXUserNickName";
static NSString * const kAUXUserRealName = @"kAUXUserRealName";
static NSString * const kAUXUserHeadImg = @"kAUXUserHeadImg";
static NSString * const kAUXUserGender = @"kAUXUserGender";
static NSString * const kAUXUserBirthday = @"kAUXUserBirthday";
static NSString * const kAUXUserCountry = @"kAUXUserCountry";
static NSString * const kAUXUserRegion = @"kAUXUserRegion";
static NSString * const kAUXUserCity = @"kAUXUserCity";

static NSString * const kAUXUserPortrait = @"kAUXUserPortrait";

static NSString * const kAUXUserPhone = @"kAUXUserPhone";
static NSString * const kAUXUserOpenId = @"kAUXUserOpenId";
static NSString * const kAUXUserQQId = @"kAUXUserQQId";
static NSString * const kAUXUserAccount = @"kAUXUserAccount";

static NSString * const kAUXUserDeviceToken = @"kAUXUserDeviceToken";

static NSString * const kAUXUserData = @"kAUXUserData";

@interface AUXUser ()
@property (nonatomic,copy) NSString *archivePhone;
@end

@implementation AUXUser

+ (instancetype)defaultUser {
    
    static AUXUser *user = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [AUXUser unarchiveUser];
    });
    return user;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.uid = [aDecoder decodeObjectForKey:kAUXUserUid];
        self.token = [aDecoder decodeObjectForKey:kAUXUserToken];
        self.accessToken = [aDecoder decodeObjectForKey:kAUXAccessToken];
        self.justRegister = [[aDecoder decodeObjectForKey:kAUXUserJustRegister] boolValue];
        self.needBindInFirstTIme = [[aDecoder decodeObjectForKey:kAUXUserNeedBindInFirstTime] boolValue];
        
        self.nickName = [aDecoder decodeObjectForKey:kAUXUserNickName];
        self.realName = [aDecoder decodeObjectForKey:kAUXUserRealName];
        self.headImg = [aDecoder decodeObjectForKey:kAUXUserHeadImg];
        self.gender = [aDecoder decodeObjectForKey:kAUXUserGender];
        self.birthday = [aDecoder decodeObjectForKey:kAUXUserBirthday];
        self.country = [aDecoder decodeObjectForKey:kAUXUserCountry];
        self.region = [aDecoder decodeObjectForKey:kAUXUserRegion];
        self.city = [aDecoder decodeObjectForKey:kAUXUserCity];
        
        self.portrait = [aDecoder decodeObjectForKey:kAUXUserPortrait];
        
        self.phone = [aDecoder decodeObjectForKey:kAUXUserPhone];
        self.openid = [aDecoder decodeObjectForKey:kAUXUserOpenId];
        self.qqid = [aDecoder decodeObjectForKey:kAUXUserQQId];
        self.account = [aDecoder decodeObjectForKey:kAUXUserAccount];
        
        self.deviceToken = [aDecoder decodeObjectForKey:kAUXUserDeviceToken];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uid forKey:kAUXUserUid];
    [aCoder encodeObject:self.token forKey:kAUXUserToken];
    [aCoder encodeObject:self.accessToken forKey:kAUXAccessToken];
    [aCoder encodeObject:@(self.justRegister) forKey:kAUXUserJustRegister];
    [aCoder encodeObject:@(self.needBindInFirstTIme) forKey:kAUXUserNeedBindInFirstTime];
    
    [aCoder encodeObject:self.nickName forKey:kAUXUserNickName];
    [aCoder encodeObject:self.realName forKey:kAUXUserRealName];
    [aCoder encodeObject:self.headImg forKey:kAUXUserHeadImg];
    [aCoder encodeObject:self.gender forKey:kAUXUserGender];
    [aCoder encodeObject:self.birthday forKey:kAUXUserBirthday];
    [aCoder encodeObject:self.country forKey:kAUXUserCountry];
    [aCoder encodeObject:self.region forKey:kAUXUserRegion];
    [aCoder encodeObject:self.city forKey:kAUXUserCity];
    
    [aCoder encodeObject:self.portrait forKey:kAUXUserPortrait];
    
    [aCoder encodeObject:self.phone forKey:kAUXUserPhone];
    [aCoder encodeObject:self.openid forKey:kAUXUserOpenId];
    [aCoder encodeObject:self.qqid forKey:kAUXUserQQId];
    [aCoder encodeObject:self.account forKey:kAUXUserAccount];
    
    [aCoder encodeObject:self.deviceToken forKey:kAUXUserDeviceToken];
    
}

/// 归档路径
+ (NSString *)archivePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    path = [path stringByAppendingPathComponent:@"user.data"];
    
    return path;
}

/// 归档
+ (void)archiveUser {
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:[self defaultUser]];
    
    [[NSUserDefaults shareDefaults] setObject:userData forKey:kAUXUserData];
    [[NSUserDefaults shareDefaults] synchronize];
}

/// 解档
+ (AUXUser *)unarchiveUser {
    AUXUser *user;
    
    NSData *userData = [[NSUserDefaults shareDefaults] objectForKey:kAUXUserData];
    id unarchiveObject = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    
    if (unarchiveObject) {
        user = (AUXUser *)unarchiveObject;
    } else {
        user = [[AUXUser alloc] init];
    }
    
    return user;
}

/// 手机唯一标识符
+ (NSString *)UUIDString {
    return [[UIDevice currentDevice].identifierForVendor.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)account {
    if (!AUXWhtherNullString(self.phone)) {
        _account = self.phone;
    }
    
    if (!AUXWhtherNullString(self.openid)) {
        _account = self.openid;
    } else if (!AUXWhtherNullString(self.qqid)) {
        _account = self.qqid;
    } 
    
    return _account;
}

+ (BOOL)isLogin {
    
    if ([AUXUser defaultUser].uid && [AUXUser defaultUser].token) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isBindAccount {
    if (AUXWhtherNullString([AUXUser defaultUser].phone)) {
        return NO;
    }
    return YES;
}

- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {
    if (!_deviceInfoArray) {
        _deviceInfoArray = [[NSMutableArray alloc] init];
    }
    
    return _deviceInfoArray;
}

- (NSMutableDictionary<NSString *,AUXACDevice *> *)deviceDictionary {
    if (!_deviceDictionary) {
        _deviceDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return _deviceDictionary;
}

- (NSArray<AUXACDevice *> *)deviceArray {
    return self.deviceDictionary.allValues;
}

- (void)logout {
    self.uid = nil;
    self.token = nil;
    [AUXUser archiveUser];
    
    [JPUSHService deleteTags:[NSSet setWithObjects:self.archivePhone , [[self class] UUIDString] , nil] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        NSLog(@"delete tags code: %ld, iTags: %@, seq: %ld", (long) iResCode, iTags, (long) seq);
        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
            NSLog(@"delete alias code: %ld, alias: %@, seq: %ld", (long) iResCode, iAlias, (long) seq);
            
        } seq:70];
    } seq:80];
    
    // 取消设备订阅
    for (AUXACDevice *device in self.deviceArray) {
        [[AUXACNetwork sharedInstance] unsubscribeDevice:device withType:device.deviceType];
        [device.delegates removeAllObjects];
    }
    
    [AUXArchiveTool clearRemoteNotificationNum];
//    [AUXArchiveTool removeDeviceListType];
    [self.deviceInfoArray removeAllObjects];
    [self.deviceDictionary removeAllObjects];
}

- (void)addDevicesDelegate:(id<AUXACDeviceProtocol>)delegate {
    for (AUXACDevice *device in self.deviceArray) {
        if ([device.delegates containsObject:delegate]) {
            continue;
        }
        
        [device.delegates addObject:delegate];
    }
}

- (void)removeDevicesDelegate:(id<AUXACDeviceProtocol>)delegate {
    for (AUXACDevice *device in self.deviceArray) {
        if (![device.delegates containsObject:delegate]) {
            continue;
        }
        
        [device.delegates removeObject:delegate];
    }
}

- (BOOL)updateDeviceDictionaryWithDeviceArray:(NSArray<AUXACDevice *> *)deviceArray deviceDelegate:(id<AUXACDeviceProtocol>)delegate {
    NSArray<NSString *> *boundMacArray = [self.deviceInfoArray valueForKeyPath:@"mac"];
    
    BOOL hasNewDevices = NO;
    
    for (AUXACDevice *tempDevice in deviceArray) {
        AUXACDevice *device = tempDevice;
        
        NSString *mac = [device getMac];
        
        // 判断设备是否已绑定
        if (![boundMacArray containsObject:mac]) {
            continue;
        }
        
        NSInteger index = [boundMacArray indexOfObject:mac];
        AUXDeviceInfo *deviceInfo = self.deviceInfoArray[index];
        
        AUXACDevice *existedDevice = [self.deviceDictionary objectForKey:deviceInfo.deviceId];
        
        // 设备已存在
        if (existedDevice || [existedDevice isEqual:device]) {
            
            // 旧设备，当 key 或者 password 改变之后，需要重新订阅设备
            if (device.bLDevice && (![device.bLDevice.key isEqualToString:deviceInfo.deviceKey] || device.bLDevice.password != deviceInfo.password.integerValue)) {
//                NSLog(@"\t\t 该设备已失效，重新创建对象...");
                NSInteger terminalId = deviceInfo.terminalId == 0 ? 1 : deviceInfo.terminalId;
                [device.delegates removeAllObjects];
                device = [[AUXACDeviceManager sharedInstance] createBLDeviceWithMac:deviceInfo.mac password:(uint32_t)deviceInfo.password.integerValue key:deviceInfo.deviceKey alias:deviceInfo.alias type:deviceInfo.type terminal_id:terminalId];
            } else {
//                if (device.gizDevice) {
//                    [[AUXACNetwork sharedInstance] subscribeDevice:device withType:device.deviceType];
//                    NSLog(@"触发重复订阅");
//                }
                continue;
            }
        }
        
        hasNewDevices = YES;
        
//        NSLog(@"\t\t 存储该设备到 deviceDictionary...");
        [self.deviceDictionary setObject:device forKey:deviceInfo.deviceId];
        
        // 设置设备代理
        if (delegate) {
            [device.delegates addObject:delegate];
        }
        
        // 如果是多联机设备，则查询子设备列表
        if (deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
            device.needQuerySubDevice = YES;
            [device setNeedUpdateSubDevice];
            
            device.needQuerySubDeviceAliases = YES;
            [device setNeedUpdateSubDeviceAliases];
        }
        
        // 订阅设备
        [[AUXACNetwork sharedInstance] subscribeDevice:device withType:device.deviceType];
    }
    
    return hasNewDevices;
}

- (void)createOldDevicesIfNeededWithDeviceDelegate:(id<AUXACDeviceProtocol>)delegate {
    for (AUXDeviceInfo *deviceInfo in self.deviceInfoArray) {
        if (deviceInfo.source == AUXDeviceSourceGizwits) {
            continue;
        }
        
        AUXACDevice *device = self.deviceDictionary[deviceInfo.deviceId];
        
        if (device) {
            continue;
        }
        
//        NSLog(@"AUXUser 创建【古北】设备 %@ ", deviceInfo.mac);
        NSInteger terminalId = deviceInfo.terminalId == 0 ? 1 : deviceInfo.terminalId;
        device = [[AUXACDeviceManager sharedInstance] createBLDeviceWithMac:deviceInfo.mac password:(uint32_t)deviceInfo.password.integerValue key:deviceInfo.deviceKey alias:deviceInfo.alias type:deviceInfo.type terminal_id:terminalId];
        
        [self.deviceDictionary setObject:device forKey:deviceInfo.deviceId];
        
        if (delegate) {
            [device.delegates addObject:delegate];
        }
        
        // 如果是多联机设备，则查询子设备列表
        if (deviceInfo.suitType == AUXDeviceSuitTypeGateway) {
            device.needQuerySubDevice = YES;
            [device setNeedUpdateSubDevice];
            
            device.needQuerySubDeviceAliases = YES;
            [device setNeedUpdateSubDeviceAliases];
        }
        
        // 订阅设备
        [[AUXACNetwork sharedInstance] subscribeDevice:device withType:device.deviceType];
    }
}

- (AUXDeviceInfo *)getDeviceInfoWithMac:(NSString *)mac {
    AUXDeviceInfo *deviceInfo = nil;
    
    NSArray<NSString *> *boundMacArray = [self.deviceInfoArray valueForKeyPath:@"mac"];
    
    if ([boundMacArray containsObject:mac]) {
        NSInteger index = [boundMacArray indexOfObject:mac];
        deviceInfo = self.deviceInfoArray[index];
    }
    
    return deviceInfo;
}

- (AUXACDevice *)getSDKDeviceWithMac:(NSString *)mac {
    AUXACDevice *sdkDevice = nil;
    
    AUXDeviceInfo *deviceInfo = [self getDeviceInfoWithMac:mac];
    
    if (deviceInfo) {
        sdkDevice = self.deviceDictionary[deviceInfo.deviceId];
    }
    
    return sdkDevice;
}

- (NSArray<AUXAudioDevice *> *)convertToAudioDeviceList {
    NSMutableArray<AUXAudioDevice *> *audioDeviceList = [[NSMutableArray alloc] init];
    
    for (AUXDeviceInfo *deviceInfo in self.deviceInfoArray) {
        AUXACDevice *device = self.deviceDictionary[deviceInfo.deviceId];
        deviceInfo.device = device;
        
        if (!device) {
            continue;
        }
        
        // 单元机设备
        if (deviceInfo.suitType == AUXDeviceSuitTypeAC) {
            
            AUXACControl *deviceControl = device.controlDic[kAUXACDeviceAddress];
            AUXACStatus *deviceStatus = device.statusDic[kAUXACDeviceAddress];
            
            if (!deviceControl) {
                continue;
            }
            
            AUXAudioDevice *audioDevice = [[AUXAudioDevice alloc] init];
            [audioDevice setValueWithDeviceInfo:deviceInfo deviceControl:deviceControl deviceStatus:deviceStatus];
            
            audioDevice.alias = deviceInfo.alias;
            audioDevice.address = kAUXACDeviceAddress.integerValue;
            
            [audioDeviceList addObject:audioDevice];
            
        } else {    // 多联机
            for (NSString *address in device.aliasDic.allKeys) {
                
                // 现在多联机不查询全部子设备的状态，所以只能拿一个控制对象来用。
                AUXACControl *deviceControl = device.controlDic.allValues.firstObject;
                AUXACStatus *deviceStatus = device.statusDic[address];
                
                if (!deviceControl) {
                    continue;
                }
                
                AUXAudioDevice *audioDevice = [[AUXAudioDevice alloc] init];
                [audioDevice setValueWithDeviceInfo:deviceInfo deviceControl:deviceControl deviceStatus:deviceStatus];
                
                audioDevice.alias = device.aliasDic[address];
                
                unsigned int nAddress;
                [[NSScanner scannerWithString:address] scanHexInt:&nAddress];
                
                audioDevice.address = nAddress;
                
                [audioDeviceList addObject:audioDevice];
            }
        }
    }
    
    return audioDeviceList;
}

- (void)setUid:(NSString *)uid {
    _uid = uid;
    if (uid) {
//        self.phone = nil;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JPUSHService setAlias:_uid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                NSLog(@"set alias code: %ld, alias: %@, seq: %ld", (long) iResCode, iAlias, (long) seq);
            } seq:0];
        });
    }
}

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
}

- (void)setToken:(NSString *)token {
    _token = token;
}

- (void)setPhone:(NSString *)phone {
    _phone = phone;
    
    if (_phone) {
        self.archivePhone = phone;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JPUSHService addTags:[NSSet setWithObjects:phone, [[self class] UUIDString] , nil] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                NSLog(@"add tags code: %ld, iTags: %@, seq: %ld", (long) iResCode, iTags, (long) seq);
            } seq:0];
        });
        
    }
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
