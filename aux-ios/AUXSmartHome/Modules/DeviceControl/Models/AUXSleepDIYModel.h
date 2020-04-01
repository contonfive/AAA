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
#import <YYModel/YYModel.h>

#import "AUXDefinitions.h"

/**
 睡眠DIY曲线节点
 */
@interface AUXSleepDIYPointModel : NSObject <YYModel, NSCopying>

@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, assign) AUXServerWindSpeed windSpeed;  // 0：低风，1：中风，2：高风，3：静音，4：自动

- (BOOL)isEqualToSleepDIYPointModel:(AUXSleepDIYPointModel *)sleepDIYPointModel;

@end

/**
 睡眠DIY模型
 
 @discussion 无论新旧设备的睡眠DIY列表都保存在服务器上。旧设备的睡眠DIY开启/关闭由SDK下发命令，且只能开启一条，互斥逻辑由App进行判断；
 新设备的睡眠DIY开启/关闭由服务器处理。
 */
@interface AUXSleepDIYModel : NSObject <YYModel, NSCopying>

@property (nonatomic, strong) NSString *sleepDiyId;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) AUXServerDeviceMode mode;     // 模式，1：制冷，2：制热
@property (nonatomic, assign) AUXServerWindSpeed windSpeed;  // 0：低风，1：中风，2：高风，3：静音，4：自动

@property (nonatomic, assign) NSInteger startHour;      // 开始时间 时 (新设备)
@property (nonatomic, assign) NSInteger startMinute;    // 开始时间 分 (新设备)
@property (nonatomic, assign) NSInteger endHour;
@property (nonatomic, assign) NSInteger endMinute;

@property (nonatomic, assign) NSInteger definiteTime;  // 睡眠时间 (小时数) (古北设备)

@property (nonatomic, assign) NSInteger deviceManufacturer;      // 0：旧设备，1：新设备
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL smart;         // 智能模式

/**
 电控指令。(JSON字符串)
 
 @warning 请勿主动设置该属性的值，请使用 pointModelList
 @see pointModelList
 */
@property (nonatomic, strong) NSString *electricControl;

@property (nonatomic, strong) NSArray<AUXSleepDIYPointModel *> *pointModelList;    // 睡眠曲线节点列表。节点个数等于睡眠时间。

/// 根据开始时间和睡眠时间，生成时间段 (如: 23:00-09:00)
- (NSString *)timePeriod;

/**
 将用于【服务器】的睡眠DIY节点列表转换为 SDK 使用的节点列表。
 App节点间隔为1小时，SDK为10分钟，所以每个节点需要拷贝6份。

 @return SDK 使用的节点列表
 */
- (NSArray<AUXACSleepDIYPoint *> *)convertToACSleepDIYPointArray;

/**
 判断睡眠DIY的节点列表 和 SDK 上报的节点列表是否相等。
 App节点间隔为1小时，SDK为10分钟，所以要将SDK的节点去掉一部分。

 @param acSleepDIYPointArray SDK 上报的节点列表
 @return 是否相等
 */
- (BOOL)isEqualToACSleepDIYPointArray:(NSArray<AUXACSleepDIYPoint *> *)acSleepDIYPointArray;

- (BOOL)isEqualToSleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel;

@end
