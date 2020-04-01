//
//  AUXVIPViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/28.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXVIPViewController.h"
#import "AUXVIPActiveTableViewCell.h"
#import "AUXVIPScanViewController.h"
#import "AUXVIPImportDeviceViewController.h"
#import "AUXVIPBindDeviceViewController.h"
#import "AUXVIPSuccessViewController.h"

#import "AUXVIPActiveTableViewCell.h"
#import "UITableView+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXSoapManager.h"
#import "AUXUser.h"
#import "AUXDeviceInfo.h"
#import "AUXUserprofileModel.h"

@interface AUXVIPViewController ()<UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *vipCardImageView;
@property (weak, nonatomic) IBOutlet UILabel *vipCardTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITextField *deviceNumberTextfiled;
@property (weak, nonatomic) IBOutlet UITextField *vipCardNumberTextfiled;
@property (weak, nonatomic) IBOutlet UIView *tableBackView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vipCardTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeight;

@property (weak, nonatomic) IBOutlet UIView *firstBottomView;
@property (weak, nonatomic) IBOutlet UIView *secondBottomView;


@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (nonatomic,assign) BOOL isImportDeviceSN;
@property (nonatomic,assign) BOOL deviceSnCanActive;
@property (nonatomic,assign) BOOL isShowBootView;
@property (nonatomic,strong) AUXUserprofileModel *userProfileModel;

@property (nonatomic, strong, readonly) NSArray<AUXDeviceInfo *> *deviceInfoArray;    // 设备列表
@end

