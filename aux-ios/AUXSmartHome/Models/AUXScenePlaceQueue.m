//
//  AUXScenePlaceQueue.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/23.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXScenePlaceQueue.h"
#import "AUXLocateTool.h"
#import "AUXNetworkManager.h"
#import "NSDate+AUXCustom.h"
#import <AMapLocationKit/AMapLocationKit.h>
#define kMinDistance (0)

@interface AUXScenePlaceQueue ()<AUXLocateToolDeletate,AMapLocationManagerDelegate>
@property (nonatomic,strong) NSMutableArray <AUXSceneDetailModel *> *sceneDetailArray;
@property (nonatomic, strong) NSMutableArray <NSString *> *weekArray;
@property (nonatomic,strong) AMapLocationManager*locationManager;
@end

@implementation AUXScenePlaceQueue

+ (instancetype)sharedInstance
{
    static AUXScenePlaceQueue *scenePlaceQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scenePlaceQueue = [[AUXScenePlaceQueue alloc] init];
    });
    return scenePlaceQueue;
}

- (void)start{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark getters
- (NSMutableArray<AUXSceneDetailModel *> *)sceneDetailArray {
    if (!_sceneDetailArray) {
        _sceneDetailArray = [[NSMutableArray alloc] init];
    }
    return _sceneDetailArray;
}


- (void)appendTask:(AUXSceneDetailModel *)sceneDetailModel {
    if (!sceneDetailModel) {
        return ;
    }
    [self.sceneDetailArray addObject:sceneDetailModel];
}

- (NSMutableArray<NSString *> *)weekArray {
    if (!_weekArray) {
        _weekArray = [NSMutableArray array];
        [_weekArray addObject:@"星期一"];
        [_weekArray addObject:@"星期二"];
        [_weekArray addObject:@"星期三"];
        [_weekArray addObject:@"星期四"];
        [_weekArray addObject:@"星期五"];
        [_weekArray addObject:@"星期六"];
        [_weekArray addObject:@"星期日"];
    }
    return _weekArray;
}


#pragma mark  开始定位
- (void)startSerialLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark  结束定位
- (void)stopSerialLocation{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark  定位回调
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    
    if (self.sceneDetailArray.count==0) {
    }else{
        NSLog(@"$$$$$$$$:%f---%f",location.coordinate.longitude,location.coordinate.latitude);
        NSMutableArray *tmpArray = self.sceneDetailArray.mutableCopy;
        for (AUXSceneDetailModel*model in tmpArray) {
            NSArray *localArray = [model.location componentsSeparatedByString:@","];
            double latitude = [localArray.firstObject doubleValue];
            double longitude = [localArray.lastObject doubleValue];
            double targetDistance = model.distance;
            double currentDistance = [self distanceBetweenOrderBy:latitude :location.coordinate.latitude :longitude :location.coordinate.longitude];
            
            if (model.actionType==AUXScenePlaceTypeOfGoHome) {
                if (currentDistance<=targetDistance) {
                    [[AUXNetworkManager manager] placeSceneWithSceneId:model.sceneId completion:^(BOOL success, NSError * _Nonnull error) {
                    }];
                }
                NSMutableArray *tmpArray = self.sceneDetailArray.mutableCopy;
                for (AUXSceneDetailModel*model in tmpArray) {
                    if ([model.sceneId isEqualToString:model.sceneId]) {
                        if ([self.sceneDetailArray containsObject:model]) {
                             [self.sceneDetailArray removeObject:model];
                        }
                       
                    }
                }
            }else{
                if (currentDistance>=targetDistance) {
                    [[AUXNetworkManager manager] placeSceneWithSceneId:model.sceneId completion:^(BOOL success, NSError * _Nonnull error) {
                    }];
                    NSMutableArray *tmpArray = self.sceneDetailArray.mutableCopy;
                    for (AUXSceneDetailModel*model in tmpArray) {
                        if ([model.sceneId isEqualToString:model.sceneId]) {
                            if ([self.sceneDetailArray containsObject:model]) {
                                [self.sceneDetailArray removeObject:model];
                            }
                            
                        }
                    }
                }
            }
        }
    }
}


#pragma mark  判断两个经纬度之间的距离
-(double)distanceBetweenOrderBy:(double) lat1 :(double) lat2 :(double) lng1 :(double) lng2{
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:lat1 longitude:lng1];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:lat2 longitude:lng2];
    double  distance  = [curLocation distanceFromLocation:otherLocation];
    return  distance;
}

