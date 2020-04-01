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
#import <MagicalRecord/MagicalRecord.h>

#import "AUXDefinitions.h"

#import "AUXDBDeviceModel+CoreDataClass.h"

/**
 设备型号
 */
@interface AUXDeviceModel : NSObject

@property (nonatomic, strong) NSString *advertise;  // 型号广告描述
@property (nonatomic, strong) NSString *createdAt;  // 创建时间

@property (nonatomic, strong) NSString *deviceMainUri;  // 设备型号主模块图所在 uri
@property (nonatomic, strong) NSString *entityUri;      // 型号图片 uri

@property (nonatomic, strong) NSString *feature;    // 功能列表（json格式）
@property (nonatomic, strong) NSString *model;      // 设备型号（唯一）
@property (nonatomic, strong) NSString *modelDescribe;  // 设备型号描述
@property (nonatomic, strong) NSString *modelId;    // 设备Id（主键）
@property (nonatomic, strong) NSString *modelItem;  // 设备内机物料（唯一）

@property (nonatomic, strong) NSString *step;       // 配网步骤（json)
@property (nonatomic, strong) NSString *stepUri;    // 配网步骤(图片) uri

@property (nonatomic, assign) NSInteger deviceType;   // 设备来源 0: 老设备 1: 新设备
@property (nonatomic, assign) NSInteger suitType;   // 适合类型标识 0: 单元机 1: 多联机
@property (nonatomic, assign) NSInteger useType;
@property (nonatomic, assign) NSInteger hardwareType;   // 硬件类型标识 1: 古北 2: 庆科
@property (nonatomic, assign) NSInteger deviceDisplay;   // 是否为测试员
@property (nonatomic, assign) NSInteger category;   // 挂机/柜机类型标识 0: 挂机 1: 柜机



///**
// 型号类别 0：挂机，1：柜机，2：单元机，3：多联机
// @note (用于手动选择型号界面的显示，除此之外别无他用)
// */
//@property (nonatomic, assign) AUXDeviceCategoryType category;
//
//
//- (void)setValueWithDBModel:(AUXDBDeviceModel *)dbModel;
//
///**
// 将从服务器获取的设备型号列表转换为存储于本地数据库的型号列表。
//
// @param modelList 服务器型号列表
// @return 本地数据库型号列表
// */
//+ (NSArray<AUXDBDeviceModel *> *)convertToDBModelList:(NSArray<AUXDeviceModel *> *)modelList;

@end
