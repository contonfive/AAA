//
//  AUXAddContactFooterView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAddContactFooterView.h"

@implementation AUXAddContactFooterView


- (IBAction)saveAtcion:(id)sender {
    if (self.saveBlock) {
        self.saveBlock();
    }
}


@end
