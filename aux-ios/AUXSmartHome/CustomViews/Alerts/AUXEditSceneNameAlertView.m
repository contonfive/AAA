//
//  AUXEditSceneNameAlertView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXEditSceneNameAlertView.h"

@implementation AUXEditSceneNameAlertView

+ (instancetype)editSceneNameAlertViewcancelBlock:(void (^)(void))cancelBlock confirmBlock:(void (^)(NSString*name))confirmBlock {
    AUXEditSceneNameAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AUXCustomAlertView" owner:nil options:nil] objectAtIndex:5];
    alertView.cancelBlock = cancelBlock;
    alertView.confirmBlock = confirmBlock;
    return alertView;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
}

- (IBAction)confirmButtonAction:(UIButton *)sender {
     self.confirmBlock(self.nameTextField.text);
}
- (IBAction)cancleButtoinAction:(UIButton *)sender {
     self.cancelBlock();
}


@end
