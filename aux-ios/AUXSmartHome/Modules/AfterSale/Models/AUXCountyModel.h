//
//  AUXCountyModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXCountyModel : NSObject

/**
 区县GUID
 */
@property (nonatomic,copy) NSString *value;
/**
 区县名称
 */
@property (nonatomic,copy) NSString *text;
/**
 城市ID
 */
@property (nonatomic,copy) NSString *CityId;
/**
 城市名称
 */
@property (nonatomic,copy) NSString *CityName;
@end

NS_ASSUME_NONNULL_END
