//
//  AUXGatewayDeviceListCollectionViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXGatewayDeviceListCollectionViewCell.h"

#import "UIColor+AUXCustom.h"
#import "AUXConfiguration.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXGatewayDeviceListCollectionViewCell()

@property (nonatomic, assign) NSInteger deviceTotalCount;
@end

@implementation AUXGatewayDeviceListCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.deviceTotalCount = 0;
}

- (void)initSubviews {
    [super initSubviews];
    
}

#pragma mark - Setters
- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    [super setDeviceInfo:deviceInfo];
}

- (void)setOffline:(BOOL)offline {
    [super setOffline:offline];
    
    AUXACDevice *device = self.deviceDictionary[self.deviceInfo.deviceId];
    if (!self.offline) {
        self.deviceTotalCount = device.aliasDic.count;
    } else {
        self.sumCountLabel.text = @"离线";
    }
}

- (void)setDeviceTotalCount:(NSInteger)deviceTotalCount {
    _deviceTotalCount = deviceTotalCount;
    
    self.sumCountLabel.text = [NSString stringWithFormat:@"%@台", @(deviceTotalCount)];
}


@end
