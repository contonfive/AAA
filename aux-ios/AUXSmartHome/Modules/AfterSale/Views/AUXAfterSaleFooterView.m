//
//  AUXAfterSaleFooterView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleFooterView.h"

@implementation AUXAfterSaleFooterView

- (IBAction)phoneButtonAtcion:(id)sender {
    if (self.phoneBlock) {
        self.phoneBlock();
    }
}

@end
