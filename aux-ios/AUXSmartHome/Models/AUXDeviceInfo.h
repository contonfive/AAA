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
#import <YYModel/YYModel.h>

#import "AUXDefinitions.h"
#import "AUXDeviceFeature.h"

@class AUXDeviceModel;

/**
 设备信息 (从服务器获取的设备列表)
 */
@interface AUXDeviceInfo : NSObject <YYModel>

/**
 对于同一台设备，只要 mac 地址不变，deviceId 就不会变。
 */
@property (nonatomic, strong) NSString *deviceId;

@property (nonatomic, strong) NSString *alias;      // 别名

@property (nonatomic, assign) AUXDeviceSource source;   // 来源：0=古北，1=机智云
@property (nonatomic, strong) NSString *mac;

@property (nonatomic, strong) NSString *sn;         // 设备SN码
@property (nonatomic, strong) NSString *modelId;    // 型号id

@property (nonatomic, assign) AUXDeviceSuitType suitType;   // 适合类型标识 0=单元机 1=多联机
@property (nonatomic, assign) AUXDeviceMachineType useType; // 挂机/柜机类型标识 0: 挂机 1: 柜机

@property (nonatomic, strong) NSString *deviceMainUri;  // 设备模块主界面图
@property (nonatomic, strong) NSString *entityUri;  // 设备实物图 
@property (nonatomic, strong) NSString *feature;    // 功能列表（json格式）

@property (nonatomic, assign, readonly) WindGearType windGearType;

@property (nonatomic, assign) AUXDeviceShareType userTag;   // 权限 (主人、家人、朋友)

@property (nonatomic, assign) BOOL online;
@property (nonatomic, assign) BOOL wash;    // 滤网是否需清洗

// 新设备
@property (nonatomic, strong) NSString *did;        // 设备did
@property (nonatomic, strong) NSString *productKey; // 产品
//@property (copy, nonatomic) NSString *passCode;

// 旧设备
@property (nonatomic, strong) NSString *deviceKey;  // 设备key
@property (nonatomic, strong) NSString *deviceLock; // 设备锁
@property (nonatomic, strong) NSString *type;       // 类型
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) NSInteger subDevice;  // 子设备
@property (nonatomic, assign) NSInteger terminalId; // 终端id
@property (nonatomic, strong) NSString *city;       // 城市
@property (nonatomic, strong) NSString *cityCode;   // 城市编码
@property (nonatomic, strong) NSString *dataOne;
@property (nonatomic, strong) NSString *dataTwo;
@property (nonatomic, strong) NSString *dataThree;

@property (nonatomic, strong) NSString *latitude;   // 纬度
@property (nonatomic, strong) NSString *longitude;  // 经度

// 虚拟体验
@property (nonatomic, assign) BOOL virtualDevice;

// 用于设备控制
@property (nonatomic, strong) AUXACDevice *device;
@property (nonatomic, strong) NSArray<NSString *> *addressArray;    // 同时控制多台子设备时使用

/**
 设备支持的功能。
 @note 当该属性为 nil 时，会使用属性 feature 来实例化该属性。也可以通过调用方法 updateDeviceFeature: 来设置该属性的值。
 */
@property (nonatomic, strong, readonly) AUXDeviceFeature *deviceFeature;

+ (instancetype)virtualDeviceInfo;

/**
 初始化设备信息

 @param acDevice SDK 空调设备实例
 @param model 设备型号
 @return 设备信息
 */
- (instancetype)initWithACDevice:(AUXACDevice *)acDevice model:(AUXDeviceModel *)model deviceSN:(NSString *)deviceSN;

- (void)updateDeviceFeature:(AUXDeviceFeature *)deviceFeature;

@property(nonatomic, assign) BOOL     isSelected;


@end
