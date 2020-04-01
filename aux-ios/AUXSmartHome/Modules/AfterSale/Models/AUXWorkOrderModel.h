//
//  AUXWorkOrderModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXWorkOrderModel : NSObject

/**
 工单类型
 */
@property (nonatomic,assign) AUXAfterSaleType workOrderType;
/**
 单据ID
 */
@property (nonatomic,copy) NSString *guid;
/**
 工单单号
 */
@property (nonatomic,copy) NSString *workNumber;
/**
 实体名
 */
@property (nonatomic,copy) NSString *EntityName;
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
 产品类型
 */
@property (nonatomic,copy) NSString *Product;
/**
 单据状态
 */
@property (nonatomic,copy) NSString *State;
/**
 单据状态显示颜色
 */
@property (nonatomic,copy) NSString *Color;
/**
 创建日期
 */
@property (nonatomic,copy) NSString *Createdon;
/**
 服务站号码
 */
@property (nonatomic,copy) NSString *StationPhone;
/**
 是否完工
 */
@property (nonatomic,assign) BOOL IsFinsh;

/**
 家用空调
 */
@property (nonatomic,assign) BOOL isHomeWorkOrder;
/**
 中央空调
 */
@property (nonatomic,assign) BOOL isSrvWorkOrder;
@end

NS_ASSUME_NONNULL_END
