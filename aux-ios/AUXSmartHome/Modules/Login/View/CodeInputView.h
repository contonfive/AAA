//
//  AUXCodeViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/3/25.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectCodeBlock)(NSString *);
@interface CodeInputView : UIView
@property(nonatomic,copy)SelectCodeBlock CodeBlock;
@property(nonatomic,strong)UITextView * textView;
@property(nonatomic,assign)NSInteger inputNum;//验证码输入个数（4或6个）
- (instancetype)initWithFrame:(CGRect)frame inputType:(NSInteger)inputNum selectCodeBlock:(SelectCodeBlock)CodeBlock;
@end
