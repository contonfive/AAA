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

#import "AUXArchiveTool.h"
#import "AUXUser.h"
#import "NSUserDefaults+AUXCuxtom.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString * const kAUXSSIDCacheKey = @"kSSIDCacheKey";
static NSString * const kAUXAccountCacheKey = @"kAUXAccountCacheKey";
static NSString * const kAUXGrammerIDCacheKey = @"kAUXGrammerIDCacheKey";

static NSString * const kAUXConfigSuccessGuideKey = @"kAUXConfigSuccessGuideKey";

static NSString * const kAUXControlGuideKeyCard = @"kAUXControlGuideKeyCard";
static NSString * const kAUXControlGuideKeyList = @"kAUXControlGuideKeyList";

static NSString * const kAUXControlPrivacyStatement = @"kAUXControlPrivacyStatement";

static NSString * const kAUXNotificationControlGuideKey = @"kAUXNotificationControlGuideKey";

//static NSString * const kAUXUserComponentDeviceID = @"kAUXUserComponentDeviceID";

static NSString * const kAUXLogoutWhenResumeKey = @"kAUXLogoutWhenResumeKey";
static NSString * const kAUXTerminateTimeKey = @"kAUXTerminateTimeKey";
static NSString * const kAUXIgnoreVersionKey = @"kAUXIgnoreVersion%@Key";

static NSString * const kAUXMarqueeMessageKey = @"kAUXMarqueeMessageKey";
static NSString * const kAUXMarqueeBeforeKey = @"kAUXMarqueeBeforeKey";

static NSString * const kAUXAdvertisementKey = @"kAUXAdvertisementKey";

static NSString * const kAUXGuidKey = @"kAUXGuidKey";

static NSString * const kAUXRemoteNotificationKey = @"kAUXRemoteNotificationKey";

static NSString * const kAUXSceneMapSearchHistory = @"kAUXSceneMapSearchHistory";

static NSString * const kAUXAUXDeviceListType = @"kAUXAUXDeviceListType";

static NSString * const kAUXAUXDeviceCount = @"kAUXAUXDeviceCount";

static NSData *AES256EncryptWithKey(NSString *key, NSData *data);
static NSData *AES256DecryptWithKey(NSString *key, NSData *data);
static NSString *makeEncryptKey(Class class, NSString *ssid);


@implementation AUXArchiveTool

#pragma mark 账号密码
+ (void)archiveUserAccount:(NSString *)account {
    
    if ([account length] > 0) {
        
        [[NSUserDefaults shareDefaults] setObject:account forKey:kAUXAccountCacheKey];
        
    } else {
        [[NSUserDefaults shareDefaults] removeObjectForKey:kAUXAccountCacheKey];
    }
    
    [[NSUserDefaults shareDefaults] synchronize];
}

