/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXTextFieldTableViewCell.h"
#import "NSString+AUXCustom.h"

@interface AUXTextFieldTableViewCell () <UITextFieldDelegate>

@property (retain, nonatomic) NSString *changedString;

@end

@implementation AUXTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(didChangedText:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didChangedText:(UITextField *)textField {
    if (textField == self.textField) {
        
        if ([self.textField.text isStringWithEmoji]) {
            textField.text = self.changedString;
            return;
        }
        
        if ([self.textField.text containsString:@" "]) {
            self.textField.text = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
        }
        
        UITextRange *selectedRange = textField.markedTextRange;
        if ([textField positionFromPosition:selectedRange.start offset:0]) {
            // 正在操作，不计算长度
            return;
        }
        
        if (textField.text.length > self.maxLength) {
            textField.text = [textField.text substringToIndex:self.maxLength];
        } else {
            self.changedString = textField.text;
        }
    }
}

- (NSString *)getTextFieldText {
    return [self.textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "];
}

- (void)setTextFieldText:(NSString *)text {
    self.textField.text = [text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
    self.changedString = self.textField.text;
}

@end
