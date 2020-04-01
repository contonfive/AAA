//
//  AUXServiceOrderModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXServiceOrderModel : NSObject

/**
 单据Id
 */
@property (nonatomic,copy) NSString *guid;
/**
 单号
 */
@property (nonatomic,copy) NSString *Name;
/**
 服务评价单id
 */
@property (nonatomic,copy) NSString *Eid;
/**
 实体名
 */
@property (nonatomic,copy) NSString *EntityName;
/**
 服务单申请人电话
 */
@property (nonatomic,copy) NSString *UserPhone;
/**
 客户名
 */
@property (nonatomic,copy) NSString *Contact;
/**
 联系电话
 */
@property (nonatomic,copy) NSString *Phone;
/**
 产品线
 */
@property (nonatomic,copy) NSString *ProductGroup;
/**
 产品
 */
@property (nonatomic,copy) NSString *ProductName;
/**
 产品类型
 */
@property (nonatomic,copy) NSString *ProductModel;
/**
 创建日期
 */
@property (nonatomic,copy) NSString *CreateOn;
/**
 单据类型
 */
@property (nonatomic,copy) NSString *OrderType;
/**
 单据状态
 */
@property (nonatomic,copy) NSString *Status;

@end

NS_ASSUME_NONNULL_END
