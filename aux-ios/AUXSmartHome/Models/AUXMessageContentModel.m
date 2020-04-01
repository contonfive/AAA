//
//  AUXMessageContentModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/13.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXMessageContentModel.h"
#import "UIImage+AUXCustom.h"
#import "NSString+AUXCustom.h"
#import <YYModel.h>
@implementation AUXMessageContentModel

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.rowHeight = 100;
    }
    return self;
}

- (void)setBody:(NSString *)body {
    _body = body;
    
    if (!AUXWhtherNullString(self.body)) {
        CGFloat bodyHeight = [self.body getStringHeightWithText:self.body font:[UIFont systemFontOfSize:14] viewWidth:(kAUXScreenWidth - 30 * 2)];
        self.rowHeight += bodyHeight;
    }
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    
    if (!AUXWhtherNullString(self.imageUrl)) {
        CGSize imageSize = [UIImage getImageSizeWithURL:self.imageUrl];
        
        CGFloat imageWidth = kAUXScreenWidth - 30 * 2;
        CGFloat imageHeight = imageSize.height / imageSize.width * imageWidth;
        
        imageSize = CGSizeMake(imageWidth, imageHeight);
        self.imageSize = imageSize;
        self.rowHeight += imageHeight;
    }
}


@end
