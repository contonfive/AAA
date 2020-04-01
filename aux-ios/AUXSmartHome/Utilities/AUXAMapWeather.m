//
//  AUXAMapWeather.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAMapWeather.h"
#import "AUXLocateTool.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface AUXAMapWeather ()<AMapSearchDelegate , AUXLocateToolDeletate>

// 高德地图(用来获取天气)
@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) AMapWeatherSearchRequest *request;
@end

@implementation AUXAMapWeather

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setAMap];
    }
    return self;
}

#pragma mark 配置高德地图
- (void)setAMap {
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

- (void)locateTool {
    
    [AUXLocateTool defaultTool].delegate = self;
    BOOL result = [[AUXLocateTool defaultTool] requestLocation];
    
    if (!result) {
        [self requestWeather:@"北京市"];
    }
}

#pragma mark - AUXLocateToolDeletate
- (void)locateToolDidUpdateLocation:(AUXLocateTool *)locateTool {
    [self requestWeather:locateTool.city ? locateTool.city : @"北京市"];
}

#pragma mark AMapSearchDelegate -- 请求天气
- (void)requestWeather:(NSString *)city {
    self.request.city = city;
    [self.search AMapWeatherSearch:self.request];
}

- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response {
    //解析response获取天气信息，具体解析见 Demo
    AMapLocalWeatherLive *live = [response.lives firstObject];
    
    if (live && _mapDelegate && [_mapDelegate respondsToSelector:@selector(aMapWeatherDelegate:weather:)]) {
        [_mapDelegate aMapWeatherDelegate:self weather:live];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

@end
