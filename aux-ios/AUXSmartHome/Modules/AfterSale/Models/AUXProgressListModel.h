//
//  AUXProgressListModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXProgressListModel : NSObject

/**
 状态
 */
@property (nonatomic,copy) NSString *Status;
/**
 留言
 */
@property (nonatomic,copy) NSString *Memo;
/**
 进度单ID
 */
@property (nonatomic,copy) NSString *guid;
/**
 处理日期
 */
@property (nonatomic,copy) NSString *DealDate;
/**
 处理时间
 */
@property (nonatomic,copy) NSString *DealTime;

@end

NS_ASSUME_NONNULL_END
