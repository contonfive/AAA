//
//  AUXChooseLocationView.m
//  ChooseLocation
//
//  Created by Sekorm on 16/8/22.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "AUXChooseLocationView.h"
#import "AUXAddressView.h"
#import "UIView+MIExtensions.h"
#import "AUXAddressTableViewCell.h"
#import "AUXSoapManager.h"
#import "AUXAddressModel.h"
#import "UIColor+AUXCustom.h"

#define HYScreenW [UIScreen mainScreen].bounds.size.width

static  CGFloat  const  kHYTopViewHeight = 40; //顶部视图的高度
static  CGFloat  const  kHYTopTabbarHeight = 30; //地址标签栏的高度

@interface AUXChooseLocationView ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic,weak) AUXAddressView * topTabbar;
@property (nonatomic,weak) UIScrollView * contentView;
@property (nonatomic,weak) UIView * underLine;
@property (nonatomic,strong) NSMutableArray * provincesArray;
@property (nonatomic,strong) NSMutableArray * citysArray;
@property (nonatomic,strong) NSMutableArray * countysArray;
@property (nonatomic,strong) NSMutableArray * townsArray;
@property (nonatomic,strong) NSMutableArray * tableViews;
@property (nonatomic,strong) NSMutableArray * topTabbarItems;
@property (nonatomic,weak) UIButton * selectedBtn;

@end

@implementation AUXChooseLocationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - setUp UI

- (void)setUp{
    
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHYTopViewHeight)];
    [self addSubview:topView];
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"所在地区";
    [titleLabel sizeToFit];
    [topView addSubview:titleLabel];
    titleLabel.centerY = topView.height * 0.5;
    titleLabel.centerX = topView.width * 0.5;
    UIView * separateLine = [self separateLine];
    [topView addSubview: separateLine];
    separateLine.top = topView.height - separateLine.height;
    topView.backgroundColor = [UIColor whiteColor];

    
    AUXAddressView * topTabbar = [[AUXAddressView alloc]initWithFrame:CGRectMake(0, topView.height, self.frame.size.width, kHYTopViewHeight)];
    [self addSubview:topTabbar];
     self.topTabbar = topTabbar;
    
    [self addTopBarItem];
    
    UIView * separateLine1 = [self separateLine];
    [topTabbar addSubview: separateLine1];
    separateLine1.top = topTabbar.height - separateLine.height;
    [self.topTabbar layoutIfNeeded];
    topTabbar.backgroundColor = [UIColor whiteColor];
    
    UIView * underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [topTabbar addSubview:underLine];
    _underLine = underLine;
    underLine.height = 2.0f;
    UIButton * btn = self.topTabbarItems.lastObject;
    [self changeUnderLineFrame:btn];
    underLine.top = separateLine1.top - underLine.height;
    
    _underLine.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
    UIScrollView * contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topTabbar.frame), self.frame.size.width, self.height - kHYTopViewHeight - kHYTopTabbarHeight)];
    contentView.contentSize = CGSizeMake(HYScreenW, 0);
    [self addSubview:contentView];
    _contentView = contentView;
    _contentView.pagingEnabled = YES;
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.delegate = self;
    
    [self addTableView];
}


