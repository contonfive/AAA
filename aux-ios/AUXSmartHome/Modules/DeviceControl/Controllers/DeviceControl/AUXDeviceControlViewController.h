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
#import "AUXDeviceFeature.h"

@class AUXSleepDIYModel;

/**
 设备控制界面
 */
@interface AUXDeviceControlViewController : AUXBaseViewController

@property (nonatomic, strong) NSArray<AUXDeviceInfo *> *deviceInfoArray;

@property (nonatomic, assign) BOOL isfromHomepage;
@property (nonatomic,strong)NSString *isNewAdd;

@property (nonatomic,strong)NSDictionary *tmpDict;
/// 设备控制类型。默认为 AUXDeviceControlTypeVirtual 虚拟体验。
@property (nonatomic, assign) AUXDeviceControlType controlType;

/// 跳转到故障列表
- (void)pushFaultListViewController;

/**
 判断是否可以开启睡眠DIY (设备控制互斥逻辑)

 @param sleepDIYModel 睡眠DIY
 @param message 错误信息。当返回YES时，值为nil；返回NO时，message为具体错误信息。
 @return YES=可以开启，NO=不能开启
 */
- (BOOL)canTurnOnSleepDIY:(AUXSleepDIYModel *)sleepDIYModel message:(NSString **)message;

/**
 判断是否可以开启智能用电 (设备控制互斥逻辑)

 @param message 错误信息。当返回YES时，值为nil；返回NO时，message为具体错误信息。
 @return YES=可以开启，NO=不能开启
 */
- (BOOL)canTurnOnSmartPower:(NSString **)message;

/**
 判断是否可以开启峰谷节电 (设备控制互斥逻辑)
 
 @param message 错误信息。当返回YES时，值为nil；返回NO时，message为具体错误信息。
 @return YES=可以开启，NO=不能开启
 */
- (BOOL)canTurnOnPeakValley:(NSString **)message;

/**
 通过SDK开启/关闭睡眠DIY

 @param sleepDIYModel 睡眠DIY
 @param on 开启/关闭
 */
- (void)switchSleepDIYBySDK:(AUXSleepDIYModel *)sleepDIYModel on:(BOOL)on;

- (void)reloadDeviceArray:(NSArray<AUXDeviceInfo *> *)deviceInfoArray;

@end


@interface AUXDeviceControlViewController (ActivityIndicator)

- (void)showTransparentLoading;
- (void)hideTransparentLoading;



@end
