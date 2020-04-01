//
//  UITextView+AUXFont.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "UITextView+AUXFont.h"

@implementation UITextView (AUXFont)

+ (void)load{
    
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    
    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
    
    method_exchangeImplementations(imp, myImp);
    
}
- (id)myInitWithCoder:(NSCoder*)aDecode{
    
    [self myInitWithCoder:aDecode];
    if (self) {
        CGFloat fontSize = self.font.pointSize;
        NSString *fontName = self.font.fontName;
        
        self.font = [UIFont fontWithName:fontName size:fontSize];
    }
    return self;
}

@end
