//
//  AUXSelectWallpaperViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/5/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSelectWallpaperViewController.h"
#import "UIColor+AUXCustom.h"

@interface AUXSelectWallpaperViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *buttonBackView;
@property (weak, nonatomic) IBOutlet UIButton *userButton;

@end

@implementation AUXSelectWallpaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backImageView.image = [[UIImage imageNamed:self.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.userButton.layer.masksToBounds = YES;
    self.userButton.layer.cornerRadius = 15;
    self.userButton.layer.borderWidth=1;
    self.userButton.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
}


- (IBAction)userBHuttonAction:(UIButton *)sender {
    NSLog(@"%@",self.imageName);
    [MyDefaults setObject:self.imageName forKey:kSelectHomepageBackImageName];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear: YES];
    //设置导航栏背景图片为一个空的image，这样就透明了
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}
- (void)viewWillDisappear:(BOOL)animated{
    //    如果不想让其他页面的导航栏变为透明 需要重置
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

@end
