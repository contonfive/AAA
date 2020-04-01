//
//  AUXComponentsTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/5/31.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXComponentsTableViewCell.h"

@implementation AUXComponentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
    _deviceInfo = deviceInfo;
}

- (IBAction)switchAtcion:(id)sender {
    self.switchButton.selected = !self.switchButton.selected;
    self.tapBlcok(self.deviceInfo);
}

@end
