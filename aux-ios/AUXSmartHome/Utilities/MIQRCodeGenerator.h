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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 二维码图片生成工具
 */
@interface MIQRCodeGenerator : NSObject

/**
 根据二维码内容和尺寸，生成图片

 @param string 二维码内容
 @param size 图片尺寸
 @return 二维码图片
 */
+ (UIImage *)createQRCodeForString:(NSString *)string withSize:(CGFloat)size;

/**
 在二维码图片中间添加 icon

 @param image 二维码图片
 @param icon icon
 @param iconSize icon尺寸
 @return 二维码图片
 */
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize;

/**
 更改二维码的颜色

 @param image 二维码图片
 @param red 红色值 0-255
 @param green 绿色值 0-255
 @param blue 蓝色值 0-255
 @return 二维码图片
 */
+ (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

@end
