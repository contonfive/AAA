//
//  AUXProduct.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
#import "AUXPickListModel.h"
#import "AUXProgressListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXProduct : NSObject

/**
 安装还是维修
 */
@property (nonatomic,assign) AUXAfterSaleType workOrderType;

/**
 服务单号
 */
@property (nonatomic,copy) NSString *Name;
/**
 产品线名称
 */
@property (nonatomic,copy) NSString *ProductGroup;
/**
 产品名称
 */
@property (nonatomic,copy) NSString *ProductName;
/**
 单据创建时间
 */
@property (nonatomic,copy) NSString *CreatedOn;
/**
 经度
 */
@property (nonatomic,copy) NSString *Longitude;
/**
 纬度
 */
@property (nonatomic,copy) NSString *Latitude;
/**
 单据状态
 */
@property (nonatomic,copy) NSString *Status;
/**
 购机日期
 */
@property (nonatomic,copy) NSString *BuyDate;
/**
 产品大类
 */
@property (nonatomic,strong) AUXPickListModel *ProductGroupType;
/**
 处理详情类
 */
@property (nonatomic,strong) NSArray <AUXProgressListModel *> *ProgressList;

/**
 购买单位类型
 */
@property (nonatomic,assign) NSInteger ActualChannelType;

@end

NS_ASSUME_NONNULL_END
