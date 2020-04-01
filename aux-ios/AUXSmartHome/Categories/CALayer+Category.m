//
//  AUXCodeViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "CALayer+Category.h"

@implementation CALayer (Category)
+ (CALayer *)addSubLayerWithFrame:(CGRect)frame
                  backgroundColor:(UIColor *)color
                         backView:(UIView *)baseView
{
    CALayer * layer = [[CALayer alloc]init];
    layer.frame = frame;
    layer.backgroundColor = [color CGColor];
    [baseView.layer addSublayer:layer];
    return layer;
}
@end
