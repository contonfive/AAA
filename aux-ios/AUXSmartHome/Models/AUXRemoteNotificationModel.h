//
//  AUXRemoteNotificationModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXMessageContentModel.h"

@interface AUXRemoteNotificationModel : AUXMessageContentModel<NSCoding>

+ (instancetype)sharedInstance;

- (void)archiveRemoteNotificationList:(AUXRemoteNotificationModel *)remoteNotificationModel;

- (NSMutableArray *)unarchiveRemoteNotificationList;

@property (nonatomic,copy) NSString *_j_msgid;

@end
