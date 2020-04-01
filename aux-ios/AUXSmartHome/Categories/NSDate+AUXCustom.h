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

@interface NSDate (AUXCustom)

/// 判断当前年份是不是闰年
+ (BOOL)isLeapYear:(NSInteger)year;


/**
 获取天数

 @param month 月份
 @param year 年
 @return 天数
 */
+ (NSInteger)numberOfDaysInMonth:(NSInteger)month forYear:(NSInteger)year;

/**
 根据时间戳 判断时间是否是今天 昨天 星期几 几月几日

 @param beDateTime 时间戳
 @return 距离现在的时间
 */
+ (NSString *)distanceTimeWithBeforeTime:(NSString *)beDateTime;

/**
 时间转时间戳

 @param theTime 时间
 @return 时间戳
 */
+(long)cTimestampFromString:(NSString *)theTime;

/**
 时间戳——>字符串时间

 @param timestamp 时间戳
 @return 时间戳对应的时间
 */
+(NSString *)cStringFromTimestamp:(NSString *)timestamp ;

/**
 当前时间戳

 @return 当前时间戳
 */
+ (NSString *)cNowTimestamp;

/**
 当前时间

 @return 当前时间
 */
+ (NSString*)getCurrentTimes;
/**
 获取当前时间 以 2018-09-29T00:00:00 格式

 @return 当前时间
 */
+ (NSString *)getDateTime;
/**
 获取明天时间 以 2018-09-29T00:00:00 格式
 
 @return 明天时间
 */
+ (NSString *)getNextDateTime;

/**
 *  判断当前时间是否处于某个时间段内
 *
 *  @param startTime        开始时间
 *  @param expireTime       结束时间
 */
+ (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime;

/**
 当前时间

 @return 返回时
 */
+(NSString *)nowhh;

/**
 当前时间

 @return 返回分钟
 */
+(NSString *)nowmm;



/**
 时间戳转化为年月日

 @param TimestampyyyMMdd 时间戳
 @return 时间
 */
+(NSString *)cStringFromTimestampyyyMMdd:(NSString *)TimestampyyyMMdd;


/**
 时间戳转化为年月日 时
 
 @param TimestampyyyMMddHH 时间戳
 @return 时间
 */
+(NSString *)cStringFromTimestampyyyMMddHH:(NSString *)TimestampyyyMMddHH;

@end
