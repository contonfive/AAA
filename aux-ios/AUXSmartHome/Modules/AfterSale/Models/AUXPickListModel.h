//
//  AUXPickListModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXPickListModel : NSObject
/**
 产品名称
 */
@property (nonatomic,copy) NSString * Name;
/**
 产品的guid
 */
@property (nonatomic,copy) NSString *Value;
@end

NS_ASSUME_NONNULL_END
