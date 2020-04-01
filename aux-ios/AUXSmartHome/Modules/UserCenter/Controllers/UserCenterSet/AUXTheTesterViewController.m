//
//  AUXTheTesterViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTheTesterViewController.h"

@interface AUXTheTesterViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *testerImageview;
@property (weak, nonatomic) IBOutlet UIImageView *displayImageview;
@property (weak, nonatomic) IBOutlet UIButton *testerButton;
@property (weak, nonatomic) IBOutlet UIButton *displayButton;

@end

@implementation AUXTheTesterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL istheTester = [[MyDefaults objectForKey:kIsTheTester] integerValue];
    BOOL isListed = [[MyDefaults objectForKey:kIslisted] integerValue];
    
    if (istheTester) {
        self.testerImageview.image = [UIImage imageNamed:@"common_btn_on"];
        self.testerButton.selected = YES;
        if (isListed) {
            self.displayImageview.image = [UIImage imageNamed:@"common_btn_on"];
            self.displayButton.selected = YES;
        }else{
            self.displayImageview.image = [UIImage imageNamed:@"common_btn_off"];
            self.displayButton.selected = NO;
        }
    }else{
        self.testerImageview.image = [UIImage imageNamed:@"common_btn_off"];
        self.displayImageview.image = [UIImage imageNamed:@"common_btn_off"];
        self.displayButton.selected = NO;
        self.testerButton.selected = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (IBAction)testerButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.testerImageview.image = [UIImage imageNamed:@"common_btn_on"];
        self.displayButton.enabled = YES;
        [MyDefaults setObject:@"1" forKey:kIsTheTester];
    }else{
        self.testerImageview.image = [UIImage imageNamed:@"common_btn_off"];
        self.displayImageview.image = [UIImage imageNamed:@"common_btn_off"];
        [MyDefaults setObject:@"0" forKey:kIsTheTester];
        [MyDefaults setObject:@"0" forKey:kIslisted];
        self.displayButton.enabled = NO;
    }
}

- (IBAction)disPlayButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.displayImageview.image = [UIImage imageNamed:@"common_btn_on"];
        [MyDefaults setObject:@"1" forKey:kIslisted];
    }else{
        self.displayImageview.image = [UIImage imageNamed:@"common_btn_off"];
        [MyDefaults setObject:@"0" forKey:kIslisted];

    }
}

@end
