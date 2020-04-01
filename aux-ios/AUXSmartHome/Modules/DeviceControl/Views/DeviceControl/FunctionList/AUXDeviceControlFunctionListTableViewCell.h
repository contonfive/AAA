//
//  AUXDeviceControlFunctionListTableViewCell.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXBaseTableViewCell.h"
#import "AUXDeviceFunctionItem.h"
#import "AUXDeviceStatus.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXDeviceControlFunctionListTableViewCell : AUXBaseTableViewCell

@property (nonatomic, strong) UICollectionView *onCollectionView;
@property (nonatomic, strong) UICollectionView *offCollectionView;

/// 数据源 开机状态下的功能列表
@property (nonatomic, strong) NSArray<AUXDeviceFunctionItem *> *onFunctionList;
/// 数据源 关机状态下的功能列表
@property (nonatomic, strong) NSArray<AUXDeviceFunctionItem *> *offFunctionList;


@property (nonatomic,strong) AUXDeviceStatus *deviceStatus;

/// 选择了开机状态下的某个功能时
@property (nonatomic, copy) void (^didSelectOnItemBlock)(NSInteger item);
/// 选择了关机状态下的某个功能时
@property (nonatomic, copy) void (^didSelectOffItemBlock)(NSInteger item);

- (void)reloadData;

+ (CGFloat)heightForFunctionItem;


@end

NS_ASSUME_NONNULL_END
