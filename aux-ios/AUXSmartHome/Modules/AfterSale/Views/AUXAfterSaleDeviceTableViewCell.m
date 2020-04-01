//
//  AUXAfterSaleDeviceTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleDeviceTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AUXAfterSaleDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    _deviceInfo = deviceInfo;
    
    [self.deviceImageView sd_setImageWithURL:[NSURL URLWithString:_deviceInfo.deviceMainUri] placeholderImage:nil options:SDWebImageRefreshCached];
    self.deviceLabel.text = _deviceInfo.alias;
}

@end
