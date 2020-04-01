//
//  AUXAdvertisingCache.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/1/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAdvertisingCache.h"
#import "NSDate+AUXCustom.h"
#import <YYModel.h>

@implementation AUXAdvertisingCache

+ (BOOL)saveAdvertisingData:(NSArray <AUXLaunchAdModel *>*)array {
    NSMutableArray *dataArray = [NSMutableArray array];
    for (AUXLaunchAdModel *model in array) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        [dataArray addObject:data];
    }
    
    BOOL result = [dataArray writeToFile:[self launchAdCachePath] atomically:YES];
    
    if (result) {
        NSLog(@"%@" , kAUXLocalizedString(@"AdvertisementCacheSuccess"));
    } else {
        NSLog(@"%@" , kAUXLocalizedString(@"AdvertisementCacheFailure"));
    }
    
    return result;
}

+ (NSMutableArray <AUXLaunchAdModel *>*)readCacheAdvertisingData {
    NSArray *array = [NSArray arrayWithContentsOfFile:[self launchAdCachePath]];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSData *data in array) {
        AUXLaunchAdModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [dataArray addObject:model];
    }
    return dataArray;
}

+ (BOOL)editAdvertisingData:(AUXLaunchAdModel *)model {
    
    if (AUXWhtherNullString(model.advertisementId) || model.startTime == model.endTime || model.endTime < model.startTime || model.startTime == 0 || model.endTime == 0) {
        return NO;
    }
    
    NSMutableArray *dataArray = [self readCacheAdvertisingData];
    
    NSMutableArray *removeArray = [NSMutableArray array];
    for (AUXLaunchAdModel *cacheModel in dataArray) {
        if (![cacheModel.advertisementId isEqualToString:model.advertisementId] || AUXWhtherNullString(cacheModel.imageBannerURLString)) {
            [removeArray addObject:cacheModel];
        }
    }
    
        [dataArray removeObjectsInArray:removeArray];
    if (dataArray.count == 0) {
        [dataArray addObject:model];
    }
    
    return [self saveAdvertisingData:dataArray];
}

+ (void)removeCacheAdvertisingData {
    [[NSFileManager defaultManager] removeItemAtPath:[self launchAdCachePath] error:nil];
}

+ (void)getCurrentAdvertisinDataCompletion:(CompletionBlock)completion {
    NSMutableArray *dataArray = [[self readCacheAdvertisingData] mutableCopy];
    
    if (dataArray.count == 0) {
        if (completion) {
            completion(NO , nil);
        }
        return ;
    }
    
    NSMutableArray *removeArray = [NSMutableArray array];
    NSTimeInterval currentTimeInterval = [[NSDate cNowTimestamp] longLongValue] * 1000;
    for (AUXLaunchAdModel *model in dataArray) {
        if (model.startTime <= currentTimeInterval && model.endTime >= currentTimeInterval) {
            if (completion) {
                completion(YES , model);
            }
            return ;
        } else {
            [removeArray addObject:model];
        }
    }
        [dataArray removeObjectsInArray:removeArray];
    
    [self saveAdvertisingData:dataArray];
    
    if (dataArray.count == 0) {
        if (completion) {
            completion(NO , nil);
        }
    }
}

+ (NSString *)launchAdCachePath {
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:@"launchAdCache.data"];
    
}

@end
