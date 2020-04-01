//
//  UILabel+AUXCustom.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/23.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "UILabel+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import <CoreText/CoreText.h>

@implementation UILabel (AUXCustom)

+ (void)load{
    
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    
    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
    
    method_exchangeImplementations(imp, myImp);
    
}

- (id)myInitWithCoder:(NSCoder*)aDecode{
    
    [self myInitWithCoder:aDecode];
    
    if (self) {
        CGFloat fontSize = self.font.pointSize;
        NSString *fontName = self.font.fontName;
        
        self.font = [UIFont fontWithName:fontName size:fontSize];
    }
    return self;
}

- (void)setColumnSpace:(CGFloat)columnSpace
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    //调整间距
    [attributedString addAttribute:(__bridge NSString *)kCTKernAttributeName value:@(columnSpace) range:NSMakeRange(0, [attributedString length])];
    self.attributedText = attributedString;
}

- (void)setRowSpace:(CGFloat)rowSpace
{
    self.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    //调整行距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = rowSpace;
    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
    self.attributedText = attributedString;
}

-(void)setLabelSpaceWithValue:(NSString *)str withRowHeight:(CGFloat)rowHeight {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = rowHeight; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:self.font, NSParagraphStyleAttributeName:paraStyle};
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    self.attributedText = attributeStr;
}

- (void)setLabelAttributedString:(NSString *)text color:(UIColor *)color{
    NSString *title = self.text;
    NSRange componentRange = [title rangeOfString:text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:title];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:componentRange];
    self.attributedText = attributedString;
}

- (void)setLabelAttributedStringWithTextArray:(NSArray <NSString *>*)textArray color:(UIColor *)color {
    NSString *title = self.text;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:title];
    for (NSString *text in textArray) {
        NSRange componentRange = [title rangeOfString:text];
        [attributedString addAttribute:NSForegroundColorAttributeName value:color range:componentRange];
        
        if ([text isEqualToString:@"限制空调"]) {
            NSRange componentRange = [title rangeOfString:@"空调"];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"8E959D"] range:componentRange];
        }
        
    }
    self.attributedText = attributedString;
}

- (void)setLabelAnimateText:(NSString *)text completion:(void (^)(void))completion{
    
    dispatch_queue_t queue = dispatch_queue_create(0, 0);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < text.length; i++)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.text = [text substringWithRange:NSMakeRange(0, i+1)];
                
                if (self.text.length == text.length) {
                    if (completion) {
                        completion();
                    }
                }
                
            });
            
            [NSThread sleepForTimeInterval:0.3];
        }
    });
    

}

@end
