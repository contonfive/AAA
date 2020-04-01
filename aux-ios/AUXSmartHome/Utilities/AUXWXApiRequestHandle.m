//
//  AUXWXApiRequestHandle.m
//  AUXSmartHome
//
//  Copyright AUX Group Co., Ltd on 2018/5/29.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWXApiRequestHandle.h"
#import "WXApi.h"

@implementation AUXWXApiRequestHandle

+ (instancetype)shareAUXWXApiRequestHandle {
    static dispatch_once_t onceToken;
    static AUXWXApiRequestHandle *handle;
    dispatch_once(&onceToken, ^{
        handle = [[AUXWXApiRequestHandle alloc]init];
    });
    return handle;
}

+ (SendMessageToWXReq *)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene {
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = info;
    ext.url = url;
    ext.fileData = data;

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = ext;
    message.messageExt = messageExt;
    message.messageAction = action;
    [message setThumbImage:thumbImage];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.scene = scene;
    req.message = message;
    
    return req;
//    return [WXApi sendReq:req];
}

@end