- (void)addTableView{

    UITableView * tabbleView = [[UITableView alloc]initWithFrame:CGRectMake(self.tableViews.count * HYScreenW, 0, HYScreenW, _contentView.height)];
    [_contentView addSubview:tabbleView];
    [self.tableViews addObject:tabbleView];
    tabbleView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabbleView.delegate = self;
    tabbleView.dataSource = self;
    tabbleView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [tabbleView registerNib:[UINib nibWithNibName:@"AUXAddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXAddressTableViewCell"];
}

- (void)addTopBarItem{
    
    UIButton * topBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [topBarItem setTitle:@"请选择" forState:UIControlStateNormal];
    [topBarItem setTitleColor:[UIColor colorWithHexString:@"256BBD"] forState:UIControlStateNormal];
    [topBarItem setTitleColor:[UIColor colorWithHexString:@"256BBD"] forState:UIControlStateSelected];
    topBarItem.titleLabel.font = [UIFont systemFontOfSize:16];
    [topBarItem sizeToFit];
     topBarItem.centerY =  self.topTabbar.height * 0.5;
    [self.topTabbarItems addObject:topBarItem];
    [self.topTabbar addSubview:topBarItem];
//    [self.topTabbar setCotentOffSet:nil animated:YES];
    [topBarItem addTarget:self action:@selector(topBarItemClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - TableViewDatasouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if([self.tableViews indexOfObject:tableView] == 0){
        return self.provincesArray.count;
    }else if ([self.tableViews indexOfObject:tableView] == 1){
        return self.citysArray.count;
    }else if ([self.tableViews indexOfObject:tableView] == 2){
        return self.countysArray.count;
    }else if ([self.tableViews indexOfObject:tableView] == 3){
        return self.townsArray.count;
    }
    return self.provincesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    AUXAddressTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AUXAddressTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    AUXAddressModel * item;
    //省级别
    if([self.tableViews indexOfObject:tableView] == 0){
        item = self.provincesArray[indexPath.row];
    //市级别
    }else if ([self.tableViews indexOfObject:tableView] == 1){
        item = self.citysArray[indexPath.row];
    //县级别
    }else if ([self.tableViews indexOfObject:tableView] == 2){
        item = self.countysArray[indexPath.row];
    }else if ([self.tableViews indexOfObject:tableView] == 3){
        item = self.townsArray[indexPath.row];
    }
    
    cell.addressModel = item;
    return cell;
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableViews indexOfObject:tableView] == 0) {
        for (AUXAddressModel *model in self.provincesArray) {
            model.isSelected = NO;
        }
        
        AUXAddressModel *provinceModel = self.provincesArray[indexPath.row];
        provinceModel.isSelected = YES;
        
        for (int i = 1; i < self.tableViews.count; i++) {
            [self removeLastItem];
        }
        
        [self setSelectedProvience:provinceModel.text];
        [self requsetCityInfo:provinceModel];
    } else if ([self.tableViews indexOfObject:tableView] == 1) {
        for (AUXAddressModel *model in self.citysArray) {
            model.isSelected = NO;
        }
        
        AUXAddressModel *cityModel = self.citysArray[indexPath.row];
        cityModel.isSelected = YES;
        
        for (int i = 2; i < self.tableViews.count; i++) {
            [self removeLastItem];
        }
        
        [self setSelectedCity:cityModel.text];
        [self requesCountysInfo:cityModel];
    } else if ([self.tableViews indexOfObject:tableView] == 2) {
        for (AUXAddressModel *model in self.countysArray) {
            model.isSelected = NO;
        }
        
        AUXAddressModel *countyModel = self.countysArray[indexPath.row];
        countyModel.isSelected = YES;
        
        for (int i = 3; i < self.tableViews.count; i++) {
            [self removeLastItem];
        }
        
        [self setSelectedCounty:countyModel.text];
        [self requestTownsInfo:countyModel];
    } else if ([self.tableViews indexOfObject:tableView] == 3) {
        for (AUXAddressModel *model in self.townsArray) {
            model.isSelected = NO;
        }
        
        AUXAddressModel *townModel = self.townsArray[indexPath.row];
        townModel.isSelected = YES;
        
        UIButton *button = self.topTabbarItems.lastObject;
        [self changeUnderLineFrame:button];
        [self setSelectedTown:townModel.text];
        [self reloadTableView];
        
        [self setUpAddress];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AUXAddressModel * item;
    if([self.tableViews indexOfObject:tableView] == 0){
        item = self.provincesArray[indexPath.row];
    }else if ([self.tableViews indexOfObject:tableView] == 1){
        item = self.citysArray[indexPath.row];
    }else if ([self.tableViews indexOfObject:tableView] == 2){
        item = self.countysArray[indexPath.row];
    }
    item.isSelected = NO;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

}

#pragma mark - private 

//点击按钮,滚动到对应位置
- (void)topBarItemClick:(UIButton *)btn{
    
    NSInteger index = [self.topTabbarItems indexOfObject:btn];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.contentOffset = CGPointMake(index * HYScreenW, 0);
        [self changeUnderLineFrame:btn];
    }];
}

//调整指示条位置
- (void)changeUnderLineFrame:(UIButton  *)btn{
    
    _selectedBtn.selected = NO;
    btn.selected = YES;
    _selectedBtn = btn;
    _underLine.left = btn.left;
    _underLine.width = btn.width;
}

//完成地址选择,执行chooseFinish代码块
- (void)setUpAddress{

    NSString *localString = [NSString string];
    NSMutableDictionary *localDict = [NSMutableDictionary dictionary];
    for (AUXAddressModel *model in self.provincesArray) {
        if (model.isSelected) {
            localString = [NSString stringWithFormat:@"%@%@" , localString , model.text];
            [localDict setObject:model.text forKey:@"Province"];
            [localDict setObject:model.value forKey:@"ProvinceId"];
        }
    }
    
    for (AUXAddressModel *model in self.citysArray) {
        if (model.isSelected) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , model.text];
            [localDict setObject:model.text forKey:@"City"];
            [localDict setObject:model.value forKey:@"CityId"];
        }
    }
    
    for (AUXAddressModel *model in self.countysArray) {
        if (model.isSelected) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , model.text];
            [localDict setObject:model.text forKey:@"County"];
            [localDict setObject:model.value forKey:@"CountyId"];
        }
    }
    
    for (AUXAddressModel *model in self.townsArray) {
        if (model.isSelected) {
            localString = [NSString stringWithFormat:@"%@ %@" , localString , model.text];
            [localDict setObject:model.text forKey:@"Town"];
            [localDict setObject:model.value forKey:@"TownId"];
        }
    }
    [localDict setObject:localString forKey:@"local"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
        if (self.chooseFinish) {
            self.chooseFinish(localDict);
        }
    });
}

