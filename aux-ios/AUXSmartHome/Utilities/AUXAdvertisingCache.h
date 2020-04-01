//
//  AUXAdvertisingCache.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/1/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXLaunchAdModel.h"

typedef void(^CompletionBlock)(BOOL result , AUXLaunchAdModel *model);

NS_ASSUME_NONNULL_BEGIN

@interface AUXAdvertisingCache : NSObject

+ (BOOL)saveAdvertisingData:(NSArray <AUXLaunchAdModel *>*)array;

+ (NSMutableArray <AUXLaunchAdModel *>*)readCacheAdvertisingData;

+ (BOOL)editAdvertisingData:(AUXLaunchAdModel *)model;

+ (void)removeCacheAdvertisingData;

+ (void)getCurrentAdvertisinDataCompletion:(CompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
