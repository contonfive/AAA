//
//  AUXSleepDIYSetViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepDIYSetViewController.h"
#import "AUXSleepDIYListViewController.h"

#import "AUXSubtitleTableViewCell.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXAlertCustomView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "NSString+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"
@interface AUXSleepDIYSetViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AUXSleepDIYSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"睡眠DIY名称";
        cell.indicatorImageView.hidden = NO;
        
        cell.subtitleLabel.text = self.sleepDIYModel.name;
        
    } else {
        cell.titleLabel.text = @"删除睡眠DIY";
        cell.indicatorImageView.hidden = YES;
        
        cell.subtitleLabel.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        if (AUXWhtherNullString(self.sleepDIYModel.sleepDiyId)) {
            return ;
        }
        
        AUXDeviceInfoAlertView *alertView = [AUXDeviceInfoAlertView alertViewWithNameType:AUXNamingTypeSleepDIY deviceInfo:self.deviceInfo device:nil address:nil content:self.sleepDIYModel.name confirm:^(NSString *name) {
            if (self.controlType == AUXDeviceControlTypeVirtual) {
                return ;
            }
            
            if (!self.deviceInfo) {
                return;
            }
            
            if ([name length] == 0) {
                [self showErrorViewWithMessage:@"名称不能为空"];
                return;
            }
            
            self.sleepDIYModel.name = name;
            
            [self updateSleepDIYByServer];
            
        } close:^{
            
        }];
        alertView.currentVC = self;
    } else {
        
        [AUXAlertCustomView alertViewWithMessage:@"确定要删除睡眠DIY吗？" confirmAtcion:^{
            if (self.deviceInfo.virtualDevice) {
                [self showFailure:kAUXLocalizedString(@"VirtualAletMessage")];
                return ;
            }
            
            if (AUXWhtherNullString(self.sleepDIYModel.sleepDiyId)) {
                return ;
            }
            
            [self deleteSleepDIY:self.sleepDIYModel];
        } cancleAtcion:^{
            
        }];
        
    }
    
}

#pragma mark 网络请求

- (void)updateSleepDIYByServer {

    self.sleepDIYModel.deviceId = self.deviceInfo.deviceId;
    [[AUXNetworkManager manager] updateSleepDIYWithModel:self.sleepDIYModel completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                
                if (self.updateSleepDIYNameBlock) {
                    self.updateSleepDIYNameBlock(self.sleepDIYModel.name);
                }
                
                [self showSuccess:@"保存成功" completion:^{
                    [self.tableView reloadData];
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:

                [self showErrorViewWithError:error defaultMessage:@"保存失败"];
                break;
        }
    }];
}

- (void)deleteSleepDIY:(AUXSleepDIYModel *)sleepDIYModel {
    
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] deleteSleepDIYWithId:sleepDIYModel.sleepDiyId completion:^(NSError * _Nonnull error) {
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {

                @weakify(self);
                [self showSuccess:@"删除成功" completion:^{
                    @strongify(self);
                    for (AUXBaseViewController *vc in self.navigationController.viewControllers) {
                        if ([vc isKindOfClass:[AUXSleepDIYListViewController class]]) {
                            [self.navigationController popToViewController:vc animated:YES];
                            return ;
                        }
                    }
                }];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                [self showErrorViewWithError:error defaultMessage:@"删除失败"];
                break;
        }
    }];
}

@end
