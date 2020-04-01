//
//  AUXTodayExtensionViewController.m
//  AUXTodayExtension
//
//  Created by 奥克斯家研--张海昌 on 2018/5/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTodayExtensionViewController.h"
#import "AUXTodayExtensionTableViewCell.h"
#import "AUXTodayExensionNoDeviceTableViewCell.h"
#import "AUXTodayExtensionFooterView.h"
#import <NotificationCenter/NotificationCenter.h>

#import "AUXArchiveTool.h"
#import "AUXUser.h"
#import "AUXNetworkManager.h"
#import "AUXDeviceInfo.h"
#import "AUXDeviceDiscoverManager.h"
#import "AUXDeviceListViewModel.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import <MBProgressHUD.h>

#define kWidgetWidth [UIScreen mainScreen].bounds.size.width

@interface AUXTodayExtensionViewController () <NCWidgetProviding , UITableViewDelegate , UITableViewDataSource , AUXDeviceListViewModelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) BOOL shouldAddDevice;
@property (nonatomic,assign) BOOL shouldAgainLogin;
@property (nonatomic,assign) BOOL shouldLoginIn;
@property (nonatomic, strong, readonly) NSArray<AUXDeviceInfo *> *deviceInfoArray;    // 设备列表
@property (nonatomic, strong, readonly) NSDictionary<NSString *, AUXACDevice *> *deviceDictionary;  // 设备字典 (key为 deviceId)
@property (nonatomic,strong) NSArray *selectedArray;
@property (nonatomic,strong) NSMutableArray *selectedDeviceInfoArray;
@property (nonatomic,strong) NSMutableArray *lastSelectedDeviceInfoArray;

@property (nonatomic,strong) AUXDeviceListViewModel *deviceListViewModel;

@property (nonatomic,strong) MBProgressHUD *progressHUD;
@property (nonatomic,strong) MBProgressHUD *transparentProgressHUD;
@property (nonatomic,assign) BOOL showLoading;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation AUXTodayExtensionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AUXArchiveTool setShouldShowNotificationControlGuidePage:NO];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidgetWidth, 1)];
    [self.tableView registerHeaderFooterViewWithNibName:@"AUXTodayExtensionFooterView"];
    
    self.shouldLoginIn = NO;
    self.shouldAddDevice = NO;
    self.shouldAgainLogin = NO;
    self.showLoading = NO;
    
    [self mainLoad];
    
    if (self.selectedArray.count == 0) {
        self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(repeatLoad) userInfo:nil repeats:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AUXUser *user = [AUXUser defaultUser];
    AUXUser *unarchiveUser = [AUXUser unarchiveUser];
    
    user.uid = unarchiveUser.uid;
    user.token = unarchiveUser.token;
    user.accessToken = unarchiveUser.accessToken;
    
    if (user.uid && user.token) {
        if (self.selectedArray.count == 0) {
            [self noDevice];
        } else {
            AUXDeviceListViewModel *deviceViewModel = [[AUXDeviceListViewModel alloc]init];
            deviceViewModel.delegate = self;
            self.deviceListViewModel = deviceViewModel;
            [self.deviceListViewModel requestDeviceList];
        }
    }else {
        [self shouldLogin];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [GizWifiSDK updatePortStatus:GizReleasePort];
 
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [GizWifiSDK updatePortStatus:GizReleasePort];
}

- (void)updateTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)repeatLoad {
    [self mainLoad];
    [self performSelector:@selector(viewWillAppear:) withObject:nil afterDelay:0.2];
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)mainLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectedArray = [AUXArchiveTool readDataByNSFileManager];
        if ([[self.extensionContext valueForKey:@"widgetActiveDisplayMode"] intValue] == 0) {
            [self setRetract];
            self.preferredContentSize = CGSizeMake(kWidgetWidth, 110);
        } else {
            [self setExpand];
            self.preferredContentSize = CGSizeMake(kWidgetWidth, self.selectedArray.count * 110 + 50);
        }
    });
}

#pragma mark 设置widget的展开和折叠状态，使用KVC为了兼容ios8
- (void)setExpand {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.extensionContext setValue:@"1" forKey:@"widgetLargestAvailableDisplayMode"];
    });
}

- (void)setRetract {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.extensionContext setValue:@"0" forKey:@"widgetLargestAvailableDisplayMode"];
    });
}

