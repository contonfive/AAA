//
//  AUXSaveCenterControlMode.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXSaveCenterControlMode : NSObject
@property(nonatomic,strong)NSArray*deviceList;
@property(nonatomic,assign)BOOL homePageFlag;
@property(nonatomic,strong)NSString *sceneName;
@end

NS_ASSUME_NONNULL_END

