//
//  AUXAddNewContactViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/21.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXAddNewContactViewController.h"
#import "AUXAfterSaleViewController.h"
#import "AUXAddContactEditTableViewCell.h"
#import "AUXWhtherSetDefaultTableViewCell.h"
#import "AUXAddContactFooterView.h"
#import "AUXSoapManager.h"
#import "AUXUser.h"

#import "AUXChooseLocationView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import <YYModel.h>

@interface AUXAddNewContactViewController ()<UITableViewDelegate , UITableViewDataSource , UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *provinceArray;
@property (nonatomic,strong) NSMutableArray *cityArray;
@property (nonatomic,strong) NSMutableArray *countyArray;
@property (nonatomic,strong) NSMutableArray *townArray;

@property (nonatomic,strong) AUXChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;
@property (nonatomic,strong) UITapGestureRecognizer *tap;

@property (nonatomic,strong) AUXAddContactFooterView *footerView;
@end

@implementation AUXAddNewContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.cover];
    [self.tableView registerCellWithNibName:@"AUXAddContactEditTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXWhtherSetDefaultTableViewCell"];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self whtherSaveBtnEnable]) {
        self.footerView.saveButton.enabled = YES;
    } else {
        self.footerView.saveButton.enabled = NO;
    }
}

- (BOOL)whtherSaveBtnEnable {
    
    NSString *localString = nil;
    if (self.topContactModel.Province) {
        localString = self.topContactModel.Province;
    }
    if (self.topContactModel.City) {
        localString = [NSString stringWithFormat:@"%@ %@" , localString , self.topContactModel.City];
    }
    if (self.topContactModel.County) {
        localString = [NSString stringWithFormat:@"%@ %@" , localString , self.topContactModel.County];
    }
    if (self.topContactModel.Town) {
        localString = [NSString stringWithFormat:@"%@ %@" , localString , self.topContactModel.Town];
    }
    
    if (AUXWhtherNullString(self.topContactModel.Name)) {
        return NO;
    }
    
    if (AUXWhtherNullString(self.topContactModel.Phone)) {
        return NO;
    }
    
    if (AUXWhtherNullString(localString)) {
        return NO;
    }
    
    if (AUXWhtherNullString(self.topContactModel.Address)) {
        return NO;
    }

    return YES;
}

#pragma mark setter
- (void)setTopContactModel:(AUXTopContactModel *)topContactModel {
    _topContactModel = topContactModel;
}
#pragma mark getter
- (NSMutableArray *)provinceArray {
    if (!_provinceArray) {
        _provinceArray = [NSMutableArray array];
    }
    return _provinceArray;
}

- (NSMutableArray *)cityArray {
    if (!_cityArray) {
        _cityArray = [NSMutableArray array];
    }
    return _cityArray;
}

- (NSMutableArray *)countyArray {
    if (!_countyArray) {
        _countyArray = [NSMutableArray array];
    }
    return _countyArray;
}

- (NSMutableArray *)townArray {
    if (!_townArray) {
        _townArray = [NSMutableArray array];
    }
    return _townArray;
}

- (UIView *)cover{
    
    if (!_cover) {
        _cover = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_cover addSubview:self.chooseLocationView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCoverAtcion:)];
        [_cover addGestureRecognizer:tap];
        tap.delegate = self;
        _cover.hidden = YES;
    }
    return _cover;
}

- (AUXChooseLocationView *)chooseLocationView{
    
    if (!_chooseLocationView) {
        _chooseLocationView = [[AUXChooseLocationView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350)];
        
    }
    return _chooseLocationView;
}


#pragma mark atcions
- (void)tapAtcion:(UITapGestureRecognizer *)tap {
    
}

- (void)tapCoverAtcion:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.25 animations:^{
        self.cover.hidden = YES;
    }];
}

- (void)chooseLocationAtcion:(AUXAddContactEditTableViewCell *)cell {

    self.cover.hidden = !self.cover.hidden;
    self.chooseLocationView.hidden = self.cover.hidden;
    self.chooseLocationView.model = self.topContactModel;
    
    @weakify(self);
    self.chooseLocationView.chooseFinish = ^(NSMutableDictionary *localDict) {
        @strongify(self);
        cell.editTextfiled.text = localDict[@"local"];
        
        [self.topContactModel yy_modelSetWithDictionary:localDict];
        
        if ([self whtherSaveBtnEnable]) {
            self.footerView.saveButton.enabled = YES;
        } else {
            self.footerView.saveButton.enabled = NO;
        }
        
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            self.cover.hidden = YES;
        }];
    };
    
}

