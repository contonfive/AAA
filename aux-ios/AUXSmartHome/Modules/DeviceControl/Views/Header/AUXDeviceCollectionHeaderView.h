//
//  AUXDeviceCollectionHeaderView.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/16.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchObj.h>
#import "AUXSceneDetailModel.h"

@interface AUXDeviceCollectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *tempretureLabel;

@property (weak, nonatomic) IBOutlet UILabel *openPlacePowerLabel;

@property (weak, nonatomic) IBOutlet UIView *separiteView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *airHumidityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pm25NumberLabel;

@property (nonatomic,strong) AMapLocalWeatherLive *live;

- (void)whtherAllowLocalRight;
@end
