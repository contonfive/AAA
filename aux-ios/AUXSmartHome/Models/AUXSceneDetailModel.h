//
//  AUXSceneDetailModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/7.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
#import "AUXSceneDeviceModel.h"
@interface AUXSceneDetailModel : NSObject

/**
 场景执行描述
 */
@property (nonatomic,copy) NSString *actionDescription;
/**
 定时字段(执行时间,00:00)
 */
@property (nonatomic,copy) NSString *actionTime;
/**
 位置字段(执行类型 1离开 2进入)
 */
@property (nonatomic,assign) AUXScenePlaceType actionType;

/**
 设备动作
 */
@property (nonatomic,strong) NSMutableArray<AUXSceneDeviceModel *> *deviceActionVoList;

/**
位置字段(执行距离)
 */
@property (nonatomic,assign) NSInteger distance;
/**
位置字段(有效时间,00:00-00:00)
 */
@property (nonatomic,copy) NSString *effectiveTime;

/**
 是否存在有效设备动作标志 true存在 false不存在
 */
@property (nonatomic,assign) BOOL existdevice;

/**
 初始化标志 0手动生成 1初始化生成 2初始化生成已被设置
 */
@property (nonatomic,assign) NSInteger whetherInitFlag;

/**
 位置字段(目标方位 经度,纬度 例:112.43,28.116)
 */
@property (nonatomic,copy) NSString *location;

/**
 位置字段(详细地址)
 */
@property (nonatomic,copy) NSString *address;

/**
 目标地址(有location 经过返地理编码得到)
 */
//@property (nonatomic,copy) NSString *currentLocation;

/**
 循环规则，周一到周日之间7天可以选择多天执行，多天用英文逗号隔开
 */
@property (nonatomic,copy) NSString *repeatRule;
/**
 场景Id
 */
@property (nonatomic,copy) NSString *sceneId;
/**
 场景名称
 */
@property (nonatomic,copy) NSString *sceneName;
/**
 场景类型1:位置2:时间3:手动 ,
 */
@property (nonatomic,assign) AUXSceneType sceneType;
/**
 开启状态 1开启 2关闭
 */
@property (nonatomic,assign) AUXScenePower state;
/**
 用户id
 */
@property (nonatomic,copy) NSString *uid;
@end