#pragma mark 网络请求
- (void)requestSaveContact {
    
    AUXUser *user = [AUXUser defaultUser];
    if (AUXWhtherNullString(self.topContactModel.Name)) {
        [self showErrorViewWithMessage:@"请填写联系人姓名"];
        return ;
    } else if (AUXWhtherNullString(self.topContactModel.Phone)) {
        [self showErrorViewWithMessage:@"请填写联系人手机号"];
        return ;
    } else if (AUXWhtherNullString(self.topContactModel.ProvinceId)) {
        [self showErrorViewWithMessage:@"请选择联系人所在区域"];
        return ;
    } else if (AUXWhtherNullString(self.topContactModel.Address)) {
        [self showErrorViewWithMessage:@"请填写联系人详细地址"];
        return ;
    }
    if (!AUXCheckPhoneNumber(self.topContactModel.Phone)) {
        [self showErrorViewWithMessage:@"请填写正确手机号"];
        return ;
    }
    
    self.topContactModel.Userphone = user.phone;
    
    [self showLoadingHUD];
    [[AUXSoapManager sharedInstance] saveContactWithModel:self.topContactModel completion:^(NSString *guid, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        
        if (guid) {
            
            self.topContactModel.guid = guid;
            if (self.topContactModel.IsDefault) {
                [self requestSetDefault:guid userPhone:user.phone];
            } else {
                [self popToAfterSaleViewControllerWithText:@"保存成功"];
            }
            
        } else {
            [self showFailure:@"创建失败"];
        }
    }];
}

- (void)requestSetDefault:(NSString *)guid userPhone:(NSString *)userPhone {
    [[AUXSoapManager sharedInstance] setTopContactDefaultWithId:guid isDefault:YES userPhone:userPhone completion:^(BOOL result, NSError * _Nonnull error) {
        if (result) {
            
            [self popToAfterSaleViewControllerWithText:@"设置成功"];
        } else {
            [self showFailure:@"设置失败"];
        }
    }];
}

- (void)popToAfterSaleViewControllerWithText:(NSString *)text {
    [self showSuccess:text completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:AUXAfterSaleAddNewContact object:nil userInfo:@{AUXAfterSaleAddNewContact : self.topContactModel}]];
        
        if (self.contactFromType == AUXAfterSaleAddContactTypeOfFromContactList) {
            NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
            if (self.fromDeviceControl) {
                for (UIViewController * vc in viewControllers) {
                    if ([vc isKindOfClass:[AUXAfterSaleViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
            }  else {
                    [viewControllers removeObjectsInRange:NSMakeRange(3, viewControllers.count - 3)];                
            }
            [self.navigationController setViewControllers:viewControllers animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_chooseLocationView.frame, point)){
        return NO;
    }
    return YES;
}

#pragma mark 键盘收缩
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.tableView endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark UITableViewDelegate , UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    AUXAddContactFooterView *footerView = [[NSBundle mainBundle] loadNibNamed:@"AUXAddContactFooterView" owner:nil options:nil].firstObject;
    footerView.saveButton.layer.borderWidth = 2;
    footerView.saveButton.layer.borderColor = [UIColor colorWithHexString:@"256BBD"].CGColor;
    footerView.saveButton.enabled = NO;

    self.footerView = footerView;
    
    footerView.saveBlock = ^{
        [self requestSaveContact];
    };
    
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 4) {
        AUXWhtherSetDefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXWhtherSetDefaultTableViewCell" forIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        cell.model = self.topContactModel;
        cell.setDefaultBlock = ^(BOOL selected) {
            self.topContactModel.IsDefault = selected;
        };
        
        return cell;
    }
    
    AUXAddContactEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddContactEditTableViewCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.model = self.topContactModel;
    
    @weakify(self);
    cell.textfiledBlock = ^(NSString * _Nonnull text) {
        @strongify(self);
        if (indexPath.row == 0) {
            self.topContactModel.Name = text;
        } else if (indexPath.row == 1) {
            self.topContactModel.Phone = text;
        } else if (indexPath.row == 3) {
            self.topContactModel.Address = text;
        }
        
        if ([self whtherSaveBtnEnable]) {
            self.footerView.saveButton.enabled = YES;
        } else {
            self.footerView.saveButton.enabled = NO;
        }
    };
    
    if (indexPath.row == 1) {
        cell.editTextfiled.keyboardType = UIKeyboardTypeNumberPad;
    } else if (indexPath.row == 2) {
        cell.editTextfiled.userInteractionEnabled = NO;
        cell.rightImageView.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AUXAddContactEditTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 2) {
        [self.tableView endEditing:YES];
        
        [self chooseLocationAtcion:cell];
    } else if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 3) {
        [cell.editTextfiled becomeFirstResponder];
    } else if (indexPath.row == 4) {
        AUXWhtherSetDefaultTableViewCell *setDefaultCell = [tableView cellForRowAtIndexPath:indexPath];
        
        [setDefaultCell.whtherSetDefaultButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        return 45;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 80;
}

@end
