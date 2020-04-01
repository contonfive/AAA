//
//  AUXNoDeviceCollectionViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXNoDeviceCollectionViewCell.h"

@implementation AUXNoDeviceCollectionViewCell
- (IBAction)addDeviceAtcion:(id)sender {
    if (self.addDeviceBlock) {
        self.addDeviceBlock();
    }
}

@end
