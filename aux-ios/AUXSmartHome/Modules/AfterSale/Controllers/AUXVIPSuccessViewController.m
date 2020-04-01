//
//  AUXVIPSuccessViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/12.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXVIPSuccessViewController.h"
#import "UIColor+AUXCustom.h"

@interface AUXVIPSuccessViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation AUXVIPSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sureBtn.layer.cornerRadius = self.sureBtn.frame.size.height / 2;
    self.sureBtn.layer.borderColor = [UIColor colorWithHexString:@"666666"].CGColor;
    self.sureBtn.layer.borderWidth = 2;
    self.sureBtn.layer.masksToBounds = YES;
}

- (IBAction)sureAtcion:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