+ (void)removeUserAccount {
    [[NSUserDefaults shareDefaults] removeObjectForKey:kAUXAccountCacheKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

+ (NSString *)getArchiveAccount {
    return [[NSUserDefaults shareDefaults] objectForKey:kAUXAccountCacheKey];
}

+ (void)archiveShouldLogoutWhenResume:(BOOL)logoutWhenResume {
    [[NSUserDefaults shareDefaults] setBool:logoutWhenResume forKey:kAUXLogoutWhenResumeKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

+ (BOOL)shouldLogoutWhenResume {
    return [[NSUserDefaults shareDefaults] boolForKey:kAUXLogoutWhenResumeKey];
}

+ (void)archiveIgnore:(BOOL)ignore version:(NSString *)version {
    [[NSUserDefaults shareDefaults] setBool:ignore forKey:[NSString stringWithFormat:kAUXIgnoreVersionKey, version]];
    [[NSUserDefaults shareDefaults] synchronize];
}

+ (BOOL)shouldIgnoreVersion:(NSString *)version {
    return [[NSUserDefaults shareDefaults] boolForKey:[NSString stringWithFormat:kAUXIgnoreVersionKey, version]];
}

#pragma mark 用来保存极光未点击的数量
+ (NSNumber *)getRemoteNotificationNum {
    NSNumber *index = (NSNumber *)[[NSUserDefaults shareDefaults] objectForKey:kAUXRemoteNotificationKey];
    return index;
}

+ (void)saveRemoteNotificationNum:(NSNumber *)index {
    [[NSUserDefaults shareDefaults] setObject:index forKey:kAUXRemoteNotificationKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

+ (void)clearRemoteNotificationNum {
    [[NSUserDefaults shareDefaults] removeObjectForKey:kAUXRemoteNotificationKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

#pragma mark Wi-Fi ssid & 密码

+ (void)archiveSSID:(NSString *)ssid password:(NSString *)password {
    
    if ([ssid length] > 0 && [password length] > 0) {
        NSDictionary *ssidCacheDictionary = [[NSUserDefaults shareDefaults] objectForKey:kAUXSSIDCacheKey];
        
        NSMutableDictionary *mutableSSIDCacheDictionary;
        
        if (ssidCacheDictionary) {
            mutableSSIDCacheDictionary = [ssidCacheDictionary mutableCopy];
        } else {
            mutableSSIDCacheDictionary = [NSMutableDictionary new];
        }
        
        NSString *encryptKey = makeEncryptKey([self class], ssid);
        NSData *encryptData = AES256EncryptWithKey(encryptKey, [password dataUsingEncoding:NSUTF8StringEncoding]);
        
        [mutableSSIDCacheDictionary setObject:encryptData forKey:ssid];
        
        [[NSUserDefaults shareDefaults] setObject:mutableSSIDCacheDictionary forKey:kAUXSSIDCacheKey];
        [[NSUserDefaults shareDefaults] synchronize];
    }
}

+ (NSString *)passwordForSSID:(NSString *)ssid {
    
    if (!ssid || ssid.length == 0) {
        return nil;
    }
    
    NSDictionary *ssidCacheDictionary = [[NSUserDefaults shareDefaults] objectForKey:kAUXSSIDCacheKey];
    
    NSData *encryptData = [ssidCacheDictionary objectForKey:ssid];
    
    if (encryptData) {
        NSString *encryptKey = makeEncryptKey([self class], ssid);
        NSData *decryptData = AES256DecryptWithKey(encryptKey, encryptData);
        
        NSString *password = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
        
        return password;
    }
    
    return nil;
}

#pragma mark 保存场景地图搜索的历史
+ (void)saveSceneMapSearchData:(NSMutableArray *)data {
    [[NSUserDefaults shareDefaults] setValue:data forKey:kAUXSceneMapSearchHistory];
}

+ (NSMutableArray *)readDataSceneMapSearchHistory {
    NSMutableArray *data = [NSMutableArray array];
    
    [data addObjectsFromArray:[[NSUserDefaults shareDefaults] objectForKey:kAUXSceneMapSearchHistory]];
    return data;
}

+ (void)clearSceneMapSearchHistory {
    [[NSUserDefaults shareDefaults] removeObjectForKey:kAUXSceneMapSearchHistory];
}

#pragma mark 选择小组件的设备
+ (void)saveDataByNSFileManager:(NSArray *)data {
    if (AUXWhtherNullString([AUXUser defaultUser].account)) {
        return ;
    }
    
    [[NSUserDefaults shareDefaults] setValue:data forKey:[AUXUser defaultUser].account];
    
}
+ (NSArray *)readDataByNSFileManager {
    
    if (AUXWhtherNullString([AUXUser defaultUser].account)) {
        return nil;
    }
    
    NSArray *data = [[NSUserDefaults shareDefaults] valueForKey:[AUXUser defaultUser].account];
    
    return data;
}

#pragma mark 科大讯飞

+ (void)archiveIFlyGrammerID:(NSString *)grammerID {
    [[NSUserDefaults shareDefaults] setObject:grammerID forKey:kAUXGrammerIDCacheKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

+ (NSString *)iflyGrammerID {
    return [[NSUserDefaults shareDefaults] objectForKey:kAUXGrammerIDCacheKey];
}

#pragma mark 用户设置列表显示样式
+ (void)saveDeviceListType:(AUXDeviceListType)deviceListType {

    [[NSUserDefaults shareDefaults] setObject:@(deviceListType) forKey:kAUXAUXDeviceListType];
}

+ (AUXDeviceListType)readDeviceListType {
    return [[[NSUserDefaults shareDefaults] objectForKey:kAUXAUXDeviceListType] integerValue] == AUXDeviceListTypeOfGrid ? AUXDeviceListTypeOfGrid : AUXDeviceListTypeOfList;
}

+ (void)removeDeviceListType {
    [[NSUserDefaults shareDefaults] removeObjectForKey:kAUXAUXDeviceListType];
}

#pragma mark 是否显示配置设备成功引导页
+ (BOOL)shouldShowConfigSuccessGuidePage {
    NSNumber *value = [[NSUserDefaults shareDefaults] objectForKey:kAUXConfigSuccessGuideKey];
    
    if (value == nil || value == NULL) {
        return YES;
    }
    
    return value.boolValue;
}

+ (void)setShouldShowConfigSuccessGuidePage:(BOOL)value {
    [[NSUserDefaults shareDefaults] setBool:value forKey:kAUXConfigSuccessGuideKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

#pragma mark 是否显示控制指引页
+ (BOOL)shouldShowControlGuide {
    BOOL result = [[self class] shouldShowControlGuidePageCard] || [[self class] shouldShowControlGuidePageList];
    return result;
}

+ (BOOL)shouldShowControlGuidePageCard {
    NSNumber *value = [[NSUserDefaults shareDefaults] objectForKey:kAUXControlGuideKeyCard];
    if (!value) {
        return YES;
    }
    
    return value.boolValue;
}

+ (BOOL)shouldShowControlGuidePageList {
    NSNumber *value = [[NSUserDefaults shareDefaults] objectForKey:kAUXControlGuideKeyList];
    if (!value) {
        return YES;
    }
    
    return value.boolValue;
}

+ (void)setShouldShowControlGuidePage:(AUXDeviceListType)value {
    
    if (value == AUXDeviceListTypeOfList) {
        [[NSUserDefaults shareDefaults] setBool:NO forKey:kAUXControlGuideKeyList];
    } else {
        [[NSUserDefaults shareDefaults] setBool:NO forKey:kAUXControlGuideKeyCard];
    }
    
    [[NSUserDefaults shareDefaults] synchronize];
}

#pragma mark 是否显示隐私声明
+ (BOOL)shouldShowPrivacy {
    NSNumber *value = [[NSUserDefaults shareDefaults] objectForKey:kAUXControlPrivacyStatement];

    return !value.boolValue;
}

+ (void)setShouldShowPrivacy:(BOOL)value {
    [[NSUserDefaults shareDefaults] setBool:value forKey:kAUXControlPrivacyStatement];
    [[NSUserDefaults shareDefaults] synchronize];
}

#pragma mark 是否显示控制栏组件使用提示
+ (BOOL)shouldShowNotificationControlGuidePage {
    NSNumber *value = [[NSUserDefaults shareDefaults] objectForKey:kAUXNotificationControlGuideKey];
    
    if (!value) {
        return YES;
    }
    
    return value.boolValue;
}

+ (void)setShouldShowNotificationControlGuidePage:(BOOL)value {
    [[NSUserDefaults shareDefaults] setBool:value forKey:kAUXNotificationControlGuideKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

#pragma mark 是否是新版本

+ (BOOL)shouldShowAdvertisementForVersion:(NSString *)version {
    NSString *localVersion = [[NSUserDefaults shareDefaults] objectForKey:kAUXAdvertisementKey];
    
    BOOL value = YES;
    
    if (version && localVersion && [localVersion isEqualToString:version]) {
        value = NO;
    }
    
    return value;
}

+ (void)hasShownAdvertisementForVersion:(NSString *)version {
    [[NSUserDefaults shareDefaults] setObject:version forKey:kAUXAdvertisementKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

#pragma mark 是否需要显示引导页
+ (BOOL)shouldShowGuidPage:(NSInteger)index {
    
    NSInteger currentIndex = [[[NSUserDefaults shareDefaults] objectForKey:kAUXGuidKey] integerValue];
    
    if (index > currentIndex) {
        return YES;
    }
    
    return NO;
}

+ (void)hasShowGuidPage:(NSInteger)index {
    [[NSUserDefaults shareDefaults] setObject:@(index) forKey:kAUXGuidKey];
    [[NSUserDefaults shareDefaults] synchronize];
}

@end


#pragma mark - C method implementations
#pragma mark Private

static NSData *AES256EncryptWithKey(NSString *key, NSData *data) {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

static NSData *AES256DecryptWithKey(NSString *key, NSData *data) {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

static NSString *makeEncryptKey(Class class, NSString *ssid) {
    NSString *tmpEncryptKey = NSStringFromClass(class);
    tmpEncryptKey = [tmpEncryptKey stringByAppendingString:@"_"];
    tmpEncryptKey = [tmpEncryptKey stringByAppendingString:ssid];
    tmpEncryptKey = [tmpEncryptKey stringByAppendingString:@"_"];
    
    unsigned char result[16] = { 0 };
    CC_MD5(tmpEncryptKey.UTF8String, (CC_LONG)tmpEncryptKey.length, result);
    NSString *ret = @"";
    
    for (int i = 0; i < 16; i++) {
        ret = [ret stringByAppendingFormat:@"%02X", result[i]];
    }
    
    return ret;
}
