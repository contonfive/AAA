//
//  AUXSubmitWorkOrderModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
#import "AUXProduct.h"
#import "AUXTopContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXSubmitWorkOrderModel : NSObject
@property (nonatomic,strong) AUXTopContactModel *TopContact;
@property (nonatomic,strong) AUXProduct *Product;
@property (nonatomic,strong) NSString *RequireinstalTime;
@property (nonatomic,strong) NSString *RequireinstalTime2;
@property (nonatomic,copy) NSString *Memo;
@property (nonatomic,assign) AUXLogisticsType LogisticsType;
/**
 购买日期
 */
@property (nonatomic,copy) NSString *purchase_date;
/**
 购买单位类型
 */
@property (nonatomic,copy) NSString *channeltype;
/**
 服务单号
 */
@property (nonatomic,copy) NSString *name;
/**
 物流状态
 */
@property (nonatomic,copy) NSString *Logistics;
/**
 创建时间
 */
@property (nonatomic,copy) NSString *createdon;
@end

NS_ASSUME_NONNULL_END
