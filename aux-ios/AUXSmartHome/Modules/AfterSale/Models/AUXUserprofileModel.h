//
//  AUXUserprofileModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/11.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXUserprofileModel : NSObject

/**
 设备档案Id
 */
@property (nonatomic,copy) NSString *guid;
/**
 单据ID
 */
@property (nonatomic,copy) NSString *ProductGroupIdName;
/**
 客户名称
 */
@property (nonatomic,copy) NSString *Customer;
/**
 金卡卡号
 */
@property (nonatomic,copy) NSString *RightsCard;
/**
 购机日期
 */
@property (nonatomic,copy) NSString *BuyDate;
/**
 电话
 */
@property (nonatomic,copy) NSString *PhoneNumber;
/**
 产品型号
 */
@property (nonatomic,copy) NSString *ProductIdName;
@end

NS_ASSUME_NONNULL_END
