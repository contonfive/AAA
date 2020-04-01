/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "UIColor+AUXCustom.h"

@implementation UIColor (AUXCustom)

+ (UIColor *)colorWithHex:(NSUInteger)hexValue withAlpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((hexValue >> 16) & 0x000000FF) / 255.0f
                           green:((hexValue >> 8) & 0x000000FF) / 255.0f
                            blue:(hexValue & 0x000000FF) / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithHex:(NSUInteger)hexValue {
    return [UIColor colorWithRed:((hexValue >> 16) & 0x000000FF) / 255.0f
                           green:((hexValue >> 8) & 0x000000FF) / 255.0f
                            blue:(hexValue & 0x000000FF) / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    
    if (!hexString || hexString.length != 6) {
        return nil;
    }
    
    unsigned int hexValue;
    
    [[NSScanner scannerWithString:hexString] scanHexInt:&hexValue];
    
    return [self colorWithHex:hexValue];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha{
    
    if (!hexString || hexString.length != 6) {
        return nil;
    }
    
    unsigned int hexValue;
    
    [[NSScanner scannerWithString:hexString] scanHexInt:&hexValue];
    
    return [self colorWithHex:hexValue withAlpha:alpha];
}


+ (UIImage*)createImageWithColor:(NSString *)hexString{
    UIColor *color = [self colorWithHexString:hexString];
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)createImageFromColors:(NSArray*)colors bySize:(CGSize)size byGradientType:(AUXGradientType)gradientType{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case AUXGradientTypeOfTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case AUXGradientTypeOfLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case AUXGradientTypeOfUpleftTolowRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case AUXGradientTypeOfUprightTolowLeft:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

@end

