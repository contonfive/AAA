//
//  AUXNotificationTools.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXNotificationTools.h"
#import "AUXArchiveTool.h"
#import "AUXTouchRemoteOrShareLink.h"
#import "AUXConstant.h"
#import "NSDate+AUXCustom.h"

@implementation AUXNotificationTools

+ (void)analyseMessageModel:(AUXMessageContentModel *)messageInfoModel completion:(void (^)(AUXMessageContentModel *messageInfoModel, BOOL opURLSuccess))completion {
    
    if (!messageInfoModel) {
        return ;
    }
    
    AUXMessageContentModel *contentModel = messageInfoModel;
    
    if ([contentModel.sourceValue isEqualToString:contentModel.linkedUrl]) {
        contentModel.sourceValue = contentModel.tempSourceValue;
    }
    
    if (contentModel && [contentModel.type isEqualToString:@"jump"]) {
        
        if ([contentModel.sourceType isEqualToString:@"schema"]) {
            NSURL *schemeURL = [NSURL URLWithString:contentModel.sourceValue];
            if ([[UIApplication sharedApplication] canOpenURL:schemeURL]) {
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:schemeURL options:@{} completionHandler:^(BOOL success) {
                            completion(contentModel , success);
                        }];
                    } else {
                        BOOL result = [[UIApplication sharedApplication] openURL:schemeURL];
                        if (completion) {
                            completion(contentModel , result);
                        }
                    }
                }
            } else {
                contentModel.tempSourceValue = contentModel.sourceValue;
                contentModel.sourceValue = contentModel.linkedUrl;
                
                if (completion) {
                    completion(contentModel , NO);
                }
            }
        } else if([contentModel.sourceType isEqualToString:@"local"]) {
            
            if (completion) {
                completion(contentModel , NO);
            }
        }
    }
}

+ (AUXRemoteNotificationModel *)contentModelWithPushLaunchUserInfo:(NSDictionary *)pushLaunchUserInfo {
    if (pushLaunchUserInfo == nil) {
        return nil;
    }
    
    AUXRemoteNotificationModel *contentModel = [[AUXRemoteNotificationModel alloc]init];
    
    NSDictionary *content = pushLaunchUserInfo;
    
    NSString *pushTime = [NSDate getCurrentTimes];
    NSString *timeKey = pushTime;
    
    NSMutableDictionary *dict = [pushLaunchUserInfo mutableCopy];
    [dict setObject:pushTime forKey:@"pushTime"];
    [dict setObject:timeKey forKey:@"dateTime"];
    [contentModel yy_modelSetWithDictionary:dict];
    [contentModel yy_modelSetWithDictionary:content];
    
    return contentModel;
}

+ (void)analysePushLaunchUserInfo:(NSDictionary *)pushLaunchUserInfo completion:(void (^)(AUXRemoteNotificationModel *messageInfoModel, BOOL opURLSuccess))completion {
    
    if (pushLaunchUserInfo == nil) {
        return ;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:pushLaunchUserInfo];
    [dict removeObjectForKey:@"aps"];
    
    id alert = pushLaunchUserInfo[@"aps"][@"alert"];
    
    if ([alert isKindOfClass:[NSDictionary class]]) {
        [dict setValuesForKeysWithDictionary:alert];
    } else if ([alert isKindOfClass:[NSString class]]) {
        [dict setValue:alert forKey:@"body"];
    }

    if (dict && [dict[@"type"] isEqualToString:@"jump"]) {
        
        int index = [[AUXArchiveTool getRemoteNotificationNum] intValue];
        index++;
        [AUXArchiveTool saveRemoteNotificationNum:@(index)];
        
    }
    
    AUXRemoteNotificationModel *contentModel = [self contentModelWithPushLaunchUserInfo:dict];
    
    if (!contentModel) {
        return ;
    }
    
    if (contentModel) {
        [[AUXRemoteNotificationModel sharedInstance] archiveRemoteNotificationList:contentModel];
    }
    
    if (contentModel && [contentModel.type isEqualToString:@"jump"]) {
        
        int index = [[AUXArchiveTool getRemoteNotificationNum] intValue];
        index--;
        if (index <= 0 ) {
            index = 0;
        }
        [AUXArchiveTool saveRemoteNotificationNum:@(index)];
        
        if ([contentModel.sourceType isEqualToString:@"schema"]) {
            NSURL *schemeURL = [NSURL URLWithString:contentModel.sourceValue];
            if ([[UIApplication sharedApplication] canOpenURL:schemeURL]) {
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:schemeURL options:@{} completionHandler:^(BOOL success) {
                            completion(contentModel , success);
                        }];
                    } else {
                        BOOL result = [[UIApplication sharedApplication] openURL:schemeURL];
                        if (completion) {
                            completion(contentModel , result);
                        }
                    }
                }
            } else {
                contentModel.tempSourceValue = contentModel.sourceValue;
                contentModel.sourceValue = contentModel.linkedUrl;
                
                if (completion) {
                    completion(contentModel , NO);
                }
            }
        } else if([contentModel.sourceType isEqualToString:@"local"]) {
            
            if (completion) {
                completion(contentModel , NO);
            }
        }
    }
}

@end
