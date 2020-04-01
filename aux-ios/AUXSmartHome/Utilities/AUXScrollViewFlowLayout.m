//
//  AUXScrollViewFlowLayout.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/7/31.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXScrollViewFlowLayout.h"

@implementation AUXScrollViewFlowLayout
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *arrayAttrs = [[NSArray alloc]initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    
    if (!self.isZoom) {
        return arrayAttrs;
    }
    
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5;
    
    for (UICollectionViewLayoutAttributes *attr in arrayAttrs) {
        CGFloat distance = ABS(attr.center.x - centerX);
        CGFloat factor = 0.001;
        CGFloat scale = 1 / (1 + distance * factor);
        attr.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return arrayAttrs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
}


@end
