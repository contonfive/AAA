//
//  AUXMessageContentModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/13.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

@interface AUXMessageContentModel : NSObject

/**
 用来暂时存储sourceValue得知
 */
@property (nonatomic,copy) NSString *tempSourceValue;

@property (nonatomic,copy) NSString *body;
@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,copy) NSString *linkedUrl;
@property (nonatomic,copy) NSString *sourceType;
@property (nonatomic,copy) NSString *sourceValue;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *platform;
@property (nonatomic,copy) NSString *pushType;

@property (nonatomic,copy) NSString *pushTime;
/**
 当前数据属于今天、昨天、还是其他日期
 */
@property (nonatomic,copy) NSString *dateTime;
@property (nonatomic,copy) NSString *uid;

@property (nonatomic,assign) CGSize imageSize;
@property (nonatomic,assign) CGFloat rowHeight;

@end
