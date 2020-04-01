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

/**
 科大讯飞语音识别结果处理类
 */
@interface AUXIFlySpeechResultHandler : NSObject

+ (NSString *)analyseResults:(NSArray<NSString *> *)results;

@end