@implementation AUXVIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initSubviews {
    [super initSubviews];
    
    self.deviceNumberTextfiled.delegate = self;
    self.vipCardNumberTextfiled.delegate = self;
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
    [self.tableView registerCellWithNibName:@"AUXVIPActiveTableViewCell"];
    self.sureButton.layer.borderWidth = 2;
    self.sureButton.layer.borderColor = [UIColor colorWithHexString:@"666666"].CGColor;
    self.sureButton.layer.cornerRadius = self.sureButton.frame.size.height / 2;
    self.deviceNumberTextfiled.returnKeyType = UIReturnKeyNext;
    [self.deviceNumberTextfiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark getter
- (NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    
    NSMutableArray *dataArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    NSMutableArray *array = [NSMutableArray array];
    for (AUXDeviceInfo *deviceInfo in dataArray) {
        if (AUXWhtherNullString(deviceInfo.sn)) {
            [array addObject:deviceInfo];
        }
    }
    [dataArray removeObjectsInArray:array];
    
    return dataArray;
}

#pragma mark actions
- (IBAction)scanDeviceAtcion:(id)sender {
    AUXVIPScanViewController *vipScanViewController = [[AUXVIPScanViewController alloc]init];
    vipScanViewController.vipScanResultBlock = ^(NSString * _Nonnull content) {
        if (content) {
            if (![self.deviceNumberTextfiled.text isEqualToString:content]) {
                 self.deviceNumberTextfiled.text = content;
                self.isShowBootView = NO;
                [self hideAnimation];
            }
        }
    };
    [self.navigationController pushViewController:vipScanViewController   animated:YES];
}

- (IBAction)scanVipCardNumberAtcion:(id)sender {
    AUXVIPScanViewController *vipScanViewController = [[AUXVIPScanViewController alloc]init];
    vipScanViewController.vipScanResultBlock = ^(NSString * _Nonnull content) {
        if (content) {
            self.vipCardNumberTextfiled.text = content;
        }
    };
    [self.navigationController pushViewController:vipScanViewController   animated:YES];
}

- (IBAction)importDeviceFromBindAtcion:(id)sender {
    
    if (self.deviceInfoArray.count == 0) {
        [self showFailure:@"暂无已绑定产品条码设备"];
        return ;
    }
    
    AUXVIPImportDeviceViewController *vipImportDeviceViewController = [AUXVIPImportDeviceViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
    vipImportDeviceViewController.deviceSnBlock = ^(NSString * _Nonnull deviceSN) {
        if (deviceSN) {
            self.deviceNumberTextfiled.text = deviceSN;
            self.isImportDeviceSN = YES;
            [self requestDeviceInfoWithDeviceSn:self.deviceNumberTextfiled.text];
        }
    };
    [self.navigationController pushViewController:vipImportDeviceViewController animated:YES];
}

- (IBAction)sureBindAtcion:(id)sender {
    if (self.deviceNumberTextfiled.text.length != 0 && !self.isShowBootView) {
        [self requestDeviceInfoWithDeviceSn:self.deviceNumberTextfiled.text];
        return;
    }
    if (self.deviceNumberTextfiled.text.length == 0) {
        [self showErrorViewWithMessage:@"请输入产品条码"];
        return ;
    }
    if (self.vipCardNumberTextfiled.text.length == 0) {
        [self showErrorViewWithMessage:@"请输入金卡卡号"];
        return ;
    }
    if (!self.deviceSnCanActive) {
        [self showErrorViewWithMessage:@"请填写正确的产品条码"];
        return;
    }
    
    [self requestCheckGoldenCard:self.vipCardNumberTextfiled.text];
}

- (void)showAnimation {
    
    if (!self.tableBackView.hidden) {
        return ;
    }
    self.vipCardImageView.hidden = NO;
    self.vipCardTitleLabel.hidden = NO;
    self.vipCardImageView.alpha = 1;
    self.vipCardTitleLabel.alpha = 1;
    self.tableBackView.hidden = NO;
    self.tableBackView.alpha = 0;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.isShowBootView = YES;
        self.editViewTop.constant = 0;
        self.editViewHeight.constant = self.editViewHeight.constant - 20;
        self.vipCardTop.constant = 24;
        self.tableBackView.alpha = 1;
        self.vipCardTitleLabel.alpha = 0;
        self.vipCardImageView.alpha = 0;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.vipCardImageView.hidden = YES;
        self.vipCardTitleLabel.hidden = YES;
        [self.tableView reloadData];
    }];
}

- (void)hideAnimation {
    
    if (self.tableBackView.hidden) {
        return ;
    }
    self.vipCardImageView.hidden = NO;
    self.vipCardTitleLabel.hidden = NO;
    self.vipCardImageView.alpha = 0;
    self.vipCardTitleLabel.alpha = 0;
    self.tableBackView.hidden = NO;
    self.tableBackView.alpha = 1;
    [UIView animateWithDuration:0.1 animations:^{
        self.editViewTop.constant = 158;
         self.isShowBootView = NO;
        self.editViewHeight.constant = self.editViewHeight.constant + 20;
        self.vipCardTop.constant = 44;
        self.tableBackView.alpha = 0;
        self.vipCardTitleLabel.alpha = 1;
        self.vipCardImageView.alpha = 1;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.tableBackView.hidden = YES;
    }];
}

#pragma mark KVO监听输入框

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.vipCardNumberTextfiled]) {
        self.firstBottomView.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
        self.secondBottomView.backgroundColor = [UIColor colorWithHexString:@"333333"];
        if (self.deviceNumberTextfiled.text.length !=0) {
            [self requestDeviceInfoWithDeviceSn:self.deviceNumberTextfiled.text];
        }
    } else if ([textField isEqual:self.deviceNumberTextfiled]) {
        self.firstBottomView.backgroundColor = [UIColor colorWithHexString:@"333333"];
        self.secondBottomView.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
    }
    
    if ([textField isEqual:self.vipCardNumberTextfiled]) {
        [self animationUp];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.vipCardNumberTextfiled]) {
        [self animationDown];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.deviceNumberTextfiled]) {
        [self.vipCardNumberTextfiled becomeFirstResponder];
    } else if ([textField isEqual:self.vipCardNumberTextfiled]) {
        [self.vipCardNumberTextfiled resignFirstResponder];
        [self.sureButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.deviceNumberTextfiled == textField) {
        if (AUXWhtherNullString(string)) {
            if (self.isShowBootView) {
                 [self hideAnimation];
            }
        }
    }
    
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    UITextField *textfiled = (UITextField *)sender;
    if (textfiled.text.length==0) {
        if (self.isShowBootView) {
            [self hideAnimation];
        }
    }
    
}

