/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXGatewayDeviceGirdCollectionViewCell.h"
#import "UIColor+AUXCustom.h"
#import "AUXConfiguration.h"

@interface AUXGatewayDeviceGirdCollectionViewCell ()
@property (nonatomic, assign) NSInteger deviceTotalCount;
@end

@implementation AUXGatewayDeviceGirdCollectionViewCell

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