- (void)requestOpenPlaceScene {
    if (![AUXUser isLogin]) {
        return ;
    }
    [[AUXNetworkManager manager] openPlaceSceneWithCompletion:^(NSArray<AUXSceneDetailModel *> * _Nonnull detailModelList, NSError * _Nonnull error) {
        if (detailModelList.count == 0) {
            return ;
        }
        NSString *currentWeek = [self currentWeekDay];
        NSString *currentTimestamp = [NSDate cNowTimestamp]; //当前时间戳
        NSString *currentTime = [NSDate getCurrentTimes];    //当前时间
        currentTime = [currentTime stringByReplacingCharactersInRange:NSMakeRange(currentTime.length - 2, 2) withString:@"00"];
        for (AUXSceneDetailModel *sceneDetailModel in detailModelList) {
            NSArray *timeArray = [sceneDetailModel.effectiveTime componentsSeparatedByString:@"-"];
            NSString *firstObject = [timeArray firstObject];
            NSString *lastObject = [timeArray lastObject];
            NSString *beginTime = [currentTime stringByReplacingCharactersInRange:NSMakeRange(11, 5) withString:firstObject];
            
            if ([lastObject isEqualToString:@"24:00"]) {
                lastObject = @"23:59";
            }
            
            NSString *endTime = [currentTime stringByReplacingCharactersInRange:NSMakeRange(11, 5) withString:lastObject];
            long beginTimeStamp = [NSDate cTimestampFromString:beginTime];
            long endTimeStamp = [NSDate cTimestampFromString:endTime];
            
            NSArray *repeatDay;
            NSMutableArray *weekDay = [NSMutableArray array];
            if (!AUXWhtherNullString(sceneDetailModel.repeatRule)) {
                repeatDay = [sceneDetailModel.repeatRule componentsSeparatedByString:@","];
            }
            
            for (NSString *week in repeatDay) {
                [weekDay addObject:self.weekArray[week.integerValue - 1]];
            }
            
            
            if (currentTimestamp.longLongValue >= beginTimeStamp && currentTimestamp.longLongValue <= endTimeStamp) {
                
                if (weekDay.count > 0) {
                    if (![weekDay containsObject:currentWeek]) {
                        continue ;
                    }
                }
                
                self.sceneDetailArray = detailModelList.mutableCopy;
                if (self.sceneDetailArray.count>0) {
                    [self start];
                }
                
            } else {
                if (weekDay.count > 0) {
                    if (![weekDay containsObject:currentWeek]) {
                        continue ;
                    }
                }
                
                // 获取所有本地通知数组
                NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
                for (UILocalNotification *notification in localNotifications)    {        NSDictionary *userInfo = notification.userInfo;
                    if (userInfo)        {
                        // 根据设置通知参数时指定的key来获取通知参数
                        NSString *info = userInfo[@"userInfo"];
                        // 如果找到需要取消的通知，则取消
                        if ([info isEqualToString:sceneDetailModel.sceneId])            {
                            [[UIApplication sharedApplication] cancelLocalNotification:notification];
                        }
                    }
                }
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = [NSString stringWithFormat:@"场景'%@'可以执行了，请打开奥克斯A+" , sceneDetailModel.sceneName];
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:sceneDetailModel.sceneId, @"userInfo", nil];
                localNotification.userInfo = userInfo;
                
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:beginTimeStamp - currentTimestamp.longLongValue];
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            
        }
    }];
}


- (NSString *)currentWeekDay {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger week = [comps weekday];
    
    switch (week) {
        case 1:
            return @"星期日";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
            
        default:
            break;
    }
    return nil;
    
}

@end
