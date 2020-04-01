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
#import "AUXDeviceCollectionViewCell.h"

/**
 设备列表 (该VC的界面在 Homepage.storyboard 中)
 */
@interface AUXDeviceListViewController : AUXBaseViewController

/// 标识是否出现过一次
@property (nonatomic, assign) BOOL hasAlreadyAppeared;

@property (nonatomic,copy) NSString *currentDeviceId;

@property (nonatomic,assign) BOOL whtherRequestDeviceList;

// 当前列表样式
@property (nonatomic,assign) AUXDeviceListType currentDeviceListType;

/**
 微信点击分享的链接，跳转到设备列表，进行设备绑定

 @param qrContent 连接中包含的设备deviceID
 */
- (void)acceptDeviceShareWithQRContent:(NSString *)qrContent;

/**
 根据设备deviceId或者设备mac地址跳转到控制页

 @param deviceID deviceID
 @param deviceMac deviceMac
 */
- (void)pushToDeviceControllerWithDeviceId:(NSString *)deviceID orDeviceMac:(NSString *)deviceMac;

@end
