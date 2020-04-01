//
//  AUXNotificationComponentPromptViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/5/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXNotificationComponentPromptViewController.h"
#import "AUXNotificationComponentPromptTableViewCell.h"
#import "AUXNotificationComponentPromptFooterView.h"
#import "AUXComponentsViewController.h"
#import "UITableView+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXArchiveTool.h"
#import "UIColor+AUXCustom.h"


@interface AUXNotificationComponentPromptViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *cellArray;

@end

@implementation AUXNotificationComponentPromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.tableView registerCellWithNibName:@"AUXNotificationComponentPromptTableViewCell"];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.cellArray = @[
                       @{@"title":@"1、从屏幕顶部下拉打开通知中心-右滑，找到底部的“编辑”按钮。",@"image":@"mine_widget_ios_img_instrution1",@"height":@"160"},
                       @{@"title":@"2、在小组件中找到“奥克斯A+”添加，然后点右上角“完成”。", @"image":@"mine_widget_ios_img_instrution2",@"height":@"125"},
                       @{@"title":@"3、返回“奥克斯A+”APP，在“我的”-“小组件”添加设备即可实现设备快捷控制。" , @"image":@"mine_widget_ios_img_instrution3",@"height":@"212"},
  ];
}

#pragma mark atcion
- (void)atcionIKnow:(UIButton *)sender {
    if (![AUXArchiveTool shouldShowNotificationControlGuidePage]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        AUXComponentsViewController *componentViewController = [AUXComponentsViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        componentViewController.hidesBottomBarWhenPushed = YES;
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        [viewControllers removeLastObject];
        [viewControllers addObject:componentViewController];
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
    
    [AUXArchiveTool setShouldShowNotificationControlGuidePage:NO];
}


#pragma mark UITableViewDelegate , UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXNotificationComponentPromptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PromptTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    NSDictionary *cellDict = self.cellArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.dataDict = cellDict;
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    AUXNotificationComponentPromptFooterView *footerView = [[NSBundle mainBundle] loadNibNamed:@"AUXNotificationComponentPromptFooterView" owner:nil options:nil].firstObject;
    
    footerView.iKnowButton.layer.borderColor = [[UIColor colorWithHexString:@"256BBD"] CGColor];
    footerView.iKnowButton.layer.borderWidth = 2;
    
    [footerView.iKnowButton addTarget:self action:@selector(atcionIKnow:) forControlEvents:UIControlEventTouchUpInside];
    footerView.backgroundColor = [UIColor whiteColor];

    
    return footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 46;
    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 220;
    } else if (indexPath.row == 1) {
        return 185;
    } else {
        return 272;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}
@end
