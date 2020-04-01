//
//  AUXSleepDIYAlertView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepDIYAlertView.h"

@implementation AUXSleepDIYAlertView

- (IBAction)closeAtcion:(id)sender {
    
    [self removeFromSuperview];
    
//    self.layer.masksToBounds = YES;
//    self.layer.cornerRadius = 10;
    if (self.closeBlock) {
        self.closeBlock();
    }
}


@end
