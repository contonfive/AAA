//
//  AUXPushLimitModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/22.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXPushLimitModel : NSObject

/**
 关闭时间
 */
@property (nonatomic,assign) NSInteger endHour;
/**
 关闭分钟
 */
@property (nonatomic,assign) NSInteger endMinute;
/**
 id
 */
@property (nonatomic,copy) NSString *guid;
/**
 开启时间
 */
@property (nonatomic,assign) NSInteger startHour;
/**
 开启分钟
 */
@property (nonatomic,assign) NSInteger startMinute;
/**
 状态
 */
@property (nonatomic,assign) NSInteger state;
/**
 uid
 */
@property (nonatomic,copy) NSString *uid;
@end

NS_ASSUME_NONNULL_END
