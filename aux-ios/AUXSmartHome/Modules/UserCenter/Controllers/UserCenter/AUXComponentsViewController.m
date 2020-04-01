//
//  AUXComponentsViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/5/31.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXComponentsViewController.h"
#import "AUXComponentsHeaderView.h"

#import "AUXScanCodeViewController.h"
#import "AUXNotificationComponentPromptViewController.h"

#import "AUXUser.h"
#import "AUXArchiveTool.h"
#import "AUXDeviceListViewModel.h"
#import "AUXNetworkManager.h"

#import <YYModel.h>
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>


#import "AUXCompoentsTableViewCell.h"
#import "AUXDeviceStateInfo.h"

#import "AUXAlertCustomView.h"

@interface AUXComponentsViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDeviceView;

@property (nonatomic,strong) NSMutableArray *selectedArray;
@property (nonatomic,strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation AUXComponentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedArray = [[AUXArchiveTool readDataByNSFileManager] mutableCopy];
    [self getDeviceList];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)initSubviews {
    [self.tableView registerCellWithNibName:@"AUXCompoentsTableViewCell"];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 1)];
}


- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

#pragma mark atcion

- (IBAction)actionPushToHelpVC:(id)sender {
    AUXNotificationComponentPromptViewController *notificationVC = [AUXNotificationComponentPromptViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    [self.navigationController pushViewController:notificationVC animated:YES];
}

- (IBAction)addDeviceAtcion:(id)sender {
    AUXScanCodeViewController *scanCodeViewController = [AUXScanCodeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceConfig];
    [self.navigationController pushViewController:scanCodeViewController animated:YES];
}


#pragma mark UITableViewDelegate , UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_deviceInfoArray.count == 0) {
        self.noDeviceView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.noDeviceView.hidden = YES;
        self.tableView.hidden = NO;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXCompoentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXCompoentsTableViewCell" forIndexPath:indexPath];
    
    AUXDeviceInfo *deviceInfo = self.deviceInfoArray[indexPath.row];
    cell.nameLabel.text = deviceInfo.alias;
    NSURL *imageURL = [NSURL URLWithString:deviceInfo.deviceMainUri];
    [cell.iconImageview sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRefreshCached];
    cell.switchButton.selected = [self.selectedArray containsObject:deviceInfo.deviceId] ? YES : NO;
    if ( cell.switchButton.selected) {
        [cell.switchButton setImage:[UIImage imageNamed:@"common_btn_on"] forState:UIControlStateNormal];
    }else{
        [cell.switchButton setImage:[UIImage imageNamed:@"common_btn_off"] forState:UIControlStateNormal];
    }
    cell.deviceInfo = deviceInfo;
    AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
    BOOL iscontain = [deviceStateinfo.dataArray containsObject:deviceInfo.deviceId];
    if (iscontain) {
        cell.offLineLabel.text = @"";
        cell.offLineImageView.hidden = YES;
    }else{
        cell.offLineLabel.text = @"(离线)";
        cell.offLineImageView.hidden = NO;
    }
    
    @weakify(cell);
    cell.tapBlcok = ^(AUXDeviceInfo *deviceInfo) {
        @strongify(cell);
        if (!cell.switchButton.selected) {
            if ([self.selectedArray containsObject:deviceInfo.deviceId]) {
                [self.selectedArray removeObject:deviceInfo.deviceId];
            }
            if (self.selectedArray.count ==4) {
                 [self showLoadingHUDWithText:@"每次最多添加四个设备"];
            }
        } else if (cell.switchButton.selected) {
            if (self.selectedArray.count>3) {
                [self showLoadingHUDWithText:@"每次最多添加四个设备"];
            }else{
                [self.selectedArray addObject:deviceInfo.deviceId];
            }
        }
        [AUXArchiveTool saveDataByNSFileManager:self.selectedArray];
    };
    
    cell.bottomView.hidden = NO;
    if (indexPath.row == self.deviceInfoArray.count - 1) {
        cell.bottomView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}


/// 获取设备列表
- (void)getDeviceList {
    if ([AUXUser isLogin]) {
        [[AUXNetworkManager manager] getDeviceListWithCompletion:^(NSArray<AUXDeviceInfo *> * _Nullable deviceInfoList, NSError * _Nonnull error) {
            switch (error.code) {
                case AUXNetworkErrorNone:
                    [self dealWithDeviceInfoList:deviceInfoList];
                    break;
                default:
                    [self showToastshortWitherror:error];
                    break;
            }
        }];
    }
}

/// 处理设备列表
- (void)dealWithDeviceInfoList:(NSArray<AUXDeviceInfo *> *)deviceInfoList {
    if (!deviceInfoList || deviceInfoList.count == 0) {
        return;
    }
    self.deviceInfoArray = nil;
    self.deviceInfoArray = deviceInfoList.mutableCopy;
    NSMutableArray *gatewayArray = [NSMutableArray array];
    NSMutableArray *removeArray = [NSMutableArray array];
    [self.deviceInfoArray enumerateObjectsUsingBlock:^(AUXDeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.suitType == AUXDeviceSuitTypeGateway) {
            [gatewayArray addObject:obj];
        }
    }];
    [self.deviceInfoArray removeObjectsInArray:gatewayArray];
    
    NSArray *deviceidArray = [self.deviceInfoArray valueForKeyPath:@"deviceId"];
    for (NSString *deviceid in self.selectedArray) {
        if (![deviceidArray containsObject:deviceid]) {
            [removeArray addObject:deviceid];
        }
    }
    
    
    [self.selectedArray removeObjectsInArray:removeArray];
    
    [AUXArchiveTool saveDataByNSFileManager:self.selectedArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
 





@end
