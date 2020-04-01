//
//  AUXAfterSaleViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/18.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAfterSaleViewController.h"
#import "AUXSNCodeSearchViewController.h"
#import "AUXAddNewContactViewController.h"
#import "AUXDetailContactViewController.h"

#import "AUXAfterSaleHeaderView.h"
#import "AUXAfterSaleFooterView.h"
#import "AUXAUXAfterSaleConmuteTableViewCell.h"
#import "AUXAfterSaleAddContactTableViewCell.h"
#import "AUXAfterSaleEditTableViewCell.h"
#import "AUXAfterSaleLeaveMessageCell.h"

#import "AUXDatePicker.h"
#import "UITableView+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXSoapManager.h"
#import "AUXNetworkManager.h"
#import "AUXUser.h"
#import "AUXPickerPopupViewController.h"
#import "AUXModeAndSpeedView.h"

#import "AUXTopContactModel.h"
#import "AUXSubmitWorkOrderModel.h"
#import "AUXPickListModel.h"
#import "AUXDeviceModel.h"
#import "AUXChannelTypeModel.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UMAnalytics/MobClick.h>

@interface AUXAfterSaleViewController ()<UITableViewDelegate , UITableViewDataSource , AUXDatePickerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *logisticsArray;

@property (nonatomic,strong) NSMutableArray *unitNumberArray;
@property (nonatomic,strong) NSMutableArray *unitDescribeArray;

@property (nonatomic,strong) NSMutableArray <AUXPickListModel *> *productListArray;
@property (nonatomic,strong) NSArray<AUXChannelTypeModel *> *channelTypeList;
@property (nonatomic,strong) AUXTopContactModel *defaultContact;
@property (nonatomic,strong) AUXTopContactModel *chooseContact;

@property (nonatomic,assign) CGFloat contactCellHeight;

@property (nonatomic,strong) NSMutableArray * contactsListArray;

@property (nonatomic,strong) AUXDeviceModel *deviceModel;
@property (nonatomic,strong) AUXSubmitWorkOrderModel *submitWorkOrdermodel;

@property (nonatomic,copy) NSString *Name;
@property (nonatomic,copy) NSString *Value;
@property (nonatomic,copy) NSString *BuyDate;
@property (nonatomic,assign) NSInteger ActualChannelType;
@property (nonatomic,assign) NSInteger logisticsSelect;

@property(nonatomic,strong)AUXDatePicker *buyDatePicker;
@property(nonatomic,strong)AUXDatePicker *subscribeDatePicker;
@property (nonatomic,strong) UIView *datePickerBackView;
@end

//弹框的高度
static CGFloat datePickerH = 258;//大致是键盘的高度

@implementation AUXAfterSaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideLoadingHUD];
    
    if (self.afterSaleType == AUXAfterSaleTypeOfMaintenance) {
        self.navigationItem.title = @"预约维修";
    } else {
        self.navigationItem.title = @"预约安装";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addContactNotifiAtcion:) name:AUXAfterSaleAddNewContact object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self requestProductGroup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showLoadingHUD];
    [self requestGetDefaultContact];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self buyDatePicker];
    [self.tableView registerCellWithNibName:@"AUXAUXAfterSaleConmuteTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXAfterSaleAddContactTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXAfterSaleEditTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXAfterSaleLeaveMessageCell"];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    [self requestChannelType];
}

