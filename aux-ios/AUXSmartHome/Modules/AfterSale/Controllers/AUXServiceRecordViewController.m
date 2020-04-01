//
//  AUXServiceRecordViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/11.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXServiceRecordViewController.h"
#import "AUXWorkOrderServiceDetailTableViewCell.h"
#import "AUXSoapManager.h"
#import "AUXUser.h"

#import "UITableView+AUXCustom.h"
@interface AUXServiceRecordViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AUXServiceRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)initSubviews {
//    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    
    [self.tableView registerCellWithNibName:@"AUXWorkOrderServiceDetailTableViewCell"];
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark setter
- (void)setProgressList:(NSArray<AUXProgressListModel *> *)ProgressList {
    _ProgressList = ProgressList;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ProgressList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXWorkOrderServiceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderServiceDetailTableViewCell" forIndexPath:indexPath];
    
    AUXProgressListModel *progressListModel = self.ProgressList[indexPath.row];
    cell.ProgressList = self.ProgressList;
    cell.ProgressListModel = progressListModel;
    cell.indexPath = indexPath;
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
