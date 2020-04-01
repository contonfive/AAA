//
//  AUXSceneCommonModel.h
//  AUXSmartHome
//
//  Created by AUX on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXSceneCommonModel : NSObject
+(instancetype)shareAUXSceneCommonModel;

@property (nonatomic,copy) NSString *actionDescription;

/**
 定时字段(执行时间,00:00)
 */
@property (nonatomic,copy) NSString *actionTime;

/**
 位置字段(执行类型 1离开 2进入)
 */
@property (nonatomic,assign) NSInteger actionType;

/**
 设备动作
 */
@property (nonatomic,copy) NSMutableArray *deviceActionDtoList;

/**
 位置字段(执行距离)
 */
@property (nonatomic,assign) NSInteger distance;

/**
 位置字段(有效时间,00:00-00:00)
 */
@property (nonatomic,copy) NSString *effectiveTime;

/**
 是否首页标记
 */
@property (nonatomic,assign) BOOL homePageFlag;

/**
 位置字段(目标方位 经度,纬度 例:112.43,28.116)
 */
@property (nonatomic,copy) NSString *location;

/**
 位置字段(详细地址)
 */
@property (nonatomic,copy) NSString *address;

/**
 循环规则，周一到周日之间7天可以选择多天执行，多天用英文逗号隔开
 */
@property (nonatomic,copy) NSString *repeatRule;

/**
 场景名称
 */
@property (nonatomic,copy) NSString *sceneName;

/**
 场景类型1:位置2:时间3:手动
 */
@property (nonatomic,assign) NSInteger sceneType;

/**
 开启状态 0关闭 1开启
 */
@property (nonatomic,assign) NSInteger state;

/**
 用户Id
 */
@property (nonatomic,copy) NSString *uid;


@property (nonatomic,copy) NSString *sceneId;


@property (nonatomic,assign) BOOL isBack;

@property (nonatomic,assign) BOOL isEdit;

@property (nonatomic,assign) NSInteger whetherInitFlag;

- (void)reSetValue;

@end

NS_ASSUME_NONNULL_END
