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

#import <UIKit/UIKit.h>
#import "AUXDeviceFeature.h"
#import "AUXDeviceStatus.h"
#import "AUXDeviceInfo.h"
#import "AUXDeviceFunctionItem.h"

/**
 设备列表 设备卡片
 */
@interface AUXDeviceCollectionViewCell : UICollectionViewCell

#pragma mark 共用属性
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *faultImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceNameLeading;
@property (weak, nonatomic) IBOutlet UILabel *sumCountLabel;


@property (nonatomic,assign) CGFloat roomTemperature;

@property (nonatomic, assign) BOOL hasFault;                // 设备是否故障。默认为NO。
@property (nonatomic, assign) BOOL hasRoomTemperature;      // 是否有室内温度

@property (nonatomic, assign) BOOL powerOn;                 // 默认为NO。
@property (nonatomic, assign) BOOL offline;                 // 默认为NO。

@property (nonatomic,assign) AUXDeviceListType currentDeviceListType;

@property (nonatomic, strong) AUXDeviceInfo *deviceInfo;
@property (nonatomic, strong) AUXDeviceStatus *deviceStatus;

@property (nonatomic, strong) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;

/**
 操作失败，失败原因errorText
 */
@property (nonatomic, copy) void (^sendControlError)(NSString *errorText);

/**
 显示菊花
 */
@property (nonatomic, copy) void (^showLoadingBlock)(void);
/**
 隐藏菊花
 */
@property (nonatomic, copy) void (^hideLoadingBlock)(void);
/**
 网络请求时，账号缓存过期
 */
@property (nonatomic, copy) void (^accountCacheExpiredBlock)(void);

/**
 子类可以重写该方法，执行一些视图初始化的操作
 */
- (void)initSubviews;

- (void)updateUI;


/**
 根据设备的模式返回颜色

 @return color
 */
- (UIColor *)modeColor;
/**
 更新温度
 */
- (void)updateTemperature;

/**
 显示故障
 
 @param code 故障代码
 @param faultMessage 故障信息
 @param faultId 故障id，-1为滤网故障
 */
- (void)updateUIWithFaultCode:(NSInteger)code faultMessage:(NSString *)faultMessage faultId:(NSString *)faultId;

/**
 开机

 @param sender sender 
 */
- (void)powerOnAction:(id)sender;

/**
 关机

 @param sender sender 
 */
- (void)powerOffAtcion:(id)sender;

/**
 升温

 @param sender sender 
 */
- (void)heatUpAtcion:(id)sender;

/**
 降温

 @param sender sender
 */
- (void)heatDownAtcion:(id)sender;

/**
 隐藏故障信息
 */
- (void)hideFaultInfo;

@end
