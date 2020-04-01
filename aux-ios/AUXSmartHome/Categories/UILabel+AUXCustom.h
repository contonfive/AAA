//
//  UILabel+AUXCustom.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/23.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UILabel (AUXCustom)

/**
 *  设置字间距
 */
- (void)setColumnSpace:(CGFloat)columnSpace;
/**
 *  设置行距
 */
- (void)setRowSpace:(CGFloat)rowSpace;

-(void)setLabelSpaceWithValue:(NSString *)str withRowHeight:(CGFloat)rowHeight;

/**
 设置UILabel的

 @param text AttributedString
 @param color AttributedColor
 */
- (void)setLabelAttributedString:(NSString *)text color:(UIColor *)color;

/**
 设置UILabel的AttributedString

 @param textArray 需要设置的 text
 @param color 需要设置的颜色
 */
- (void)setLabelAttributedStringWithTextArray:(NSArray <NSString *>*)textArray color:(UIColor *)color;

/**
 喷枪打字

 @param text label内容
 */
- (void)setLabelAnimateText:(NSString *)text completion:(void (^)(void))completion;
@end
