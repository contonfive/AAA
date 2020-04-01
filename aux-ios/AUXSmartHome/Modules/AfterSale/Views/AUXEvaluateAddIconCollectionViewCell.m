//
//  AUXEvaluateAddIconCollectionViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/9.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXEvaluateAddIconCollectionViewCell.h"

@implementation AUXEvaluateAddIconCollectionViewCell

- (void)setImagesArray:(NSMutableArray *)imagesArray {
    _imagesArray = imagesArray;
    
    self.numberLabel.text = _imagesArray.count == 0 ? @"添加图片" : [NSString stringWithFormat:@"%ld/4" , _imagesArray.count];
}

@end
