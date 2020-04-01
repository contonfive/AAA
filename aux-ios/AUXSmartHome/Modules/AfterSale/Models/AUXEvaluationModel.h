//
//  AUXEvaluationModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXEvaluationModel : NSObject

/**
 评价信息
 */
@property (nonatomic,copy) NSString *Memo;
/**
 评价星级
 */
@property (nonatomic,copy) NSString *Grade;
/**
 服务单id
 */
@property (nonatomic,copy) NSString *Oid;
/**
 服务单评价id
 */
@property (nonatomic,copy) NSString *Eid;
/**
 评价信息
 */
@property (nonatomic,copy) NSString *EntityName;
/**
 服务人员
 */
@property (nonatomic,copy) NSString *Worker;
/**
 图片base64编码数组
 */
@property (nonatomic,strong) NSArray *ImgIds;

@end

NS_ASSUME_NONNULL_END
