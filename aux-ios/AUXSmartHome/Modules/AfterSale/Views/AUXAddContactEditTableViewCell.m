//
//  AUXAddContactEditTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/25.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAddContactEditTableViewCell.h"
#import "NSString+AUXCustom.h"

@interface AUXAddContactEditTableViewCell ()
@property (nonatomic,copy) NSString *changedString;
@end

@implementation AUXAddContactEditTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    //监听textfield的输入状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeValue:)         name:UITextFieldTextDidChangeNotification object:self.editTextfiled];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    self.bottomView.hidden = NO;
    
    switch (indexPath.row) {
        case 0:
            self.titleLabel.text = @"联系人";
            self.editTextfiled.placeholder = @"联系人姓名";
            break;
        case 1:
            self.titleLabel.text = @"手机号码";
            self.editTextfiled.placeholder = @"收货人手机号码";
            break;
        case 2:
            self.titleLabel.text = @"所在地区";
            self.editTextfiled.placeholder = @"请选择所在地区";
            break;
        case 3:
            self.titleLabel.text = @"详细地址";
            self.editTextfiled.placeholder = @"填写门牌号，如1幢101室";
            self.bottomView.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)setModel:(AUXTopContactModel *)model {
    _model = model;
    
    if (_model) {
        if (self.indexPath.row == 0) {
            self.editTextfiled.text = _model.Name;
            self.editTextfiled.maximumTextLength = 20;
        } else if (self.indexPath.row == 1) {
            self.editTextfiled.text = _model.Phone;
            self.editTextfiled.maximumTextLength = 11;
        } else if (self.indexPath.row == 2) {
            NSString *localString = nil;
            if (_model.Province) {
                localString = _model.Province;
            }
            if (_model.City) {
                localString = [NSString stringWithFormat:@"%@ %@" , localString , _model.City];
            }
            if (_model.County) {
                localString = [NSString stringWithFormat:@"%@ %@" , localString , _model.County];
            }
            if (_model.Town) {
                localString = [NSString stringWithFormat:@"%@ %@" , localString , _model.Town];
            }
            self.editTextfiled.text = localString;
            
        } else if (self.indexPath.row == 3) {
            self.editTextfiled.text = _model.Address;
        }
    }
    
}

- (void)textFieldDidChangeValue:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)[notification object];
    
    if (textField == self.editTextfiled) {
        
        if ([self.editTextfiled.text isStringWithEmoji]) {
            textField.text = self.changedString;
            return;
        }
        
        if ([self.editTextfiled.text containsString:@" "]) {
            self.editTextfiled.text = [self.editTextfiled.text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
        }
        
        UITextRange *selectedRange = textField.markedTextRange;
        if ([textField positionFromPosition:selectedRange.start offset:0]) {
            // 正在操作，不计算长度
            return;
        }
        self.changedString = textField.text;
    }
    
    if(textField.text.length != 0) {
        if (self.textfiledBlock) {
            self.textfiledBlock(textField.text);
        }
    }
}

@end
