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

#import "AUXBaseViewController.h"

#import "AUXDeviceInfo.h"
#import "AUXDefinitions.h"

typedef NS_ENUM(NSInteger, AUXChooseDevicePurpose) {
    AUXChooseDevicePurposeShareDevice,      // 选择要分享的设备
    AUXChooseDevicePurposeControlDevice,    // 选择要集中控制的设备
    AUXChooseDevicePurposeControlSubdevice, // 选择要集中控制的子设备 (选择完后跳转到控制界面)
    AUXChooseDevicePurposeChooseSubdevice,  // 选择要集中控制的子设备 (选择完成后返回上一级)
};

/**
 选择设备界面
 */
@interface AUXChooseDeviceViewController : AUXBaseViewController

/// 选择设备的意图
@property (nonatomic, assign) AUXChooseDevicePurpose purpose;

/// 设备列表
@property (nonatomic, strong) NSArray<AUXDeviceInfo *> *deviceInfoArray;

/// 分享对象类型。当 purpose 为 AUXChooseDevicePurposeShareDevice 时，需要传入该值。
@property (nonatomic, assign) AUXDeviceShareType deviceShareType;

/// 设备。当 purpose 为 AUXChooseDevicePurposeControlSubdevice、AUXChooseDevicePurposeChooseSubdevice 时使用该属性，deviceInfoArray 会被忽略。
@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedRows;
@property (nonatomic, strong) NSMutableArray<NSString *> *selectedAddresses;

/// 子设备选择回调block。当 purpose 为 AUXChooseDevicePurposeChooseSubdevice 时，每选中或取消选中一台子设备都会回调该block。
@property (nonatomic, copy) void (^didSelectSubdevices)(NSArray<NSString *> *addressArray);

@end
