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

#import <UIKit/UIKit.h>
typedef enum  {
    AUXGradientTypeOfTopToBottom = 0,//从上到小
    AUXGradientTypeOfLeftToRight = 1,//从左到右
    AUXGradientTypeOfUpleftTolowRight = 2,//左上到右下
    AUXGradientTypeOfUprightTolowLeft = 3,//右上到左下
}AUXGradientType;

@interface UIColor (AUXCustom)

/**
 用十六进制RGB值来创建颜色 (只支持RGB格式)

 @param hexValue 十六进制RGB值，如：0xFFFFFF
 @return UIColor
 */
+ (UIColor *)colorWithHex:(NSUInteger)hexValue;

/**
 用十六进制RGB值来创建颜色 (只支持RGB格式)

 @param hexString 十六进制RGB字符串。如：FFFFFF
 @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

/**
  用十六进制RGB值来创建颜色 (只支持RGB格式)，并设置颜色透明度

 @param hexString 十六进制RGB字符串。如：FFFFFF
 @param alpha 颜色透明度
 @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha;

/**
 用十六进制RGB值来创建颜色 (只支持RGB格式)再转图片

 @param hexString  十六进制RGB字符串。如：FFFFFF
 @return 图片
 */
+ (UIImage*)createImageWithColor:(NSString *)hexString;


/**
 根据颜色数组和颜色方位生成一张渐变图片

 @param colors 颜色数组
 @param size   控件的大小
 @param gradientType 颜色方位
 @return 渐变色图片
 */
+ (UIImage*)createImageFromColors:(NSArray*)colors bySize:(CGSize)size byGradientType:(AUXGradientType)gradientType;
@end
