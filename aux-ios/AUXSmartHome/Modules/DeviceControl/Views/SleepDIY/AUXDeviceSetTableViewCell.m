//
//  AUXDeviceSetTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDeviceSetTableViewCell.h"

@implementation AUXDeviceSetTableViewCell

+ (CGFloat)properHeight {
    return 75;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)windAtcion:(id)sender {
    if (self.windBlock) {
        self.windBlock();
    }
}

- (IBAction)sleepDIYHelpAtcion:(id)sender {
    if (self.helpBlock) {
        self.helpBlock();
    }
}

- (IBAction)smartAtcion:(id)sender {
    AUXChooseButton *btn = (AUXChooseButton *)sender;
    btn.selected = !btn.selected;
    
    if (self.smartBlock) {
        self.smartBlock(btn.selected);
    }
}

@end
