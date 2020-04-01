//
//  AUXNotificationTools.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AUXMessageContentModel.h"
#import "AUXRemoteNotificationModel.h"

@interface AUXNotificationTools : NSObject

+ (void)analyseMessageModel:(AUXMessageContentModel *)messageInfoModel completion:(void (^)(AUXMessageContentModel *messageInfoModel, BOOL opURLSuccess))completion;

+ (void)analysePushLaunchUserInfo:(NSDictionary *)pushLaunchUserInfo completion:(void (^)(AUXRemoteNotificationModel *messageInfoModel, BOOL opURLSuccess))completion;

@end
