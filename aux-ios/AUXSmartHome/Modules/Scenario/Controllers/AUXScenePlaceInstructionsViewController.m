//
//  AUXScenePlaceInstructionsViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/24.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXScenePlaceInstructionsViewController.h"

@interface AUXScenePlaceInstructionsViewController ()

@end

@implementation AUXScenePlaceInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self loadHTML:kAUXScenePlaceStatement];
}

@end
