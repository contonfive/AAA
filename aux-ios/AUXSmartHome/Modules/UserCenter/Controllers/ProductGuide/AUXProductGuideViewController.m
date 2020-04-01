//
//  AUXProductGuideViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/7/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXProductGuideViewController.h"
#import "AUXProductGuideTableViewCell.h"
#import "AUXUserWebViewController.h"
#import "AUXElectronicSpecificationViewController.h"

@interface AUXProductGuideViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong)NSArray *dataArray;

@end

@implementation AUXProductGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXProductGuideTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXProductGuideTableViewCell"];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.dataArray = @[@{@"title":@"电子说明书",@"image":@"mine_icon_knowledge_directions"},
                       @{@"title":@"产品使用知识",@"image":@"mine_icon_knowledge_apply"}];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}


#pragma mark  UITableView的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXProductGuideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXProductGuideTableViewCell" forIndexPath:indexPath];
    cell.textTitleLabel.text = self.dataArray[indexPath.row][@"title"];
    cell.iconImage.image = [UIImage imageNamed:self.dataArray[indexPath.row][@"image"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark  分区头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        AUXElectronicSpecificationViewController *electronicSpecificationViewController = [AUXElectronicSpecificationViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        [self.navigationController pushViewController:electronicSpecificationViewController animated:YES];
    }else{
        AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        userWebViewController.loadUrl = kAUXKnowledgeBaseURL;
        userWebViewController.isformElectronicSpecification = YES;
        userWebViewController.title = @"知识库";
        [self.navigationController pushViewController:userWebViewController animated:YES];
    }
}
@end

