//
//  AUXOTAViewController.m
//  AUXSmartHome
//
//  Created by 陈凯 on 31/01/2018.
//  Copyright © 2018 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXOTAViewController.h"
//#import "AUXUpgradeTableViewCell.h"
//#import "AUXUser.h"
//#import "AUXTimerObject.h"
////#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AUXOTAViewController () <QMUINavigationControllerDelegate, AUXACDeviceProtocol>

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
//
//@property (nonatomic, strong) UIRefreshControl *refreshControl;
//
//@property (retain, nonatomic) NSMutableArray *deviceArray;
//@property (retain, nonatomic) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
//@property (retain, nonatomic) dispatch_queue_t versionInfoUpdateQueue;
//
//@property (assign, nonatomic) int searchCount;
//@property (assign, nonatomic) int maxUpgradingTime;
//@property (assign, nonatomic) BOOL upgrading;
//@property (assign, nonatomic) NSTimer *timer;
//@property (retain, nonatomic) AUXACDevice *device;

@end

@implementation AUXOTAViewController

//- (void)dealloc {
//    [self.timer invalidate];
//    self.timer = nil;
//}
//
//- (IBAction)upgradeDevice:(UIButton *)sender forEvent:(UIEvent *)event {
//    UITouch *touch = event.allTouches.allObjects.firstObject;
//    NSIndexPath *indexPath = [self.otaTableView indexPathForRowAtPoint:[touch locationInView:self.otaTableView]];
//
//    [self showLoadingHUD];
//    self.device = [self.deviceInfoArray objectAtIndex:indexPath.row].device;
//    [AUXACNetwork.sharedInstance updateFirmwareForDevice:self.device];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.upgrading = NO;
//    self.deviceArray = [[NSMutableArray alloc] init];
//    self.versionInfoUpdateQueue = dispatch_queue_create([@"com.auxgroup.smarthome.otainfo" UTF8String], DISPATCH_QUEUE_SERIAL);
//
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.otaTableView addSubview:self.refreshControl];
//    [self.refreshControl addTarget:self action:@selector(reloadDeviceVersionTable) forControlEvents:UIControlEventValueChanged];
//
//    for (AUXDeviceInfo *deviceInfo in AUXUser.defaultUser.deviceInfoArray) {
//        // 仅提供古北云20010固件局域网下设备升级
//        AUXACDevice *device = [AUXACDeviceManager.sharedInstance containDeviceWithMac:deviceInfo.mac];
//        if (device.deviceType == AUXACNetworkDeviceWifiTypeBL && [@"20010" isEqualToString:device.bLDevice.type] && device.isLan) {
//            [self.deviceArray addObject:device];
//            [device.delegates addObject:self];
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    
//    [self.refreshControl beginRefreshing];
//    [self reloadDeviceVersionTable];
}

//- (void)reloadDeviceVersionTable {
//    self.searchCount = 0;
//    self.deviceInfoArray = [[NSMutableArray alloc] init];
//    for (AUXACDevice *device in self.deviceArray) {
//        self.searchCount++;
//        self.device = device;
//        [self getFirmwareVersion];
//    }
//    if (self.searchCount == 0) {
//        [self.refreshControl endRefreshing];
//    }
//}
//
//- (void)getFirmwareVersion {
//    [AUXACNetwork.sharedInstance getFirmwareVersionForDevice:self.device];
//}
//
//- (void)auxACNetworkDidGetFirmwareVersionForDevice:(AUXACDevice *)device firmwareVersion:(int)firmwareVersion success:(BOOL)success withError:(NSError *)error {
//    if (self.upgrading) {
//        self.maxUpgradingTime--;
//        BOOL finish = NO;
//        if (success && firmwareVersion >= 10027) {
//            finish = YES;
//        }
//        if (!finish && self.maxUpgradingTime < 1) {
//            finish = YES;
//        }
//        if (finish) {
//            self.upgrading = NO;
//            [self.timer invalidate];
//            self.timer = nil;
//
//            if (success && firmwareVersion >= 10027) {
//                [self showSuccess:@"升级成功"];
//                for (int i = 0; i < self.deviceInfoArray.count; i++) {
//                    if ([[self.deviceInfoArray objectAtIndex:i].mac isEqualToString:[device getMac]]) {
//                        [self.deviceInfoArray removeObjectAtIndex:i];
//                        [self.otaTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                        break;
//                    }
//                }
//            } else {
//                [self showErrorViewWithMessage:@"升级失败"];
//                [self hideLoadingHUD];
//            }
//        }
//    } else {
//        @weakify(self)
//        dispatch_async(self.versionInfoUpdateQueue, ^{
//            @strongify(self)
//            if (success) {
//                if (firmwareVersion < 10027) {
//                    for (AUXDeviceInfo *storageDeviceInfo in AUXUser.defaultUser.deviceInfoArray) {
//                        if ([storageDeviceInfo.mac isEqualToString:[device getMac]]) {
//                            AUXDeviceInfo *deviceInfo = [[AUXDeviceInfo alloc] init];
//                            deviceInfo.mac = storageDeviceInfo.mac;
//                            deviceInfo.alias = storageDeviceInfo.alias;
//                            deviceInfo.deviceMainUri = storageDeviceInfo.deviceMainUri;
//                            deviceInfo.device = device;
//                            [self.deviceInfoArray addObject:deviceInfo];
//                        }
//                    }
//                }
//            }
//            self.searchCount--;
//            if (self.searchCount == 0) {
//                @weakify(self)
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    @strongify(self)
//                    [self.otaTableView reloadData];
//                    [self.refreshControl endRefreshing];
//                });
//            }
//        });
//    }
//}
//
//- (void)auxACNetworkDidUpdateFirmwareForDevice:(AUXACDevice *)device success:(BOOL)success withError:(NSError *)error {
//    // 返回错误，设备仍有可能执行升级操作
////    if (success) {
//        self.upgrading = YES;
//        self.maxUpgradingTime = 60;
//        self.timer = [AUXTimerObject scheduledWeakTimerWithTimeInterval:3 target:self selector:@selector(getFirmwareVersion) userInfo:nil repeats:YES];
////    } else {
////        [self hideLoadingHUD];
////        [self showErrorViewWithMessage:@"升级失败"];
////    }
//}
//
//#pragma mark - QMUINavigationControllerDelegate
//
//- (BOOL)shouldSetStatusBarStyleLight {
//    return YES;
//}
//
//- (BOOL)preferredNavigationBarHidden {
//    return NO;
//}
//
//- (UIImage *)navigationBarBackgroundImage {
//    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
//}
//
//- (UIImage *)navigationBarShadowImage {
//    return [UIImage qmui_imageWithColor:[UIColor clearColor]];
//}
//
//- (UIColor *)navigationBarTintColor {
//    return [UIColor whiteColor];
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.deviceInfoArray.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 90;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    AUXUpgradeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upgradingCell" forIndexPath:indexPath];
//
//    AUXDeviceInfo *deviceInfo = [self.deviceInfoArray objectAtIndex:indexPath.row];
//    [cell.airconImageView sd_setImageWithURL:[NSURL URLWithString:deviceInfo.deviceMainUri] placeholderImage:nil options:SDWebImageRefreshCached];
//    cell.airconAliasLabel.text = deviceInfo.alias;
//
//    return cell;
//}

@end
