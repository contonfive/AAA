//
//  AUXFeecBackRecordListViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/19.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXFeecBackRecordListViewController.h"
#import "AUXFeedBackRecordListTableViewCell.h"
#import "AUXFeedBackRecordDetailViewController.h"
#import "AUXNetworkManager.h"
#import "AUXFeedbackListModel.h"
#import "AUXCurrentNoDataView.h"
#import "UIColor+AUXCustom.h"

@interface AUXFeecBackRecordListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong)NSMutableArray*dataArray;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;

@end

@implementation AUXFeecBackRecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXFeedBackRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXFeedBackRecordListTableViewCell"];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (void)viewDidAppear:(BOOL)animated {
    [self getData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXFeedbackListModel *model = self.dataArray[indexPath.row];
    AUXFeedBackRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXFeedBackRecordListTableViewCell" forIndexPath:indexPath];
    cell.questionNameLabel.text = model.typeLabel;
    cell.questionDetailLabel.text = model.content;
    if (model.unreadNum !=0) {
        cell.numberLabel.hidden = NO;
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld",model.unreadNum];
    }else{
        cell.numberLabel.hidden = YES;
    }
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.dataArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark  cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AUXFeedbackListModel *model = self.dataArray[indexPath.row];

    AUXFeedBackRecordDetailViewController *feedBackRecordDetailViewController = [AUXFeedBackRecordDetailViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    feedBackRecordDetailViewController.feedbackListModel = model;
    [self.navigationController pushViewController:feedBackRecordDetailViewController animated:YES];
}

#pragma mark  获取列表
- (void)getData{
    [self.dataArray removeAllObjects];
    [self showLoadingHUD];
    [[AUXNetworkManager manager]getFeedbackcompltion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (error ==nil) {
            if ([dic[@"code"] integerValue]==200) {
                for (NSDictionary *dict in dic[@"data"]) {
                    AUXFeedbackListModel *feedbackListModel = [[AUXFeedbackListModel alloc]init];
                    [feedbackListModel yy_modelSetWithDictionary:dict];
                    [self.dataArray addObject:feedbackListModel];
                }
                [self.tableview reloadData];
                
                if (self.dataArray.count==0) {
                    self.noDataView.hidden = NO;
                    self.tableview.hidden = YES;
                }else{
                    self.noDataView.hidden = YES;
                    self.tableview.hidden = NO;
                }
            }else{
                [self showToastshortWithmessageinCenter:@"获取列表失败"];
            }
        }else{
            [self showToastshortWitherror:error];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
    tmpView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return tmpView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}


- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"mine_help_img_norecord"];
        _noDataView.titleLabel.text = @"暂无反馈记录";
        _noDataView.frame = CGRectMake(0, self.tableview.frame.origin.y, kAUXScreenWidth, self.tableview.frame.size.height);
        [self.view addSubview:_noDataView];
        
        _noDataView.topLayoutConstraint.constant = 0;
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

@end

