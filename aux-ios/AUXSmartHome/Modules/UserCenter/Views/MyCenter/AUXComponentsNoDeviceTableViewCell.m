//
//  AUXComponentsNoDeviceTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/13.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXComponentsNoDeviceTableViewCell.h"

@implementation AUXComponentsNoDeviceTableViewCell

- (IBAction)addDeviceAtcion:(id)sender {
    if (self.addDeviceBlock) {
        self.addDeviceBlock();
    }
}



@end
