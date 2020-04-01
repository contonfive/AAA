//
//  AUXPrivacyStatementView.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/11/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXPrivacyStatementView.h"
#import "UILabel+AUXCustom.h"
#import "AUXConstant.h"
#import "AUXArchiveTool.h"

@interface AUXPrivacyStatementView()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *exiteButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;

@end

@implementation AUXPrivacyStatementView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    self.backView.layer.cornerRadius = 6;
    self.backView.layer.masksToBounds = YES;
    
    [self.detailLabel setRowSpace:5];
    
}
- (IBAction)privacyAtcion:(id)sender {
    if (self.jumpBlock) {
        self.jumpBlock();
    }    
}

- (IBAction)exiteAtcion:(id)sender {
    exit(0);
}

- (IBAction)agreeAtcion:(id)sender {
    [self animationHide];
}

- (void)animationHide {
    
    [AUXArchiveTool setShouldShowPrivacy:YES];
    
    self.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
}

@end
