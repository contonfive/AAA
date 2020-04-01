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

typedef NS_ENUM(NSInteger, AUXScanPurpose) {
    AUXScanPurposeConfiguringDevice,    // 配置设备
    AUXScanPurposeCompletingDeviceSN,   // 完善SN码
    AUXScanPurposeCompletingElectronicSpecification,   // 电子说明书
    AUXScanPurposeCompletingElectronicSpecificationScan,
};

/**
 SN码、二维码扫描界面
 */
@interface AUXScanCodeViewController : AUXBaseViewController

/// 扫码的意图。默认为 AUXScanPurposeConfiguringDevice。
@property (nonatomic, assign) AUXScanPurpose scanPurpose;

/**
 扫码成功回调的block。仅当 scanPurpose 为 AUXScanPurposeCompletingDeviceSN 时才会触发回调。
 */
@property (nonatomic, copy) void (^didScanCodeBlock)(NSString *code);

@end
