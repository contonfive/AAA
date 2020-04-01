//
//  UIDevice+IPAddr.h
//  Aux
//
//  Created by Stone on 15/12/2.
//  Copyright (c) 2015年 Aux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (IPAddr)
+ (NSString *)localIP;
+ (NSString *)getGatewayIPAddress;
@end
