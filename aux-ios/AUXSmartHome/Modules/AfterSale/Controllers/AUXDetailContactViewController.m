//
//  AUXDetailContactViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/26.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDetailContactViewController.h"
#import "AUXDetailContactTableViewCell.h"
#import "AUXAddNewContactViewController.h"
#import "UITableView+AUXCustom.h"
#import "AUXSoapManager.h"
#import "AUXUser.h"
#import "AUXCurrentNoDataView.h"

@interface AUXDetailContactViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *contactsListArray;
@property (nonatomic,strong) AUXCurrentNoDataView *noDataView;
@end

@implementation AUXDetailContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXDetailContactTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestContactsList];
}

#pragma mark getter
- (NSMutableArray *)contactsListArray {
    if (!_contactsListArray) {
        _contactsListArray = [NSMutableArray array];
    }
    return _contactsListArray;
}

- (AUXCurrentNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[NSBundle mainBundle]loadNibNamed:@"AUXCurrentNoDataView" owner:self options:nil].firstObject;
        _noDataView.iconImageView.image = [UIImage imageNamed:@"mine_service_img_noaddress"];
        _noDataView.titleLabel.text = @"暂无联系人信息";
        _noDataView.frame = CGRectMake(0, kAUXNavAndStatusHight, kAUXScreenWidth, kAUXScreenHeight);
        [self.view addSubview:_noDataView];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

#pragma mark setter
- (void)setChooseContact:(AUXTopContactModel *)chooseContact {
    _chooseContact = chooseContact;
}

#pragma mark 网络请求
- (void)requestContactsList {
    AUXUser *user = [AUXUser defaultUser];
    
    [self showLoadingHUD];
    [self.contactsListArray removeAllObjects];
    [[AUXSoapManager sharedInstance] getContactsWithPageIndex:1 pageSize:100 phone:user.phone completion:^(NSArray<AUXTopContactModel *> *contactsListArray, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        [self.contactsListArray addObjectsFromArray:contactsListArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)requestSetDefault:(AUXDetailContactTableViewCell *)cell  {
    
    AUXUser *user = [AUXUser defaultUser];
    
    BOOL result = cell.isDefaultButton.selected ? YES : NO;
    
    [[AUXSoapManager sharedInstance] setTopContactDefaultWithId:cell.topContactModel.guid isDefault:result userPhone:user.phone completion:^(BOOL result, NSError * _Nonnull error) {
        if (result) {
            
            for (AUXDetailContactTableViewCell * obj in self.tableView.visibleCells) {
                if ([obj isEqual:cell]) {
                    continue;
                }
                obj.isDefaultButton.selected = NO;
            }
            
            [self showSuccess:@"设置成功"];
        } else {
            [self showFailure:@"设置失败"];
        }
    }];
}

- (void)requestDeleteContact:(AUXDetailContactTableViewCell *)cell {
    
    [[AUXSoapManager sharedInstance] deleteTopContactWithId:cell.topContactModel.guid completion:^(BOOL result, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        if (result) {
            
            [self showSuccess:@"删除成功" completion:^{
               
                if ([self.contactsListArray containsObject:cell.topContactModel]) {
                     [self.contactsListArray removeObject:cell.topContactModel];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    AUXTopContactModel *tempContactModel = self.chooseContact;
                    for (AUXTopContactModel *contactModel in self.contactsListArray) {
                        if ([contactModel.guid isEqualToString:self.chooseContact.guid]) {
                            self.chooseContact = tempContactModel;
                        } else {
                            self.chooseContact.guid = nil;
                        }
                    }
                    if (self.contactsListArray.count == 0) {
                        self.chooseContact.guid = nil;
                    }
                    
                    [self.tableView reloadData];
                });
            }];
        } else {
            [self showFailure:@"删除失败"];
        }
    }];
}

#pragma mark atcion
- (void)pushToAddContactViewController:(AUXDetailContactTableViewCell *)cell {
    AUXAddNewContactViewController *addNewContactViewController = [AUXAddNewContactViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    addNewContactViewController.topContactModel = cell.topContactModel;
    
    [self.navigationController pushViewController:addNewContactViewController animated:YES];
}

- (IBAction)addContactAtcion:(id)sender {
    AUXAddNewContactViewController *addNewContactViewController = [AUXAddNewContactViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    addNewContactViewController.topContactModel = [[AUXTopContactModel alloc]init];
    addNewContactViewController.contactFromType = AUXAfterSaleAddContactTypeOfFromContactList;
    addNewContactViewController.fromDeviceControl = self.fromDeviceControl;
    [self.navigationController pushViewController:addNewContactViewController animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if (self.contactsListArray.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    
    return self.contactsListArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXDetailContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailContactTableViewCell" forIndexPath:indexPath];
    
    AUXTopContactModel *topContactModel = self.contactsListArray[indexPath.row];
    cell.topContactModel = topContactModel;
    
    __weak typeof(cell) weakCell = cell;
    cell.isDefaultBlock = ^(BOOL selected) {
        [self requestSetDefault:weakCell];
    };
    
    cell.editBlock = ^{
        [self pushToAddContactViewController:weakCell];
    };
    
    cell.deleteBlock = ^{
        
        [self alertWithMessage:@"是否确定删除" confirmTitle:@"确定" confirmBlock:^{
            [self showLoadingHUD];
            [self requestDeleteContact:weakCell];
        } cancelTitle:@"取消" cancelBlock:^{
            
        }];
    };
    
    cell.bottomView.hidden = NO;
    if (indexPath.row ==self.contactsListArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AUXTopContactModel *contactModel = self.contactsListArray[indexPath.row];
    
    if (self.chooseContactBlock) {
        self.chooseContactBlock(contactModel);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXTopContactModel *topContactModel = self.contactsListArray[indexPath.row];
    return kAUXScreenWidth * 0.28 + topContactModel.addressHeight - 16 + 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
@end
