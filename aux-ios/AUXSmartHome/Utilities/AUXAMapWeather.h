//
//  AUXAMapWeather.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AUXAMapWeather , AMapLocalWeatherLive;
@protocol AUXAMapWeatherDelegate <NSObject>

@optional

- (void)aMapWeatherDelegate:(AUXAMapWeather *)aMapWeather weather:(AMapLocalWeatherLive *)live;

@end

NS_ASSUME_NONNULL_BEGIN
@interface AUXAMapWeather : NSObject


@property (nonatomic,weak) id<AUXAMapWeatherDelegate> mapDelegate;

@end

NS_ASSUME_NONNULL_END
