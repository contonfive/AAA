//
//  AUXShareDeviceModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUXShareDeviceModel : NSObject

@property (nonatomic,copy) NSString *deviceDescription;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *ownerUid;
@property (nonatomic,copy) NSString *qrContent;

@end