- (void)tableViewReload {
    if (!AUXWhtherNullString(self.chooseContact.guid)) {
        self.defaultContact = self.chooseContact;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark getters
- (NSArray *)sectionArray {
    if (!_sectionArray) {
        if (self.afterSaleType == AUXAfterSaleTypeOfInstallation) {
            _sectionArray = [NSArray arrayWithObject:@5];
        } else {
            _sectionArray = [NSArray arrayWithObject:@4];
        }
    }
    return _sectionArray;
}

- (NSMutableArray *)logisticsArray {
    if (!_logisticsArray) {
        _logisticsArray = [NSMutableArray arrayWithObjects:@{@"title" : @"货已到需要安装"} , @{@"title" : @"货未到预约安装"}, nil];
    }
    return _logisticsArray;
}

- (NSMutableArray *)unitNumberArray {
    if (!_unitNumberArray) {
        _unitNumberArray = [NSMutableArray array];
    }
    return _unitNumberArray;
}

- (NSMutableArray *)unitDescribeArray {
    if (!_unitDescribeArray) {
        _unitDescribeArray = [NSMutableArray array];
    }
    return _unitDescribeArray;
}

- (AUXSubmitWorkOrderModel *)submitWorkOrdermodel {
    if (!_submitWorkOrdermodel) {
        _submitWorkOrdermodel = [[AUXSubmitWorkOrderModel alloc]init];

        _submitWorkOrdermodel.LogisticsType = 1;

        NSString *nowTime = [NSDate cNowTimestamp];
        NSString *nextTimeStamp = [NSString stringWithFormat:@"%ld" , nowTime.integerValue + 3600 * 24];
        NSString *requireinstalTime = [NSDate cStringFromTimestamp:nextTimeStamp];
        _submitWorkOrdermodel.RequireinstalTime = [requireinstalTime substringWithRange:NSMakeRange(0, 10)];
    }
    return _submitWorkOrdermodel;
}

- (NSMutableArray *)contactsListArray {
    if (!_contactsListArray) {
        _contactsListArray = [NSMutableArray array];
    }
    return _contactsListArray;
}

- (UIView *)datePickerBackView {
    if (!_datePickerBackView) {
        _datePickerBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, kAUXScreenHeight)];
        _datePickerBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:_datePickerBackView];
        _datePickerBackView.alpha = 0;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAtcion:)];
        [_datePickerBackView addGestureRecognizer:tapGesture];
    }
    return _datePickerBackView;
}

- (AUXDatePicker *)buyDatePicker {
    if (!_buyDatePicker) {
        
        NSString *dateStr=@"2010-01-01 00:00:00";
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat=@"yyyy-MM-dd hh:mm:ss";
        
        NSDate *minimumDate = [dateFormatter dateFromString:dateStr];
        NSDate *maximumDate = [NSDate dateWithTimeIntervalSinceNow:- 3600 * 24];
        
        _buyDatePicker = [[NSBundle mainBundle]loadNibNamed:@"AUXDatePicker" owner:self options:nil].firstObject;
        _buyDatePicker.frame = CGRectMake(0, kAUXScreenHeight, SCREEN_WIDTH, datePickerH);
        _buyDatePicker.minimumDate = minimumDate;
        _buyDatePicker.maximumDate = maximumDate;
        
        _buyDatePicker.title = @"购买日期";
        [_buyDatePicker initData];
        _buyDatePicker.delegate = self;
        [self.datePickerBackView addSubview:_buyDatePicker];
        [_buyDatePicker pickerSelect];
    }
    return _buyDatePicker;
}

- (AUXDatePicker *)subscribeDatePicker {
    if (!_subscribeDatePicker) {
        _subscribeDatePicker = [[NSBundle mainBundle]loadNibNamed:@"AUXDatePicker" owner:self options:nil].firstObject;
        _subscribeDatePicker.frame = CGRectMake(0, kAUXScreenHeight, SCREEN_WIDTH, datePickerH);
        _subscribeDatePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24];
        _subscribeDatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 31];
        _subscribeDatePicker.title = @"预约日期";
        [_subscribeDatePicker initData];
        _subscribeDatePicker.delegate = self;
        [self.datePickerBackView addSubview:_subscribeDatePicker];
    }
    return _subscribeDatePicker;
}

#pragma mark setters
- (void)setAfterSaleType:(AUXAfterSaleType)afterSaleType {
    _afterSaleType = afterSaleType;
}

#pragma mark atcions

