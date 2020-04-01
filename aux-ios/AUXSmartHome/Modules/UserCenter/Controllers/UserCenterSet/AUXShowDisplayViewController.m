//
//  AUXShowDisplayViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/30.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXShowDisplayViewController.h"
#import "AUXArchiveTool.h"

@interface AUXShowDisplayViewController ()
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *gonggeButton;

@end

@implementation AUXShowDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AUXDeviceListType type = [AUXArchiveTool readDeviceListType];
    
    [self isGongge:type];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

#pragma mark  列表按钮的点击事件
- (IBAction)listButtonAction:(UIButton *)sender {
    [self isGongge:AUXDeviceListTypeOfList];
}

#pragma mark  宫格按钮的点击事件
- (IBAction)gonggeButtonAction:(UIButton *)sender {
    [self isGongge:AUXDeviceListTypeOfGrid];
}

- (void)isGongge:(AUXDeviceListType)type{
    if (type == AUXDeviceListTypeOfList) {
        [self.listButton setImage:[UIImage imageNamed:@"common_btn_selected_s"] forState:UIControlStateNormal];
        [self.gonggeButton setImage:[UIImage imageNamed:@"common_btn_unselected_round"] forState:UIControlStateNormal];
        
    }else{
        [self.listButton setImage:[UIImage imageNamed:@"common_btn_unselected_round"] forState:UIControlStateNormal];
        [self.gonggeButton setImage:[UIImage imageNamed:@"common_btn_selected_s"] forState:UIControlStateNormal];
    }
    
    [AUXArchiveTool saveDeviceListType:type];
}

@end
