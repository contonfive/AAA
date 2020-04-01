//
//  AUXWorkOrderViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/27.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXWorkOrderViewController.h"
#import "AUXWorkOrderDetailViewController.h"
#import "AUXAfterSaleEvaluateViewController.h"
#import "AUXWorkOrderTableViewCell.h"

#import "AUXCurrentNoDataView.h"
#import "AUXWorkOrderModel.h"
#import "UITableView+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXSoapManager.h"
#import "AUXUser.h"

@interface AUXWorkOrderViewController ()<UITableViewDataSource , UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) AUXUser *user;

@property (nonatomic,strong) NSMutableArray<AUXWorkOrderModel *> *workOrderListArray;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@end

@implementation AUXWorkOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self requestWorkOrdersList];
}

- (void)initSubviews {
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    [self.tableView registerCellWithNibName:@"AUXWorkOrderTableViewCell"];
}

#pragma mark getters
- (NSMutableArray<AUXWorkOrderModel *> *)workOrderListArray {
    if (!_workOrderListArray) {
        _workOrderListArray = [NSMutableArray array];
    }
    return _workOrderListArray;
}

- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"mine_service_img_nolist"];
        _noDataView.titleLabel.text = @"暂无可查工单";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight);
        [self.view addSubview:_noDataView];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

#pragma mark 网络请求
- (void)requestWorkOrdersList {
    
    [self showLoadingHUD];
    NSMutableArray *dataArray = [NSMutableArray array];
    [[AUXSoapManager sharedInstance] getWorkOrderListWithQueryValue:nil pageIndex:1 pageSize:100 type:1 Userphone:[AUXUser defaultUser].phone completion:^(NSArray<AUXWorkOrderModel *> *workOrderListArray, NSError * _Nonnull error) {
        
        
        [self hideLoadingHUD];
        for (AUXWorkOrderModel *model in workOrderListArray) {
            model.workOrderType = AUXAfterSaleTypeOfInstallation;
        }
        [dataArray addObjectsFromArray:workOrderListArray];
        
        [[AUXSoapManager sharedInstance] getWorkOrderListWithQueryValue:nil pageIndex:1 pageSize:100 type:2 Userphone:[AUXUser defaultUser].phone completion:^(NSArray<AUXWorkOrderModel *> *workOrderListArray, NSError * _Nonnull error) {
            
            for (AUXWorkOrderModel *model in workOrderListArray) {
                model.workOrderType = AUXAfterSaleTypeOfMaintenance;
            }
            [dataArray addObjectsFromArray:workOrderListArray];
            
            NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"Createdon" ascending:NO];
            NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:&sorter count:1];
            self.workOrderListArray = [[dataArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }];
}

#pragma mark atcions
- (void)evaluatAtcion:(AUXWorkOrderTableViewCell *)cell {
    AUXAfterSaleEvaluateViewController *evaluateViewController = [AUXAfterSaleEvaluateViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    evaluateViewController.workOrderModel = cell.workOrderModel;
    [self.navigationController pushViewController:evaluateViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.workOrderListArray.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    return self.workOrderListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXWorkOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWorkOrderTableViewCell" forIndexPath:indexPath];
    
    AUXWorkOrderModel *workOrderModel = self.workOrderListArray[indexPath.section];
    
    cell.workOrderModel = workOrderModel;

    @weakify(cell);
    cell.evaluationBlock = ^{
        @strongify(cell);
        [self evaluatAtcion:cell];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    AUXWorkOrderModel *workOrderModel = self.workOrderListArray[indexPath.section];
    
    AUXWorkOrderDetailViewController *workOrderDetailViewController = [AUXWorkOrderDetailViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    
    workOrderDetailViewController.workOrderModel = workOrderModel;
    [self.navigationController pushViewController:workOrderDetailViewController animated:YES];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 162;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

@end