- (void)shouldLogin {
    self.shouldLoginIn = YES;
    self.shouldAddDevice = NO;
    self.shouldAgainLogin = NO;
    
    [self setRetract];
    [self.tableView registerCellWithNibName:@"AUXTodayExensionNoDeviceTableViewCell"];
    
    [self updateTableView];
}

- (void)noDevice {
    self.shouldAddDevice = YES;
    self.shouldAgainLogin = NO;
    self.shouldLoginIn = NO;
    
    [self setRetract];
    [self.tableView registerCellWithNibName:@"AUXTodayExensionNoDeviceTableViewCell"];
    
    [self updateTableView];
}

- (void)haveDevice {
    self.shouldAddDevice = NO;
    self.shouldAgainLogin = NO;
    self.shouldLoginIn = NO;
    
    [self setExpand];
    [self.tableView registerCellWithNibName:@"AUXTodayExtensionTableViewCell"];
    
    [self updateTableView];
    
}

#pragma mark AUXDeviceListViewModelDelegate
- (void)viewModelDelegateOfGetDeviceListStatus:(NSError *)error {
    switch (error.code) {
        case AUXNetworkErrorNone:
            [self dealWithDeviceInfoList];
            break;
            
        case AUXNetworkErrorAccountCacheExpired:
            [self shouldLogin];
            break;
            
        default:
            break;
    }
}

- (void)viewModelDelegateOfRefrashDeviceStatus {
    [self haveDevice];
}

#pragma mark 处理设备列表
- (void)dealWithDeviceInfoList {
    
    if (self.deviceInfoArray.count > 0 && self.selectedArray.count > 0) {
        self.selectedDeviceInfoArray = [NSMutableArray array];
        for (AUXDeviceInfo *deviceInfo in self.deviceInfoArray) {
            if ([self.selectedArray containsObject:deviceInfo.deviceId]) {
                if (deviceInfo) {
                    [self.selectedDeviceInfoArray addObject:deviceInfo];
                }
            }
        }
    }
    
    if (self.selectedDeviceInfoArray.count > 0) {
        [self haveDevice];
    } else {
        [self noDevice];
    }
    
}

#pragma mark atcion
- (void)pushMainAppWithTag:(AUXExtensionPushToMainAppType)toMainType indexPath:(NSIndexPath *)indexPath{
    AUXDeviceInfo *deviceInfo;
    if (indexPath) {
        deviceInfo = self.selectedDeviceInfoArray[indexPath.row];
    }
    
    NSString *urlString;
    
    switch (toMainType) {
        case AUXExtensionPushToMainAppTypeOfLogin:
            urlString = @"AUXTodayExtension://shouldLogin";
            break;
        case AUXExtensionPushToMainAppTypeOfAddDevice:
            urlString = @"AUXTodayExtension://addDevice";
            break;
        case AUXExtensionPushToMainAppTypeOfDeviceList:
            urlString = @"AUXTodayExtension://deviceList";
            break;
        case AUXExtensionPushToMainAppTypeOfDeviceController:
            urlString = [NSString stringWithFormat:@"AUXTodayExtension://deviceController?%@" , deviceInfo.deviceId];
            break;
        default:
            break;
    }
    [GizWifiSDK updatePortStatus:GizReleasePort];
    
    [self.extensionContext openURL:[NSURL URLWithString:urlString] completionHandler:nil];
}

- (void)pushToMainAppAddDevice:(UITapGestureRecognizer *)tap {
    [self pushMainAppWithTag:AUXExtensionPushToMainAppTypeOfAddDevice indexPath:nil];
}

