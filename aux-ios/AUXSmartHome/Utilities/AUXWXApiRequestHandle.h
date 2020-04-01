//
//  AUXWXApiRequestHandle.h
//  AUXSmartHome
//
//  Created by 奥克斯家研--张海昌 on 2018/5/29.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AUXWXApiRequestHandle : NSObject

+ (instancetype)shareAUXWXApiRequestHandle;

+ (SendMessageToWXReq *)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene;


@end
