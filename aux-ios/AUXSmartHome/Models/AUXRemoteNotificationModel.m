//
//  AUXRemoteNotificationModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXRemoteNotificationModel.h"
#import "AUXConstant.h"
#import "NSUserDefaults+AUXCuxtom.h"
#import "NSDate+AUXCustom.h"

static NSString * const kAUXRemoteTempSourceValue = @"kAUXRemoteTempSourceValue";
static NSString * const kAUXRemoteTitle = @"kAUXRemoteTitle";
static NSString * const kAUXRemoteBody = @"kAUXRemoteBody";
static NSString * const kAUXRemoteBadge = @"kAUXRemoteBadge";
static NSString * const kAUXRemoteImageUrl = @"kAUXRemoteImageUrl";
static NSString * const kAUXRemoteLinkedUrl = @"kAUXRemoteLinkedUrl";
static NSString * const kAUXRemoteSourceType = @"kAUXRemoteSourceType";
static NSString * const kAUXRemotePlatform = @"kAUXRemotePlatform";
static NSString * const kAUXRemoteType = @"kAUXRemoteType";
static NSString * const kAUXRemotePushTime = @"kAUXRemotePushTime";
static NSString * const kAUXRemoteDateTime = @"kAUXRemoteDateTime";
static NSString * const kAUXRemoteJMsgid = @"kAUXRemoteJMsgid";
static NSString * const kAUXRemotePushType = @"kAUXRemotePushType";

static NSString * const kAUXAUXRemoteNotificationList = @"kAUXAUXRemoteNotificationList";


@implementation AUXRemoteNotificationModel

+ (instancetype)sharedInstance {
    static AUXRemoteNotificationModel *remoteNotification = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remoteNotification = [[AUXRemoteNotificationModel alloc]init];
    });
    return remoteNotification;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.tempSourceValue = [aDecoder decodeObjectForKey:kAUXRemoteTempSourceValue];
        self.body = [aDecoder decodeObjectForKey:kAUXRemoteBody];
        self.title = [aDecoder decodeObjectForKey:kAUXRemoteTitle];
        self.imageUrl = [aDecoder decodeObjectForKey:kAUXRemoteImageUrl];
        self.linkedUrl = [aDecoder decodeObjectForKey:kAUXRemoteLinkedUrl];
        
        self.sourceType = [aDecoder decodeObjectForKey:kAUXRemoteSourceType];
        self.sourceValue = [aDecoder decodeObjectForKey:kAUXRemoteTempSourceValue];
        self.platform = [aDecoder decodeObjectForKey:kAUXRemotePlatform];
        self.type = [aDecoder decodeObjectForKey:kAUXRemoteType];
        self.pushTime = [aDecoder decodeObjectForKey:kAUXRemotePushTime];
        self.dateTime = [aDecoder decodeObjectForKey:kAUXRemoteDateTime];
        self._j_msgid = [aDecoder decodeObjectForKey:kAUXRemoteJMsgid];
        self.pushType = [aDecoder decodeObjectForKey:kAUXRemotePushType];
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.tempSourceValue forKey:kAUXRemoteTempSourceValue];
    [aCoder encodeObject:self.body forKey:kAUXRemoteBody];
    [aCoder encodeObject:self.title forKey:kAUXRemoteTitle];
    [aCoder encodeObject:self.imageUrl forKey:kAUXRemoteImageUrl];
    [aCoder encodeObject:self.linkedUrl forKey:kAUXRemoteLinkedUrl];
    [aCoder encodeObject:self.pushType forKey:kAUXRemotePushType];
    
    [aCoder encodeObject:self.sourceType forKey:kAUXRemoteSourceType];
    [aCoder encodeObject:self.sourceValue forKey:kAUXRemoteTempSourceValue];
    [aCoder encodeObject:self.platform forKey:kAUXRemotePlatform];
    [aCoder encodeObject:self.type forKey:kAUXRemoteType];
    [aCoder encodeObject:self.pushTime forKey:kAUXRemotePushTime];
    [aCoder encodeObject:self.dateTime forKey:kAUXRemoteDateTime];
    [aCoder encodeObject:self._j_msgid forKey:kAUXRemoteJMsgid];
    
}

/// 归档路径
- (NSString *)archivePath {
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:@"remoteNotificationList.data"];
}

/// 归档
- (void)archiveRemoteNotificationList:(AUXRemoteNotificationModel *)remoteNotificationModel {
    
    if (![remoteNotificationModel.pushType isEqualToString:@"tag"]) {
        return ;
    }
    
    NSMutableArray *dataListArray = [NSMutableArray arrayWithContentsOfFile:[self archivePath]];
    NSMutableArray *dataList = [NSMutableArray array];
    
    if (dataListArray.count == 0) {
        dataListArray = [NSMutableArray array];
        NSData *remoteNotificationModelData = [NSKeyedArchiver archivedDataWithRootObject:remoteNotificationModel];
        [dataListArray addObject:remoteNotificationModelData];
    } else {
        
        for (NSData *data in dataListArray) {
            AUXRemoteNotificationModel *remoteModel = (AUXRemoteNotificationModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
            [dataList addObject:remoteModel._j_msgid];
        }
        
        if (![dataList containsObject:remoteNotificationModel._j_msgid]) {
            NSData *remoteNotificationModelData = [NSKeyedArchiver archivedDataWithRootObject:remoteNotificationModel];
            if (remoteNotificationModelData !=nil) {
                [dataListArray insertObject:remoteNotificationModelData atIndex:0];
            }
        }
        
        if (dataListArray.count == dataList.count) {
            return ;
        }
    }
    
    [dataListArray writeToFile:[self archivePath] atomically:YES];
    
    BOOL result = [dataListArray writeToFile:[self archivePath] atomically:YES];
    
    if (result) {
        NSLog(@"缓存成功");
    } else {
        NSLog(@"缓存失败");
    }
}

/// 解档
- (NSMutableArray *)unarchiveRemoteNotificationList {
    NSArray *dataArray = [NSArray arrayWithContentsOfFile:[self archivePath]];
    
    if (dataArray.count == 0 || !dataArray) {
        return nil;
    }
    
    NSMutableArray *dataList = [NSMutableArray array];
    NSMutableArray *sumDataArray = [NSMutableArray array];
    
    for (NSData *data in dataArray) {
        AUXRemoteNotificationModel *beforeRemoteModel = (AUXRemoteNotificationModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [dataList addObject:beforeRemoteModel];
    }
    
    NSMutableArray *keyList = [NSMutableArray array];
    
    for (AUXRemoteNotificationModel *model in dataList) {
        NSString *keyTime = [NSDate distanceTimeWithBeforeTime:model.dateTime];
        if (![keyList containsObject:keyTime]) {
            [keyList addObject:keyTime];
        }
    }
    
    for (NSString *keyTime in keyList) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        for (AUXRemoteNotificationModel *remoteModel in dataList) {
            if ([[NSDate distanceTimeWithBeforeTime:remoteModel.dateTime] isEqualToString:keyTime]) {
                [keyArray addObject:remoteModel];
            }
        }
        [dataDict setObject:keyArray forKey:keyTime];
        [sumDataArray addObject:dataDict];
    }
    
    return sumDataArray;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