#pragma mark UITableViewDelegate , UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.shouldAddDevice || self.shouldLoginIn || self.shouldAgainLogin) {
        return 1;
    } else {
        return self.selectedDeviceInfoArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shouldAddDevice || self.shouldLoginIn  || self.shouldAgainLogin) {
        AUXTodayExensionNoDeviceTableViewCell *noDeviceCell = [tableView dequeueReusableCellWithIdentifier:@"noDeviceCell"];
        
        noDeviceCell.shouldLogin = self.shouldLoginIn;
        noDeviceCell.shouldAddDevice = self.shouldAddDevice;
        noDeviceCell.shouldAgainLogin = self.shouldAgainLogin;
        
        noDeviceCell.cellTapAtcion = ^(AUXExtensionPushToMainAppType toMainAppType) {
            [self pushMainAppWithTag:toMainAppType indexPath:nil];
        };
        
        return noDeviceCell;
    } else {
        AUXTodayExtensionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodayExtensionCell"];
        
        int index = (int)indexPath.row;
        AUXDeviceInfo *deviceInfo = (AUXDeviceInfo *)self.selectedDeviceInfoArray[index];
        cell.deviceInfo = deviceInfo;
        
        cell.deviceTap = ^(BOOL isOffLine) {
            if (isOffLine) {
                [self showLoadingHUDWithText:@"设备不在线"];
            } else {
                [self pushMainAppWithTag:AUXExtensionPushToMainAppTypeOfDeviceController indexPath:indexPath];
            }
        };
        
        cell.sendControlError = ^(NSString *errorText) {
            [self showLoadingHUDWithText:errorText];
        };
        
        cell.showLoadingBlock = ^{
            [self showLoadingHUD];
        };
        
        cell.hideLoadingBlock = ^{
            [self hideProgressHUD];
        };
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    if ([[self.extensionContext valueForKey:@"widgetActiveDisplayMode"] intValue] == 0 || self.selectedDeviceInfoArray.count == 0) {
        return [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidgetWidth, 1)];
    } else {
        AUXTodayExtensionFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AUXTodayExtensionFooterView"];
        footerView.titleLabel.layer.masksToBounds = YES;
        footerView.titleLabel.layer.borderColor = [[[UIColor colorWithHexString:@"121212"] colorWithAlphaComponent:0.3] CGColor];
        
        [footerView.titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToMainAppAddDevice:)]];
        
        return footerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if ([[self.extensionContext valueForKey:@"widgetActiveDisplayMode"] intValue] == 0 || self.selectedDeviceInfoArray.count == 0)  {
        return 1;
    } else {
        return 50;
    }
    
}

#pragma mark LoadingHUD
- (void)showLoadingHUDWithText:(NSString *)text {
    
    if (!self.progressHUD) {
        MBProgressHUD *progressHUD;
        
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        progressHUD.bezelView.color = [UIColor whiteColor];
        progressHUD.contentColor = [UIColor blackColor];
        progressHUD.minSize = CGSizeMake(230, 100);
        progressHUD.removeFromSuperViewOnHide = NO;
        self.progressHUD = progressHUD;
    } else {
        [self.progressHUD showAnimated:YES];
    }
    
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.label.text = text;
    self.progressHUD.label.numberOfLines = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoadingTextHUD];
    });
}

- (void)hideLoadingTextHUD {
    if (self.progressHUD) {
        [self.progressHUD hideAnimated:YES];
    }
}

- (void)showLoadingHUD {
    if (!self.transparentProgressHUD) {
        MBProgressHUD *progressHUD;
        
        progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progressHUD.backgroundView.backgroundColor = [UIColor clearColor];
        progressHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        progressHUD.bezelView.color = [UIColor whiteColor];
        progressHUD.contentColor = [UIColor blackColor];
        progressHUD.minSize = CGSizeMake(50, 50);
        progressHUD.removeFromSuperViewOnHide = NO;
        
        progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.transparentProgressHUD = progressHUD;
    } else {
        [self.transparentProgressHUD showAnimated:YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (self.transparentProgressHUD) {
        [self.transparentProgressHUD hideAnimated:YES];
    }
}

#pragma mark getters
- (NSArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSArray array];
    }
    return _selectedArray;
}

- (NSArray<AUXDeviceInfo *> *)deviceInfoArray {
    return self.deviceListViewModel.deviceInfoArray;
}

- (NSDictionary<NSString *, AUXACDevice *> *)deviceDictionary {
    return [AUXUser defaultUser].deviceDictionary;
}

#pragma mark widgetDelegate

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {

    completionHandler(NCUpdateResultNewData);
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize  API_AVAILABLE(ios(10.0)){
    if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        self.preferredContentSize = CGSizeMake(kWidgetWidth, self.selectedArray.count * 110 + 50);
    }else{
        self.preferredContentSize = CGSizeMake(kWidgetWidth, 110);
    }
    
    [self updateTableView];
}



@end
