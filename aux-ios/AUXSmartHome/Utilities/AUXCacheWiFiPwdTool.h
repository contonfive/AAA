//
//  AUXCacheWiFiPwdTool.h
//  AUXSmartHome
//
//  Created by AUX on 2019/5/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXCacheWiFiPwdTool : NSObject
+(instancetype)shareAUXAUXCacheWiFiPwdTool;
@property (nonatomic,strong)NSString *wifiPwd;
@property (nonatomic,strong)NSMutableDictionary *dataDic;

@end

NS_ASSUME_NONNULL_END
