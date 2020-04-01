//
//  AUXAddressModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXAddressModel : NSObject
/**
 GUID
 */
@property (nonatomic,copy) NSString *value;
/**
 名称
 */
@property (nonatomic,copy) NSString *text;
/**
 省份ID
 */
@property (nonatomic,copy) NSString *ProvinceId;
/**
 省份名称
 */
@property (nonatomic,copy) NSString *ProvinceName;
/**
 城市ID
 */
@property (nonatomic,copy) NSString *CityId;
/**
 城市名称
 */
@property (nonatomic,copy) NSString *CityName;
/**
 区县ID
 */
@property (nonatomic,copy) NSString *CountyId;
/**
 区县名称
 */
@property (nonatomic,copy) NSString *CountyName;

@property (nonatomic,assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
