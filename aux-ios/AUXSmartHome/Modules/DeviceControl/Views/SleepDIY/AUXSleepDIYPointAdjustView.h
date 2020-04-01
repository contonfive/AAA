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

#import "AUXBaseView.h"

#import "AUXDefinitions.h"

/**
 睡眠DIY编辑界面 每个节点温度、风速调节界面
 */
@interface AUXSleepDIYPointAdjustView : AUXBaseView

@property (nonatomic, assign) BOOL halfTemperature;     // 是否支持 0.5 摄氏度，默认为NO

@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, assign) AUXServerWindSpeed windSpeed;

@property (nonatomic, strong) NSArray<NSNumber *> *windSpeedArray;

@property (nonatomic, copy) void (^temperatureChangedBlock)(CGFloat temperature);
@property (nonatomic, copy) void (^windSpeedChangedBlock)(AUXServerWindSpeed windSpeed);

@end
