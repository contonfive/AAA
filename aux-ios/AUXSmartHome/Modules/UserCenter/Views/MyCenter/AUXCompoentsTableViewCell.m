//
//  AUXCompoentsTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/7.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXCompoentsTableViewCell.h"
#import "AUXArchiveTool.h"

@implementation AUXCompoentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDeviceInfo:(AUXDeviceInfo *)deviceInfo {
   _deviceInfo = deviceInfo;
}

- (IBAction)switchAtcion:(id)sender {
    self.switchButton.selected = !self.switchButton.selected;
    if (self.switchButton.selected) {
        NSArray *tmpArray = [[AUXArchiveTool readDataByNSFileManager] mutableCopy];
        if (tmpArray.count>3) {
            self.switchButton.selected = NO;
        }else{
           [self.switchButton setImage:[UIImage imageNamed:@"common_btn_on"] forState:UIControlStateNormal];
        }
    }else{
        [self.switchButton setImage:[UIImage imageNamed:@"common_btn_off"] forState:UIControlStateNormal];
    }
    if (self.tapBlcok) {
        self.tapBlcok(self.deviceInfo);
    }
}


@end
