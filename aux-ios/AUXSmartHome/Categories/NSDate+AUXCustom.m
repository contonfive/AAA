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

#import "NSDate+AUXCustom.h"

static NSString *hhDateFormat             = @"HH";

static NSString *mmDateFormat            = @"mm";

@implementation NSDate (AUXCustom)



+ (NSInteger)numberOfDaysInMonth:(NSInteger)month forYear:(NSInteger)year {
    NSInteger maxDay = 0;
    
    switch (month) {
        case 2:
            maxDay = [self isLeapYear:year] ? 29 : 28;
            break;
            
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            maxDay = 31;
            break;
            
        case 4:
        case 6:
        case 9:
        case 11:
            maxDay = 30;
            break;
            
        default:
            maxDay = 0;
            break;
    }
    
    return maxDay;
}

+ (BOOL)isLeapYear:(NSInteger)year {
    BOOL value = NO;
    
    if (year == 0) {
        return value;
    }
    
    if ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0))) {
        value = YES;
    }
    
    return value;
}

+ (NSString *)distanceTimeWithBeforeTime:(NSString *)beDateTime {
    
    long beTime = [NSDate cTimestampFromString:beDateTime];
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm"];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if(distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue]){
        distanceStr = [NSString stringWithFormat:@"今天"];
    } else if(distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]){
        if ([nowDay integerValue] - [lastDay integerValue] ==1 || ([lastDay integerValue] - [nowDay integerValue] > 10 && [nowDay integerValue] == 1)) {
            distanceStr = [NSString stringWithFormat:@"昨天"];
        } else {
            [df setDateFormat:@"yyyy-MM-dd"];
            distanceStr = [df stringFromDate:beDate];
        }
    } else {
        [df setDateFormat:@"yyyy-MM-dd"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

//当前时间的时间戳
+ (NSString *)cNowTimestamp {
    NSDate *newDate = [NSDate date];
    long int timeSp = (long)[newDate timeIntervalSince1970];
    NSString *tempTime = [NSString stringWithFormat:@"%ld",timeSp];
    return tempTime;
}

+ (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
    
}

+ (NSString *)getDateTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSS"];
    
    NSDate *datenow = [NSDate date];
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}

+ (NSString *)getNextDateTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSS"];
    
    NSDate *datenow = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}

//时间戳——字符串时间
+(NSString *)cStringFromTimestamp:(NSString *)timestamp {
    //时间戳转时间的方法
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strTime = [dateFormatter stringFromDate:timeData];
    return strTime;
}

//时间戳——字符串时间
+(NSString *)cStringFromTimestampyyyMMddHH:(NSString *)TimestampyyyMMddHH {
    //时间戳转时间的方法
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:[TimestampyyyMMddHH intValue]];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH"];
    NSString *strTime = [dateFormatter stringFromDate:timeData];
    return strTime;
}


//时间戳——字符串时间
+(NSString *)cStringFromTimestampyyyMMdd:(NSString *)TimestampyyyMMdd {
    //时间戳转时间的方法
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:[TimestampyyyMMdd intValue]];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strTime = [dateFormatter stringFromDate:timeData];
    return strTime;
}

//字符串时间——时间戳
+(long)cTimestampFromString:(NSString *)theTime {
    
    //装换为时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate* dateTodo = [formatter dateFromString:theTime];
    
    return (long)[dateTodo timeIntervalSince1970];
}




+ (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime {
    
    long int startTimestamp = [[self class] cTimestampFromString:startTime];
    long int expireTimestamp = [[self class] cTimestampFromString:expireTime];
    long int nowTimestamp = [[self class] cNowTimestamp].longLongValue;
    
    
    if (nowTimestamp >= startTimestamp && nowTimestamp <= expireTimestamp) {
        return YES;
    }
    return NO;
}



+(NSString *)nowhh
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = hhDateFormat;
    [dateFormatter stringFromDate:[NSDate new]];
    return [dateFormatter stringFromDate:[NSDate new]];
}



+(NSString *)nowmm
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = mmDateFormat;
    [dateFormatter stringFromDate:[NSDate new]];
    return [dateFormatter stringFromDate:[NSDate new]];
}






@end