- (IBAction)submitAtcion:(id)sender {
    
    AUXUser *user = [AUXUser defaultUser];
    
    if (!self.defaultContact) {
        [self showErrorViewWithMessage:@"请添加联系人"];
        return ;
    }
    if (AUXWhtherNullString(self.Name)) {
        [self showErrorViewWithMessage:@"请选择产品线"];
        return ;
    }
    if (AUXWhtherNullString(self.submitWorkOrdermodel.RequireinstalTime)) {
        [self showErrorViewWithMessage:@"请选择预约时间"];
        return ;
    }
    if (self.ActualChannelType == 0) {
        [self showErrorViewWithMessage:@"请选择购买单位类型"];
        return ;
    }
    if (AUXWhtherNullString(self.BuyDate)) {
        [self showErrorViewWithMessage:@"请选择购买日期"];
        return ;
    }
    if (self.afterSaleType == AUXAfterSaleTypeOfInstallation) {
        if (self.submitWorkOrdermodel.LogisticsType == 0) {
            [self showErrorViewWithMessage:@"请选择物流状态"];
            return ;
        }
    }
    if (AUXWhtherNullString(self.submitWorkOrdermodel.Memo) && self.afterSaleType == AUXAfterSaleTypeOfMaintenance) {
        [self showErrorViewWithMessage:@"请填写备注信息"];
        return ;
    }
    
    if ([self.submitWorkOrdermodel.RequireinstalTime containsString:@"月"]) {
        self.submitWorkOrdermodel.RequireinstalTime = [NSDate getNextDateTime];
    }
    
    self.submitWorkOrdermodel.Product.ProductGroupType.Name = self.Name;
    self.submitWorkOrdermodel.Product.ProductGroupType.Value = self.Value;
    self.submitWorkOrdermodel.Product.BuyDate = self.BuyDate;
    self.submitWorkOrdermodel.Product.ActualChannelType = self.ActualChannelType;
    
    [self showLoadingHUD];
    [self requestSaveWorkOrderWithPhone:user.phone];
    
}

- (void)showPickerProduct:(AUXAfterSaleEditTableViewCell *)cell {
    
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (AUXPickListModel *model in self.productListArray) {
        if (!AUXWhtherNullString(model.Name)) {
            [dataArray addObject:@{@"title" : model.Name}];
        }
    }
    
    @weakify(dataArray , self);
    [AUXModeAndSpeedView alertViewWithNormalData:dataArray selectTitle:self.submitWorkOrdermodel.Product.ProductGroupType.Name confirm:^(NSInteger index) {
        @strongify(dataArray , self);

        NSDictionary *dict = dataArray[index];
        NSString *title = dict[@"title"];
        [cell.detailButton setTitle:title forState:UIControlStateNormal];
        cell.detailButton.selected = YES;

        for (AUXPickListModel *model in self.productListArray) {
            if ([model.Name isEqualToString:title]) {
                self.Name = model.Name;
                self.Value = model.Value;
            }
        }

        self.submitWorkOrdermodel.Product.ProductGroupType.Name = self.Name;
        self.submitWorkOrdermodel.Product.ProductGroupType.Value = self.Value;
    } close:^{

    }];
}

- (void)showPickerUnitDescribe:(AUXAfterSaleEditTableViewCell *)cell {
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSString *title in self.unitDescribeArray) {
        [dataArray addObject:@{@"title" : title}];
    }
     @weakify(self);
    [AUXModeAndSpeedView alertViewWithNormalData:dataArray selectTitle:self.submitWorkOrdermodel.channeltype confirm:^(NSInteger index) {
        @strongify(self);
        NSString *title = [NSString stringWithFormat:@"%@" , self.unitDescribeArray[index]];
        [cell.detailButton setTitle:title forState:UIControlStateNormal];
        self.submitWorkOrdermodel.channeltype = title;
        cell.detailButton.selected = YES;
        
        NSString *unit = self.unitNumberArray[index];
        self.ActualChannelType = unit.integerValue;
        
        self.submitWorkOrdermodel.Product.ActualChannelType = self.ActualChannelType;
    } close:^{
        
    }];
}

- (void)showPickerDate:(AUXAfterSaleEditTableViewCell *)cell {
    
    self.subscribeDatePicker.hidden = YES;
    self.buyDatePicker.hidden = NO;
    self.datePickerBackView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.buyDatePicker.frame = CGRectMake(0, kAUXScreenHeight - datePickerH, SCREEN_WIDTH, datePickerH);
        self.datePickerBackView.alpha = 1;
    }];
}

- (void)tapAtcion:(UITapGestureRecognizer *)tap {
    [self cancelDatePicker];
}

- (void)showPickerLogisticsType:(AUXAfterSaleEditTableViewCell *)cell {
    
    @weakify(self);
    [AUXModeAndSpeedView alertViewWithNormalData:self.logisticsArray selectTitle:cell.detailButton.titleLabel.text confirm:^(NSInteger index) {
        @strongify(self);
        NSDictionary *dict = self.logisticsArray[index];
        NSString *title = dict[@"title"];
        [cell.detailButton setTitle:title forState:UIControlStateNormal];
        cell.detailButton.selected = YES;

        self.submitWorkOrdermodel.LogisticsType = index == 0 ? 1 : 2;
        self.logisticsSelect = index;
    } close:^{

    }];
}

