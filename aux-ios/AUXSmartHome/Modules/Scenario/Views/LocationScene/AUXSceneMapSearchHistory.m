//
//  AUXSceneMapSearchHistory.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneMapSearchHistory.h"

@implementation AUXSceneMapSearchHistory


- (IBAction)clearButtonAtcion:(id)sender {
    if (self.clearBlock) {
        self.clearBlock();
    }
}


@end
