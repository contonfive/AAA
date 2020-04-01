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

@interface NSString (AUXCustom)


- (NSString *)base64DecodedString;
- (NSString *)base64EncodedString;


- (NSString*)encodeString;
- (NSString*)decodeString;

/**
 字符串反转

 @return abc def。 翻转成 。fed cba
 */
- (NSString *)allReverse;

/**
 只包含字母或数字
 
 @return YES 是 NO  否
 */
- (BOOL)isStringOnlyWithNumberOrLetter;

- (BOOL)isStringWithEmoji;

/**
 判断字符串是否是手机号
 @return YES 是 NO不是
 */
- (BOOL)isPhoneNumber;

/**
 动态获取字符串高度

 @param text 内容
 @param font 字体大小
 @param width 宽度
 @return 字符串高度
 */
- (CGFloat)getStringHeightWithText:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width;
@end