//当重新选择省或者市的时候，需要将下级视图移除。
- (void)removeLastItem{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViews.lastObject performSelector:@selector(removeFromSuperview) withObject:nil withObject:nil];
        [self.tableViews removeLastObject];
        
        [self.topTabbarItems.lastObject performSelector:@selector(removeFromSuperview) withObject:nil withObject:nil];
        [self.topTabbarItems removeLastObject];
    });
}

//滚动到下级界面,并重新设置顶部按钮条上对应按钮的title
- (void)scrollToNextItem:(NSString *)preTitle{
    
    NSInteger index = self.contentView.contentOffset.x / HYScreenW;
    UIButton * btn = self.topTabbarItems[index];
    [btn setTitle:preTitle forState:UIControlStateNormal];
    [btn sizeToFit];
    [self.topTabbar layoutIfNeeded];
    
    UIButton *lastButon = self.topTabbarItems.lastObject;
    CGFloat offSetX = CGRectGetMaxX(lastButon.frame) - kAUXScreenWidth;
    if (offSetX > 0) {
        [self.topTabbar setContentOffset:CGPointMake(CGRectGetMaxX(lastButon.frame) - kAUXScreenWidth, 0) animated:YES];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.contentSize = (CGSize){self.tableViews.count * HYScreenW,0};
        CGPoint offset = self.contentView.contentOffset;
        self.contentView.contentOffset = CGPointMake(offset.x + HYScreenW, offset.y);
        [self changeUnderLineFrame: lastButon];
    }];
}


#pragma mark - <UIScrollView>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView != self.contentView) return;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        NSInteger index = scrollView.contentOffset.x / HYScreenW;
        UIButton * btn = weakSelf.topTabbarItems[index];
        [weakSelf changeUnderLineFrame:btn];
    }];
}

#pragma mark - 开始就有地址时.

- (void)setModel:(AUXTopContactModel *)model {
    _model = model;
    
    [self.topTabbarItems makeObjectsPerformSelector:@selector(sizeToFit)];
    [self.topTabbar layoutIfNeeded];
    [self changeUnderLineFrame:[self.topTabbarItems lastObject]];
    
    //2.4 设置偏移量
    self.contentView.contentSize = (CGSize){self.tableViews.count * HYScreenW,0};
    CGPoint offset = self.contentView.contentOffset;
    self.contentView.contentOffset = CGPointMake((self.tableViews.count - 1) * HYScreenW, offset.y);
}

- (void)setSelectedProvience:(NSString *)provinceName {
    
    UIButton * firstBtn = self.topTabbarItems.firstObject;
    [firstBtn setTitle:provinceName forState:UIControlStateNormal];
    
    for (AUXAddressModel * item in self.provincesArray) {
        if ([item.text isEqualToString:provinceName]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.provincesArray indexOfObject:item] inSection:0];
            UITableView * tableView  = self.tableViews.firstObject;
    
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            break;
        }
    }
}

- (void)setSelectedCity:(NSString *)cityName {
    
    UIButton * firstBtn = self.topTabbarItems[1];
    [firstBtn setTitle:cityName forState:UIControlStateNormal];
    
    for (AUXAddressModel * item in self.citysArray) {
        if ([item.text isEqualToString:cityName]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.citysArray indexOfObject:item] inSection:0];
            UITableView * tableView  = self.tableViews[1];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            break;
        }
    }
}

- (void)setSelectedCounty:(NSString *)countyName {
    
    UIButton * firstBtn = self.topTabbarItems[2];
    [firstBtn setTitle:countyName forState:UIControlStateNormal];
    
    for (AUXAddressModel * item in self.countysArray) {
        if ([item.text isEqualToString:countyName]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.countysArray indexOfObject:item] inSection:0];
            UITableView * tableView  = self.tableViews[2];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            break;
        }
    }
}

