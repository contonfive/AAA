//
//  AUXCodeViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (Category)
+ (CALayer *)addSubLayerWithFrame:(CGRect)frame
                  backgroundColor:(UIColor *)color
                         backView:(UIView *)baseView;
@end