- (void)showPickerSubscribeDate:(AUXAfterSaleEditTableViewCell *)cell {
    self.subscribeDatePicker.hidden = NO;
    self.buyDatePicker.hidden = YES;
    self.datePickerBackView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.subscribeDatePicker.frame = CGRectMake(0, kAUXScreenHeight - datePickerH, SCREEN_WIDTH, datePickerH);
        self.datePickerBackView.alpha = 1;
    }];
}

- (void)pushToAddContactViewController:(AUXAfterSaleEditTableViewCell *)cell {
    
    if (self.contactsListArray.count == 0) {
        AUXAddNewContactViewController *addNewContactViewController = [AUXAddNewContactViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
        addNewContactViewController.fromDeviceControl = self.fromDeviceControl;
        addNewContactViewController.topContactModel = [[AUXTopContactModel alloc]init];
        [self.navigationController pushViewController:addNewContactViewController animated:YES];
    } else {
        [self pushToContactsListViewController:cell];
    }
}

- (void)pushToContactsListViewController:(AUXAfterSaleEditTableViewCell *)cell {
    AUXDetailContactViewController *contactsListViewController = [AUXDetailContactViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    
    self.chooseContact = self.defaultContact;
    contactsListViewController.fromDeviceControl = self.fromDeviceControl;
    contactsListViewController.chooseContact = self.chooseContact;
    contactsListViewController.chooseContactBlock = ^(AUXTopContactModel * _Nonnull contactModel) {
        self.chooseContact = contactModel;
        [self tableViewReload];
    };
    
    [self.navigationController pushViewController:contactsListViewController animated:YES];
}

#pragma mark 通知监听
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    float duration = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect beginRect = [[dict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    float offsety =  endRect.origin.y - beginRect.origin.y ;
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += offsety;
    
    if (viewFrame.origin.y > 0) {
        return ;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = viewFrame;
    }];
}

- (void)addContactNotifiAtcion:(NSNotification *)notification {
    AUXTopContactModel *topContactModel = notification.userInfo[AUXAfterSaleAddNewContact];
    
    self.chooseContact = topContactModel;
    [self tableViewReload];
}

#pragma mark 网络请求

- (void)requestGetDefaultContact {
    AUXUser *user = [AUXUser defaultUser];
    
    [[AUXSoapManager sharedInstance] getDefaultTopContactWithPhone:user.phone completion:^(AUXTopContactModel *contactModel, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (AUXWhtherNullString(contactModel.guid)) {
            [self requestContactsList];
        } else {
            self.defaultContact = contactModel;
            [self tableViewReload];
        }
    }];
}

- (void)requestContactsList {
    AUXUser *user = [AUXUser defaultUser];
    
    [self.contactsListArray removeAllObjects];
    [[AUXSoapManager sharedInstance] getContactsWithPageIndex:1 pageSize:100 phone:user.phone completion:^(NSArray<AUXTopContactModel *> *contactsListArray, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        [self.contactsListArray addObjectsFromArray:contactsListArray];
        
        if (self.contactsListArray.count == 0) {
            self.defaultContact = nil;
        } else {
            self.defaultContact = self.contactsListArray.firstObject;
        }
        [self tableViewReload];
    }];
}

- (void)requestChannelType {
    [self.unitDescribeArray removeAllObjects];
    [self.unitNumberArray removeAllObjects];
    [[AUXNetworkManager manager] getAfterSaleChanneltypeCompletion:^(NSArray<AUXChannelTypeModel *> * _Nonnull channelTypeList) {
        self.channelTypeList = [NSArray arrayWithArray:channelTypeList];
        for (AUXChannelTypeModel *channelTypeModel in self.channelTypeList) {
            [self.unitNumberArray addObject:channelTypeModel.Value];
            [self.unitDescribeArray addObject:channelTypeModel.Name];
        }
    }];
}

- (void)requestProductGroup {
    [[AUXSoapManager sharedInstance] getProductGroupCompletion:^(NSArray<AUXPickListModel *> *productlistArray, NSError * _Nonnull error) {
        self.productListArray = [NSMutableArray arrayWithArray:productlistArray];
    }];
}

- (void)requestSaveWorkOrderWithPhone:(NSString *)phone {
    [[AUXSoapManager sharedInstance] saveWorkOrderWithType:self.afterSaleType SubmitWorkOrderModel:self.submitWorkOrdermodel Userphone:phone completion:^(BOOL result, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (result) {
            
            if (self.afterSaleType == AUXAfterSaleTypeOfInstallation) {
                [MobClick event:@"after_sale_install" attributes:@{@"params" : @(YES)}];
            } else if (self.afterSaleType == AUXAfterSaleTypeOfMaintenance) {
                [MobClick event:@"after_sale_repair" attributes:@{@"params" : @(YES)}];
            }
            
            [self showSuccess:@"预约成功" completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [self showFailure:@"预约失败"];
            NSString *errorString = error.userInfo[NSLocalizedDescriptionKey];
            if (AUXWhtherNullString(errorString)) {
                errorString = @"预约失败";
            }
            
            if (self.afterSaleType == AUXAfterSaleTypeOfInstallation) {
                [MobClick event:@"after_sale_install" attributes:@{@"params" : errorString}];
            } else if (self.afterSaleType == AUXAfterSaleTypeOfMaintenance) {
                [MobClick event:@"after_sale_repair" attributes:@{@"params" : errorString}];
            }
        }
    }];
}

#pragma mark AUXDatePickerDelegate

- (void)datePickerView:(AUXDatePicker *)datePickerView didSelectedDateString:(NSString *)dateString {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.buyDatePicker.frame = CGRectMake(0, kAUXScreenHeight, SCREEN_WIDTH, datePickerH);
        self.subscribeDatePicker.frame = CGRectMake(0, kAUXScreenHeight, SCREEN_WIDTH, datePickerH);
        self.datePickerBackView.alpha = 0;
    }];
    
    if ([datePickerView isEqual:self.buyDatePicker]) {
        
        AUXAfterSaleEditTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
        NSString *title = dateString;
        [cell.detailButton setTitle:title forState:UIControlStateNormal];
        cell.detailButton.selected = YES;
        dateString = [dateString stringByAppendingString:@" 00:00:00"];
        
        self.BuyDate = dateString;
        
        self.submitWorkOrdermodel.Product.BuyDate = self.BuyDate;
    } else {
        
        AUXAfterSaleEditTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        [cell.detailButton setTitle:dateString forState:UIControlStateNormal];
        cell.detailButton.selected = YES;
        
        NSString *requireinstalTime  = dateString;
        requireinstalTime = [requireinstalTime stringByAppendingString:@"T00:00:00.000"];
        self.submitWorkOrdermodel.RequireinstalTime = requireinstalTime;
    }
    
    [self tableViewReload];
}

-(void)cancelDatePicker{
    [UIView animateWithDuration:0.3 animations:^{
        self.buyDatePicker.frame = CGRectMake(0, kAUXScreenHeight, SCREEN_WIDTH, datePickerH);
        self.subscribeDatePicker.frame = CGRectMake(0, kAUXScreenHeight, SCREEN_WIDTH, datePickerH);
        self.datePickerBackView.alpha = 0;
    }];
}

#pragma mark UITableViewDelegate , UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger index = [self.sectionArray.firstObject integerValue];
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self.sectionArray.firstObject integerValue];
    
    if (indexPath.section == 0) {
        if (AUXWhtherNullString(self.defaultContact.guid)) {
            AUXAfterSaleAddContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXAfterSaleAddContactTableViewCell" forIndexPath:indexPath];
            return cell;
        } else {
            
            AUXAUXAfterSaleConmuteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXAUXAfterSaleConmuteTableViewCell" forIndexPath:indexPath];
            cell.contactModel = self.defaultContact;
            self.submitWorkOrdermodel.TopContact = cell.contactModel;
            
            return cell;
        }
        
    } else if (indexPath.section == index - 1) {
        AUXAfterSaleLeaveMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXAfterSaleLeaveMessageCell" forIndexPath:indexPath];
        
        cell.leaveTextViewBlock = ^(NSString *text) {
            self.submitWorkOrdermodel.Memo = text;
        };
        
        if (self.afterSaleType == AUXAfterSaleTypeOfMaintenance) {
            
            if (!AUXWhtherNullString(self.faultName)) {
                cell.textView.text = self.faultName;
                self.submitWorkOrdermodel.Memo = self.faultName;
            }
            cell.whtherMustImageView.hidden = NO;
        } else {
            cell.textView.placeholder = @"请描述您的需求，如特殊环境等…";
        }
        
        return cell;
    } else  {
        AUXAfterSaleEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXAfterSaleEditTableViewCell" forIndexPath:indexPath];
        
        cell.indexPath = indexPath;
        cell.deviceModel = self.deviceModel;
        cell.submitWorkOrdermodel = self.submitWorkOrdermodel;
        cell.unitNumberArray = self.unitNumberArray;
        cell.unitDescribeArray = self.unitDescribeArray;
        if ([cell.titleLabel.text isEqualToString: @"购买单位类型"]&&self.submitWorkOrdermodel.channeltype) {
                [cell.detailButton setTitle:self.submitWorkOrdermodel.channeltype forState:UIControlStateNormal];
        }
        if (indexPath.section == index - 2) {
            cell.titleLabel.text = @"预约日期";
            NSString *requireinstalTime = _submitWorkOrdermodel.RequireinstalTime;
            if ([requireinstalTime containsString:@"-"]) {
                requireinstalTime = [requireinstalTime substringWithRange:NSMakeRange(0, 10)];
            }
            [cell.detailButton setTitle:requireinstalTime forState:UIControlStateNormal];
            cell.detailButton.selected = YES;
            cell.bottomView.hidden = YES;
        }
        
        if (self.afterSaleType == AUXAfterSaleTypeOfInstallation) {
            if (indexPath.section == index - 3) {
                cell.titleLabel.text = @"物流状态";
                [cell.detailButton setTitle:@"货已到需要安装" forState:UIControlStateNormal];
                cell.detailButton.selected = YES;
                if (self.submitWorkOrdermodel.LogisticsType) {
                    NSDictionary *dict = self.logisticsArray[self.logisticsSelect];
                    [cell.detailButton setTitle:dict[@"title"] forState:UIControlStateNormal];
                }
                cell.bottomView.hidden = YES;
            }
        }
        
        cell.detailBlock = ^{
            [self tableView:tableView didSelectRowAtIndexPath:indexPath];
        };
        
        return cell;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) {
        AUXAfterSaleHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"AUXAfterSaleHeaderView" owner:nil options:nil].firstObject;
        
        if (section == 0) {
            headerView.titleLabel.text = @"联系人信息";
        } else if (section == 1) {
            headerView.titleLabel.text = @"预约详情";
        }
        
        return headerView;
    }
    return nil;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSInteger index = [self.sectionArray.firstObject integerValue];
    
    if (section == index - 1) {
        AUXAfterSaleFooterView *footerView = [[NSBundle mainBundle] loadNibNamed:@"AUXAfterSaleFooterView" owner:nil options:nil].firstObject;
        
        @weakify(footerView);
        footerView.phoneBlock = ^{
            @strongify(footerView);
            NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",footerView.phoneButton.currentTitle];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        };
        return footerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger index = [self.sectionArray.firstObject integerValue];
    
    AUXAfterSaleEditTableViewCell *cell = (AUXAfterSaleEditTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (AUXWhtherNullString(self.defaultContact.guid)) {
            [self pushToAddContactViewController:cell];
        } else {
            [self pushToContactsListViewController:cell];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showPickerProduct:cell];
        } else if (indexPath.row == 1) {
            [self showPickerUnitDescribe:cell];
        } else if (indexPath.row == 2) {
            [self showPickerDate:cell];
        }
    } else if (indexPath.section == index - 2) {
        [self showPickerSubscribeDate:cell];
    } else if (self.afterSaleType == AUXAfterSaleTypeOfInstallation) {
        if (indexPath.section == 2) {
            [self showPickerLogisticsType:cell];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) {
        return 40;
    }
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSInteger index = [self.sectionArray.firstObject integerValue];
    
    if (section == index - 1) {
        return 50;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!AUXWhtherNullString(self.defaultContact.guid)) {
            return 67 + self.defaultContact.addressHeight;
        }
    }
    NSInteger index = [self.sectionArray.firstObject integerValue];
    
    if (indexPath.section == index - 1) {
        return 110;
    }
    
    return 60;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView endEditing:YES];
}

@end