- (void)setSelectedTown:(NSString *)townName {
    
    UIButton * firstBtn = self.topTabbarItems[3];
    [firstBtn setTitle:townName forState:UIControlStateNormal];
    
    for (AUXAddressModel * item in self.townsArray) {
        if ([item.text isEqualToString:townName]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.townsArray indexOfObject:item] inSection:0];
            UITableView * tableView  = self.tableViews[3];
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            break;
        }
    }
}

#pragma mark - getter 方法

//分割线
- (UIView *)separateLine{
    
    UIView * separateLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1 / [UIScreen mainScreen].scale)];
    separateLine.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    return separateLine;
}

- (NSMutableArray *)tableViews{
    
    if (_tableViews == nil) {
        _tableViews = [NSMutableArray array];
    }
    return _tableViews;
}

- (NSMutableArray *)topTabbarItems{
    if ( _topTabbarItems == nil) {
         _topTabbarItems = [NSMutableArray array];
    }
    return  _topTabbarItems;
}

//省级别数据源
- (NSArray *)provincesArray{
    
    if (!_provincesArray) {
        _provincesArray = [NSMutableArray array];
        [self requestProvienceInfo];
    }
    return _provincesArray;
}

- (NSArray *)citysArray{
    
    if (!_citysArray) {
        _citysArray = [NSMutableArray array];
    }
    return _citysArray;
}

- (NSArray *)countysArray{
    
    if (!_countysArray) {
        _countysArray = [NSMutableArray array];
    }
    return _countysArray;
}

- (NSArray *)townsArray{
    
    if (!_townsArray) {
        _townsArray = [NSMutableArray array];
    }
    return _townsArray;
}

- (void)enableTableViews:(BOOL)enable {
    for (UITableView *tableView in self.tableViews) {
        tableView.userInteractionEnabled = enable;
    }
}

#pragma mark 网络请求
- (void)requestProvienceInfo {
    
    [self enableTableViews:false];
    
    [[AUXSoapManager sharedInstance] getProvinceListCompletion:^(NSArray<AUXAddressModel *> *provienceArray, NSError * _Nonnull error) {
        
        self.provincesArray = [NSMutableArray arrayWithArray:provienceArray];
        
        NSMutableArray *removeArray = [NSMutableArray array];
        for (AUXAddressModel *model in self.provincesArray) {
            if ([model.text containsString:@"香港"]) {
                [removeArray addObject:model];
            }
            if ([model.text containsString:@"澳门"]) {
                [removeArray addObject:model];
            }
        }
        [self.provincesArray removeObjectsInArray:removeArray];
        
        [self reloadTableView];
    }];
}

- (void)requsetCityInfo:(AUXAddressModel *)addressModel {
    [self enableTableViews:false];
    [[AUXSoapManager sharedInstance] getCityList:addressModel.value completion:^(NSArray<AUXAddressModel *> *cityListArray, NSError * _Nonnull error) {
        self.citysArray = [cityListArray mutableCopy];
        
        if (self.citysArray.count != 0) {
            [self addTableView];
            [self addTopBarItem];
            [self scrollToNextItem:addressModel.text];
        } else {
            [self setUpAddress];
        }
        [self reloadTableView];
    }];
}

- (void)requesCountysInfo:(AUXAddressModel *)addressModel {
    [self enableTableViews:false];
    [[AUXSoapManager sharedInstance] getCountyList:addressModel.value completion:^(NSArray<AUXAddressModel *> *countyListArray, NSError * _Nonnull error) {
        self.countysArray = [countyListArray mutableCopy];
        if (self.countysArray.count != 0) {
            [self addTableView];
            [self addTopBarItem];
            [self scrollToNextItem:addressModel.text];
        } else {
            [self setUpAddress];
        }
        [self reloadTableView];
    }];
}

- (void)requestTownsInfo:(AUXAddressModel *)addressModel {
    [self enableTableViews:false];
    [[AUXSoapManager sharedInstance] getTownList:addressModel.value completion:^(NSArray<AUXAddressModel *> *townListArray, NSError * _Nonnull error) {
        self.townsArray = [townListArray mutableCopy];
        if (self.townsArray.count != 0) {
            [self addTableView];
            [self addTopBarItem];
            [self scrollToNextItem:addressModel.text];
        } else {
            [self setUpAddress];
        }
        [self reloadTableView];
    }];
}

- (void)reloadTableView {
    
    self.contentView.contentSize = (CGSize){self.tableViews.count * HYScreenW,0};
    CGPoint offset = self.contentView.contentOffset;
    self.contentView.contentOffset = CGPointMake((self.tableViews.count - 1) * HYScreenW, offset.y);
    
    for (UITableView *tableView in self.tableViews) {
        [tableView reloadData];
    }
    
    [self enableTableViews:true];
}

@end
