//
//  AUXAfterSaleLeaveMessageCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleLeaveMessageCell.h"
#import "NSString+AUXCustom.h"
#import "UIColor+AUXCustom.h"

@interface AUXAfterSaleLeaveMessageCell ()<UITextViewDelegate>

@property (nonatomic,copy) NSString *changedString;
@end

@implementation AUXAfterSaleLeaveMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.whtherMustImageView.hidden = YES;
}

- (void)textViewDidChange:(QMUITextView *)textView {
    
    if ([textView.text isStringWithEmoji]) {
        textView.text = self.changedString;
        return;
    }
    
    if ([textView.text containsString:@" "]) {
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
    }
    
    self.changedString = textView.text;
    
    if (self.leaveTextViewBlock) {
        self.leaveTextViewBlock(textView.text);
    }
}


@end
