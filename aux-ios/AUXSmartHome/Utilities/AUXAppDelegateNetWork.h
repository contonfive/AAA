//
//  AUXAppDelegateNetWork.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/19.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUXAppDelegateNetWork : NSObject

+ (instancetype)sharedInstance;

- (void)setUpNetWorkRequest;

- (void)doLoginOutWithMessage:(NSString *)message;

@end
