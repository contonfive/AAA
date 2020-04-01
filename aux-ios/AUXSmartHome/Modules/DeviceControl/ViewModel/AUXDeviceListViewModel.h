//
//  AUXDeviceListViewModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/4.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AUXDeviceInfo.h"

@protocol AUXDeviceListViewModelDelegate <NSObject>

@optional

- (void)viewModelDelegateOfGetDeviceListStatus:(NSError *)error;

- (void)viewModelDelegateOfRefrashDeviceStatus;

- (void)viewModelDelegateOfShowLoading;

- (void)viewModelDelegateOfHideLoading;

- (void)viewModelDelegateOfError:(NSError *)error;

- (void)viewModelDelegateOfMessage:(NSString *)message;

@end

@interface AUXDeviceListViewModel : NSObject

@property (nonatomic,weak) id<AUXDeviceListViewModelDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;

- (void)requestDeviceList;

/// 查询服务器的设备列表
- (void)getSaasDeviceList;

/// 调用 SDK 搜索设备
- (void)getBoundDevices;

/**
 获取设备列表完成，逻辑处理

 @param deviceInfoList 获取到的设备列表
 @param error error
 */
- (void)didGetDeviceList:(NSArray<AUXDeviceInfo *> *)deviceInfoList error:(NSError *)error;

@end
