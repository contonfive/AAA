//
//  UIFont+AUXFont.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "UIFont+AUXFont.h"

@implementation UIFont (AUXFont)

#define MyUIScreen  375 // UI设计原型图的手机尺寸宽度(6s), 6p的--414

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

// 这里设置iPhone6放大的字号数（现在是缩小2号，也就是iPhone6上字号为17，在iPhone4s和iPhone5上字体为15时，）
#define IPHONE5_INCREMENT 2
// 这里设置iPhone6Plus放大的字号数（现在是放大1号，也就是iPhone6上字号为17，在iPhone6P上字体为18时）
#define IPHONE6PLUS_INCREMENT 1

+(void)load{
    
    //获取替换后的类方法
    Method newMethod = class_getClassMethod([self class], @selector(adjustFontWithName: size:));
    //获取替换前的类方法
    Method method = class_getClassMethod([self class], @selector(fontWithName: size:));
    //然后交换类方法
    method_exchangeImplementations(newMethod, method);
    
}

//以6s未基准（因为一般UI设计是以6s尺寸为基准设计的）的字体。在5s和6P上会根据屏幕尺寸，字体大小会相应的扩大和缩小
+ (UIFont *)adjustFont:(CGFloat)fontSize {
    UIFont *newFont = nil;
    newFont = [UIFont adjustFont:fontSize * [UIScreen mainScreen].bounds.size.width/MyUIScreen];
    return newFont;
}

+ (UIFont *)adjustFontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont *newFont = nil;
    newFont = [UIFont adjustFontWithName:fontName size:fontSize * [UIScreen mainScreen].bounds.size.width/MyUIScreen];
    return newFont;
}

@end
