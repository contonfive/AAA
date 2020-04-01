//
//  AUXProvinceModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXProvinceModel : NSObject

/**
 省份GUID
 */
@property (nonatomic,copy) NSString *value;
/**
 省份名称
 */
@property (nonatomic,copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