#pragma mark 页面动画
- (void)animationUp {
    
    __block CGRect frame = self.view.frame;
    
    if (frame.origin.y < 0) {
        return ;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        frame.origin.y -= 100;
        self.view.frame = frame;
    }];
}

- (void)animationDown {
    __block CGRect frame = self.view.frame;
    
    if (frame.origin.y > 0) {
        return ;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        frame.origin.y += 100;
        self.view.frame = frame;
    }];
}

#pragma mark 网络请求
- (void)requestDeviceInfoWithDeviceSn:(NSString *)deviceSn {
    
    if (AUXWhtherNullString(deviceSn)) {
        return ;
    }
    @weakify(self);
    [self showLoadingHUD];
    [[AUXSoapManager sharedInstance] GetUserprofileWithNumber:deviceSn completion:^(AUXUserprofileModel *userProfileModel, NSString *message) {
        @strongify(self);
        [self hideLoadingHUD];
        if (!AUXWhtherNullString(userProfileModel.guid)) {
            self.deviceSnCanActive = YES;
            self.userProfileModel = userProfileModel;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.isShowBootView) {
                   [self showAnimation];
                }
            });
        } else {
            self.deviceSnCanActive = NO;
            [self showToastshortWithmessageinCenter:@"机型条码不存在"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isShowBootView) {
                    [self hideAnimation];
                }
            });
        }
    }];
}

- (void)requestCheckGoldenCard:(NSString *)cardNumber {
    @weakify(self);
     [self showLoadingHUD];
    [[AUXSoapManager sharedInstance] CheckGoldenCardWithNumber:cardNumber completion:^(BOOL result, NSString *message) {
        @strongify(self);
         [self hideLoadingHUD];
        if (result) {
            [self requestActiveVIPCardWithCardNumber:self.vipCardNumberTextfiled.text deviceSn:self.deviceNumberTextfiled.text];
        } else {
            [self showErrorViewWithMessage:@"请填写正确的金卡卡号"];
        }
    }];
}

- (void)requestActiveVIPCardWithCardNumber:(NSString *)cardNumber deviceSn:(NSString *)deviceSn {
    
    [self showLoadingHUD];
    @weakify(self);
    [[AUXSoapManager sharedInstance] useGoldenCardWithCardId:cardNumber number:deviceSn userphone:[AUXUser defaultUser].phone completion:^(BOOL result, NSString *message) {
        @strongify(self);
        [self hideLoadingHUD];
        if (result) {
            if (!self.isImportDeviceSN && self.deviceInfoArray.count > 0) {
                AUXVIPBindDeviceViewController *vipBindDeviceViewController = [AUXVIPBindDeviceViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
                vipBindDeviceViewController.deviceSN = self.deviceNumberTextfiled.text;
                [self.navigationController pushViewController:vipBindDeviceViewController animated:YES];
            } else {
                AUXVIPSuccessViewController *vipSuccessViewController = [AUXVIPSuccessViewController instantiateFromStoryboard:kAUXStoryboardNameAfterSale];
                [self.navigationController pushViewController:vipSuccessViewController animated:YES];
            }
        } else {
            if (!message) {
                message = @"金卡与条码不匹配";
            }
            [self showErrorViewWithMessage:message];
        }
    }];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXVIPActiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VIPActiveTableViewCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    cell.bottomView.hidden = NO;
    
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"产品线";
            cell.contentLabel.text = self.userProfileModel.ProductGroupIdName;
            break;
        case 1:
            cell.titleLabel.text = @"产品型号";
            cell.contentLabel.text = self.userProfileModel.ProductIdName;
            break;
        case 2:
            cell.titleLabel.text = @"购买日期";
            cell.contentLabel.text = self.userProfileModel.BuyDate;
            break;
        case 3:
            cell.titleLabel.text = @"姓名";
            cell.contentLabel.text = self.userProfileModel.Customer;
            break;
        case 4:
            cell.titleLabel.text = @"电话";
            cell.contentLabel.text = self.userProfileModel.PhoneNumber;
            cell.bottomView.hidden = YES;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark 通知监听

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
    self.firstBottomView.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
    self.secondBottomView.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];
}

@end
