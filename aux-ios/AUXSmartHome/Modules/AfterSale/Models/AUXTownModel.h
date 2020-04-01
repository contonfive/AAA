//
//  AUXTownModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>


NS_ASSUME_NONNULL_BEGIN

@interface AUXTownModel : NSObject

/**
 街道GUID
 */
@property (nonatomic,copy) NSString *value;
/**
 街道名称
 */
@property (nonatomic,copy) NSString *text;
/**
 区县ID
 */
@property (nonatomic,copy) NSString *CountyId;
/**
 区县名称
 */
@property (nonatomic,copy) NSString *CountyName;
@end

NS_ASSUME_NONNULL_END
