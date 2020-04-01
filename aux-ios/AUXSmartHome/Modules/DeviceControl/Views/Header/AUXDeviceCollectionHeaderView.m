//
//  AUXDeviceCollectionHeaderView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/16.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceCollectionHeaderView.h"
#import "AUXConstant.h"
#import "AUXLocateTool.h"
@interface AUXDeviceCollectionHeaderView()

@end

@implementation AUXDeviceCollectionHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSet)];
    [self.weatherImageView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSet)];
    [self.tempretureLabel addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSet)];
    [self.openPlacePowerLabel addGestureRecognizer:tap3];
    
}

- (void)goToSet {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)whtherAllowLocalRight {
    if ([AUXLocateTool whtherOpenLocalionPermissions] == NO) {
        self.weatherImageView.image = [UIImage imageNamed:@"index_icon_initial"];
        self.tempretureLabel.text = @"--";
        self.openPlacePowerLabel.hidden = NO;
        
        self.separiteView.hidden = YES;
        self.cityLabel.hidden = YES;
        self.weatherStatusLabel.hidden = YES;
        self.airHumidityTitleLabel.hidden = YES;
        self.pm25NumberLabel.hidden = YES;
        
        self.weatherImageView.userInteractionEnabled = YES;
        self.tempretureLabel.userInteractionEnabled = YES;
        self.openPlacePowerLabel.userInteractionEnabled = YES;
    } else {
        self.openPlacePowerLabel.hidden = YES;
        
        self.separiteView.hidden = NO;
        self.cityLabel.hidden = NO;
        self.weatherStatusLabel.hidden = NO;
        self.airHumidityTitleLabel.hidden = NO;
        self.pm25NumberLabel.hidden = NO;
        
        self.weatherImageView.userInteractionEnabled = NO;
        self.tempretureLabel.userInteractionEnabled = NO;
        self.openPlacePowerLabel.userInteractionEnabled = NO;
    }
}

#pragma mark setters
- (void)setLive:(AMapLocalWeatherLive *)live {
    _live = live;
    
    if (_live) {
        
        self.tempretureLabel.hidden = NO;
        self.cityLabel.hidden = NO;
        self.openPlacePowerLabel.hidden = YES;
        self.separiteView.hidden = NO;
        self.weatherStatusLabel.hidden = NO;
        self.airHumidityTitleLabel.hidden = NO;
        self.pm25NumberLabel.hidden = NO;
        
        self.tempretureLabel.text = [NSString stringWithFormat:@"%@°C" , _live.temperature];
        self.cityLabel.text = _live.city;
        self.pm25NumberLabel.text = [NSString stringWithFormat:@"%@%%" , _live.humidity];
        self.weatherStatusLabel.text = _live.weather;
        
        NSString *imageString = @"index_icon_cloudy";
        if ([_live.weather containsString:@"晴"]) {
            imageString = @"index_icon_晴";
        } else if ([_live.weather containsString:@"多云"]) {
            imageString = @"index_icon_多云";
        } else if ([_live.weather containsString:@"阴"]) {
            imageString = @"index_icon_阴";
        } else if ([_live.weather containsString:@"雨"]) {
            imageString = @"index_icon_雨";
        } else if ([_live.weather containsString:@"雪"]) {
            imageString = @"index_icon_雪";
        } else if ([_live.weather containsString:@"雾"] || [_live.weather containsString:@"霾"]) {
            imageString = @"index_icon_雾霾";
        } else if ([_live.weather containsString:@"沙尘"]) {
            imageString = @"index_icon_沙尘";
        } else {
            imageString = @"index_icon_cloudy";
        }
        self.weatherImageView.image = [UIImage imageNamed:imageString];
    } else {
        self.tempretureLabel.hidden = YES;
        self.cityLabel.hidden = YES;
        self.openPlacePowerLabel.hidden = YES;
        self.separiteView.hidden = YES;
        self.weatherStatusLabel.hidden = YES;
        self.airHumidityTitleLabel.hidden = YES;
        self.pm25NumberLabel.hidden = YES;
        
    }
    
    if ([AUXLocateTool whtherOpenLocalionPermissions] == NO) {
        self.tempretureLabel.text = @"--";
        self.openPlacePowerLabel.hidden = NO;
        self.tempretureLabel.hidden = NO;
        
        self.separiteView.hidden = YES;
        self.cityLabel.hidden = YES;
        self.weatherStatusLabel.hidden = YES;
        self.airHumidityTitleLabel.hidden = YES;
        self.pm25NumberLabel.hidden = YES;
        
        self.weatherImageView.userInteractionEnabled = YES;
        self.tempretureLabel.userInteractionEnabled = YES;
        self.openPlacePowerLabel.userInteractionEnabled = YES;
    }
}

@end
