//
//  AUXDeviceStateInfo.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/16.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUXDeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceStateInfo : NSObject
+(instancetype)shareAUXDeviceStateInfo;
@property (nonatomic,strong)NSMutableArray*dataArray;

@end

NS_ASSUME_NONNULL_END
