//
//  AUXStoreSearchView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/5/17.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXStoreSearchView.h"

@interface AUXStoreSearchView ()<UITextFieldDelegate>

@end

@implementation AUXStoreSearchView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backView.layer.cornerRadius = self.backView.frame.size.height / 2;
    self.backView.layer.masksToBounds = YES;
    
    [self.searchTextFiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


- (void)textFieldDidChange:(UITextField *)textField {
    
    if (self.searchBlock) {
        self.searchBlock(textField.text);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.searchBlock) {
        self.searchBlock(textField.text);
    }
    
    return YES;
}

- (IBAction)cancleAtcion:(id)sender {
    
    if (self.cancleBlock) {
        self.cancleBlock();
    }
}

@end
