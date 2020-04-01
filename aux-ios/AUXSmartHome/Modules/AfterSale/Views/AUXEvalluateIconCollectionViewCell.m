//
//  AUXEvalluateIconCollectionViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/9.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXEvalluateIconCollectionViewCell.h"

@implementation AUXEvalluateIconCollectionViewCell


- (IBAction)deleteAtcion:(id)sender {
    
    if (self.deleteBlock) {
        self.deleteBlock(self.imageView.image);
    }
    
}

@end
