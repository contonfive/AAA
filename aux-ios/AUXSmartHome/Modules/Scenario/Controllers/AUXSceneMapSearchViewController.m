//
//  AUXSceneMapSearchViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/8/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneMapSearchViewController.h"
#import "AUXArchiveTool.h"
#import "AUXSceneMapSearchHistory.h"
#import "UIColor+AUXCustom.h"

@interface AUXSceneMapSearchViewController ()<MAMapViewDelegate, AMapSearchDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate , UITableViewDataSource , UITableViewDelegate>
@property (nonatomic,assign) BOOL selectedHistoryItem;
@property (nonatomic,strong) NSDictionary *selectedHistoryDict;
@property (nonatomic, strong) NSMutableArray *historyData;
@property (nonatomic, strong) NSMutableArray *tips;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic ,strong) AMapPOIAroundSearchRequest *request;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;

@end

@implementation AUXSceneMapSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedHistoryItem = NO;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    self.request = [[AMapPOIAroundSearchRequest alloc] init];
//    self.request.keywords  = @"商务住宅|餐饮服务|生活服务";
    self.request.keywords = @"道路附属设施|地名地址信息|餐饮服务|商务住宅|医疗保健服务";


    /* 按照距离排序. */
    self.request.sortrule = 0;
    self.request.offset = 50;
    self.request.requireExtension = YES;
    
    self.tips = [NSMutableArray array];
    self.historyData = [AUXArchiveTool readDataSceneMapSearchHistory];
    
    if (self.historyData.count != 0) {
        [self.tableView reloadData];
    }
    [self searchController];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchController.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.searchController.active = NO;
}

#pragma mark getters

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchBar.delegate = self;
        _searchController.searchBar.placeholder = @"手动输入地址";
        [self searchBarShouldBeginEditing:_searchController.searchBar];
        [_searchController.searchBar sizeToFit];
        self.navigationItem.titleView = _searchController.searchBar;
        UITextField *tt = [_searchController.searchBar valueForKey:@"searchField"];
        tt.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
        tt.layer.masksToBounds = YES;
        tt.layer.cornerRadius = tt.bounds.size.height/2;
    }
    return _searchController;
}


#pragma mark - Utility

/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    
    [self.search AMapInputTipsSearch:tips];
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {
    if (response.count == 0)
    {
        self.tableView.hidden = YES;
        self.noResultLabel.hidden = NO;
        return;
    }
    self.tableView.hidden = NO;
    self.noResultLabel.hidden = YES;
    
    if (self.selectedHistoryItem) {
        for (AMapTip *tip in response.tips) {
            if ([tip.uid isEqualToString:self.selectedHistoryDict[@"uid"]] && [tip.adcode isEqualToString:self.selectedHistoryDict[@"adcode"]]) {
                [self transfitMapTipToParent:tip];
            }
        }
    } else {
        [self.tips setArray:response.tips];
        [self.tableView reloadData];
    }
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    AUXSceneMapSearchViewController *mapSearchViewController = [[AUXSceneMapSearchViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mapSearchViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark UISearchBarDelete

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar; {
    searchBar.placeholder = @"手动输入方位";
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UISearchControllerDelegate
- (void)didPresentSearchController:(UISearchController *)searchController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchController.searchBar becomeFirstResponder]; //放主线程执行这个
    });
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self searchTipsWithKey:searchController.searchBar.text];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tips.count == 0) {
        return self.historyData.count;
    } else {
        return self.tips.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.tips.count == 0 && self.historyData.count != 0) {
        AUXSceneMapSearchHistory *headerView = [[NSBundle mainBundle] loadNibNamed:@"AUXSceneMapSearchHistory" owner:nil options:nil].firstObject;
        headerView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
        headerView.clearBlock = ^{
            [AUXArchiveTool clearSceneMapSearchHistory];
            [self.historyData removeAllObjects];
            [tableView reloadData];
        };
        return headerView;
    } else  {
        return [UIView new];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:tipCellIdentifier];
    }
    
    
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 79, kScreenWidth-10, 1)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
    [cell addSubview:lineLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.tips.count == 0) {
        NSDictionary *dict = self.historyData[indexPath.row];
        cell.textLabel.text = dict[@"name"];
        cell.detailTextLabel.text = dict[@"address"];
    } else {
        AMapTip *tip = self.tips[indexPath.row];
        cell.textLabel.text = tip.name;
        cell.detailTextLabel.text = tip.address;
    }
    cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"8E959D"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.tips.count == 0) {
        if (self.historyData.count == 0) {
            return 1;
        }
        return 40;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapTip *tip;
    if (self.tips.count != 0) {
        tip = self.tips[indexPath.row];
        
        if (self.historyData.count != 0) {
            
            BOOL whtherEqual = NO;
            for (NSDictionary *dict in self.historyData) {
                if (![dict[@"uid"] isEqualToString:tip.uid] && ![dict[@"adcode"] isEqualToString:tip.adcode]) {
                    whtherEqual = YES;
                }
            }
            
            if (whtherEqual) {
                NSDictionary *secondDict = @{@"name" : tip.name , @"address" : tip.address , @"adcode" : tip.adcode , @"uid" : tip.uid};
                [self.historyData addObject:secondDict];
            }
        } else {
            self.selectedHistoryItem = YES;
            
            NSDictionary *secondDict = @{@"name" : tip.name , @"address" : tip.address , @"adcode" : tip.adcode , @"uid" : tip.uid};
            [self.historyData addObject:secondDict];
        }
        [AUXArchiveTool saveSceneMapSearchData:self.historyData];
    } else {
        
        self.selectedHistoryItem = YES;
        NSDictionary *dict = self.historyData[indexPath.row];
        self.selectedHistoryDict = dict;
        [self searchTipsWithKey:dict[@"name"]];
    }
    
    [self transfitMapTipToParent:tip];
}

- (void)transfitMapTipToParent:(AMapTip *)tip {
    
    if (tip) {
        self.searchController.active = NO;
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.cellSelcetedBlock) {
                self.cellSelcetedBlock(tip);
            }
        }];
    }
}


#pragma mark - tableview滑动的时候收回键盘
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end

