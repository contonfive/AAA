//
//  AUXSceneLogViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneLogViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXNetworkManager.h"
#import "AUXSceneLogModel.h"
#import "MJRefresh.h"
#import "AUXSceneLogTableViewCell.h"
#import "AUXCurrentNoDataView.h"

@interface AUXSceneLogViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *outSideTableview;
@property (nonatomic,strong)NSMutableArray*dataArray;
@property (nonatomic,strong)NSMutableArray*dataArray1;
@property (nonatomic,strong)NSMutableArray*sectionTitleArray;
@property (nonatomic,assign)CGFloat cellHeight;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;

@end

@implementation AUXSceneLogViewController
{
    NSInteger  _currentpage;
    NSInteger  _totalPages;
    NSInteger  _totalcount;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.outSideTableview registerNib:[UINib nibWithNibName:@"AUXSceneLogTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneLogTableViewCell"];
    self.outSideTableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.outSideTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.outSideTableview.backgroundColor = [UIColor whiteColor];
    self.outSideTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    self.outSideTableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    self.outSideTableview.estimatedRowHeight = 0;
    self.outSideTableview.estimatedSectionHeaderHeight = 0;
    self.outSideTableview.estimatedSectionFooterHeight = 0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self refreshData];
}

#pragma mark 下拉刷新
- (void)refreshData {
    _currentpage = 0;
    [self.dataArray removeAllObjects];
    [self getData];
}

#pragma mark 加载更多
- (void)loadMore {
    if (_currentpage==0) {
        [self.dataArray removeAllObjects];
    }
    _currentpage ++;
    if (_currentpage*20 > _totalcount) {
        [self showToastshortWithmessageinCenter:@"数据已经加载完啦"];
        [self.outSideTableview.mj_footer endRefreshing];
        return;
    }
    [self getData];
}



-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

-(NSMutableArray *)dataArray1{
    if (!_dataArray1) {
        self.dataArray1 = [[NSMutableArray alloc]init];
    }
    return _dataArray1;
}

-(NSMutableArray *)sectionTitleArray{
    if (!_sectionTitleArray) {
        self.sectionTitleArray = [[NSMutableArray alloc]init];
    }
    return _sectionTitleArray;
}


-(void)getData{
    [[AUXNetworkManager manager] getSceneHistroyWithpage:_currentpage Size:20 compltion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        if ([error.localizedDescription isEqualToString:@"OPERATE RETRIEVE SUCCESS"]) {
            NSArray *tmpArray = dic[@"content"];
            self->_totalPages = [dic[@"totalPages"] integerValue];
            self->_totalcount = [dic[@"totalElements"] integerValue];

            for (NSDictionary *dic  in tmpArray) {
                AUXSceneLogModel *scenelogModel = [[AUXSceneLogModel alloc]init];
                [scenelogModel yy_modelSetWithDictionary:dic];
                [self.dataArray addObject:scenelogModel];
            }
            [self reSetDate];
        }else{
            [self showToastshortWitherror:error];
        }
    }];
}


- (void)reSetDate {
    [self.sectionTitleArray removeAllObjects];
    [self.dataArray1 removeAllObjects];
    
    NSMutableArray *dateArray = [[NSMutableArray alloc]init];
    for (AUXSceneLogModel *model in self.dataArray) {
        [dateArray addObject:[model.createDay substringToIndex:10]];
    }
    for (NSString *item in dateArray) {
        if (![self.sectionTitleArray containsObject:item]) {
            [self.sectionTitleArray addObject:item];
        }
    }
    for (NSString *timeStr in self.sectionTitleArray) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
            NSPredicate *predicate = nil;
            predicate = [NSPredicate predicateWithFormat:@"createDay contains[c] %@", timeStr];
            tmpArray = [[self.dataArray filteredArrayUsingPredicate:predicate] mutableCopy];
        [self.dataArray1 addObject:tmpArray];
    }
    [self.outSideTableview reloadData];
    [self.outSideTableview.mj_header endRefreshing];
    [self.outSideTableview.mj_footer endRefreshing];
    
    if (self.dataArray.count==0) {
        self.noDataView.hidden = NO;
        self.outSideTableview.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.outSideTableview.hidden = NO;
    }
}


#pragma mark  tableview 每个cell显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    AUXSceneLogModel *model = self.dataArray1[indexPath.section][indexPath.row];
    AUXSceneLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneLogTableViewCell" forIndexPath:indexPath];
    NSMutableArray  *tmparray = [self.dataArray1[indexPath.section] mutableCopy];
    if (indexPath.row < tmparray.count && indexPath.row > 0) {
        AUXSceneLogModel *model1 = self.dataArray1[indexPath.section][indexPath.row-1];
        AUXSceneLogModel *model2 = self.dataArray1[indexPath.section][indexPath.row];
        if ([model2.createDay isEqualToString:model1.createDay]) {
            model.timeLabelHidden = YES;
        }else{
            model.timeLabelHidden = NO;
        }
    }else{
        model.timeLabelHidden = NO;
    }
    cell.model = model;
    self.cellHeight = cell.cellHeight;
    
//    cell.refreshBlock = ^(CGFloat cellHeight) {
//        self.cellHeight = cellHeight;
////       [self.outSideTableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
//    };
    return cell;
}

#pragma mark  tableview 每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *arr= self.dataArray1[indexPath.section];
    if (indexPath.section == self.sectionTitleArray.count-1 && indexPath.row == arr.count-1) {
         return self.cellHeight+10;
    }
    return self.cellHeight;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionTitleArray.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray1[section];
    return array.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    backView.backgroundColor = [UIColor whiteColor];
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 30)];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.font = [UIFont systemFontOfSize:16];
    tipLabel.textColor = [UIColor colorWithHexString:@"666666"];
    [backView addSubview:tipLabel];
    
    tipLabel.text = [[self.sectionTitleArray[section] substringFromIndex:5] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    return backView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"scene_img_noscenelog"];
        _noDataView.titleLabel.text = @"暂无场景日志";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, self.outSideTableview.frame.size.height-12);
        [self.view addSubview:_noDataView];
        _noDataView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
        _noDataView.topLayoutConstraint.constant = 12;
        _noDataView.hidden = YES;
        
    }
    return _noDataView;
}


//#pragma mark  cell的点击事件
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    AUXSceneLogModel *model = self.dataArray1[indexPath.section][indexPath.row];
//    model.isSelected = !model.isSelected;
//    [self.outSideTableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
//}


@end







