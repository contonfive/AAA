//
//  AUXSleepDIYTypeViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/28.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepDIYTypeViewController.h"
#import "AUXSleepDIYTimeViewController.h"

#import "AUXSubtitleTableViewCell.h"
#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXSleepDIYTypeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AUXSleepDIYTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXSubtitleTableViewCell"];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
}

- (void)createSleepDIYModel {
    self.sleepDIYModel = [[AUXSleepDIYModel alloc] init];
    self.sleepDIYModel.mode = self.mode;
    self.sleepDIYModel.windSpeed = AUXServerWindSpeedLow;
    self.sleepDIYModel.on = NO;    // 睡眠DIY默认关闭
    
    if (self.deviceInfo.virtualDevice) {
        self.oldDevice = YES;
    }
    
    if (self.oldDevice) {
        self.sleepDIYModel.deviceManufacturer = 0;
    } else {
        self.sleepDIYModel.deviceManufacturer = 1;
        
        // 新设备的开始时间默认为 23:00
        self.sleepDIYModel.startHour = 23;
        self.sleepDIYModel.endHour = 9;
    }
    
    // 创建睡眠DIY的节点
    NSMutableArray<AUXSleepDIYPointModel *> *pointArray = [[NSMutableArray alloc] init];
    
    // 默认的制冷、制热节点数据
    NSArray<NSDictionary *> *sleepDIYDataArray;
    
    switch (self.mode) {
        case AUXServerDeviceModeCool:
            sleepDIYDataArray = [self defaultCoolSleepDIYDataArray];
            break;
            
        case AUXServerDeviceModeHeat:
        default:
            sleepDIYDataArray = [self defaultHeatSleepDIYDataArray];
            break;
    }
    
    [sleepDIYDataArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        AUXSleepDIYPointModel *pointModel = [AUXSleepDIYPointModel yy_modelWithDictionary:obj];
        [pointArray addObject:pointModel];
    }];
    
    self.sleepDIYModel.definiteTime = pointArray.count;
    self.sleepDIYModel.pointModelList = pointArray;
    self.sleepDIYModel.smart = YES;
    
    [self updatePointModelHour];
}

- (void)updatePointModelHour {
    // 旧设备没有开始时间，pointModel.hour 从0开始累加
    AUXIndexToHourBlock indexToOldHour = ^ (NSInteger index, NSInteger startHour) {
        return index;
    };
    
    // 新设备有开始时间，pointModel.hour 从开始时间开始累加
    AUXIndexToHourBlock indexToNewHour = ^ (NSInteger index, NSInteger startHour) {
        return (startHour + index) % 24;
    };
    
    AUXIndexToHourBlock indexToHour;
    
    NSInteger startHour = 0;
    
    if (self.oldDevice) {
        indexToHour = indexToOldHour;
    } else {
        indexToHour = indexToNewHour;
        startHour = self.sleepDIYModel.startHour;
    }
    
    [self.sleepDIYModel.pointModelList enumerateObjectsUsingBlock:^(AUXSleepDIYPointModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hour = indexToHour(idx, startHour);
    }];
}

/// 默认的制冷睡眠DIY
- (NSArray<NSDictionary *> *)defaultCoolSleepDIYDataArray {
    return @[@{@"temperature": @26, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @27, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @28, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @28, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @28, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @28, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @28, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @27, @"windSpeed": @(AUXServerWindSpeedLow)}];
}
/// 默认的制热睡眠DIY
- (NSArray<NSDictionary *> *)defaultHeatSleepDIYDataArray {
    return @[@{@"temperature": @26, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @25, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @24, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @24, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @24, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @24, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @24, @"windSpeed": @(AUXServerWindSpeedLow)},
             @{@"temperature": @25, @"windSpeed": @(AUXServerWindSpeedLow)}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AUXSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSubtitleTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.iconImageView.image = [UIImage imageNamed:@"device_btn_cold"];
        cell.titleLabel.text = @"制冷睡眠DIY";
        cell.bottomView.hidden = NO;
    } else {
        cell.iconImageView.image = [UIImage imageNamed:@"device_btn_hot"];
        cell.titleLabel.text = @"制热睡眠DIY";
    }
    
    cell.showsIconImage = YES;
    cell.showsIndicator = YES;
    cell.subtitleLabel.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AUXServerDeviceMode mode = AUXServerDeviceModeCool;
    
    if (indexPath.row == 0) {
        mode = AUXServerDeviceModeCool;
    } else {
        mode = AUXServerDeviceModeHeat;
    }
    
    if (mode == AUXServerDeviceModeHeat && self.deviceInfo.deviceFeature.coolOnly) {
        [self showErrorViewWithMessage:@"该设备不支持制热模式"];
        return;
    }
    
    self.mode = mode;
    [self createSleepDIYModel];
    
    if (self.sleepDIYModel) {
        [self pushSleepDIYEditViewControllerWithMode:mode addSleepDIY:YES sleepDIYModel:self.sleepDIYModel];
    }
    
}

// 跳转到 睡眠DIY编辑/添加界面
- (void)pushSleepDIYEditViewControllerWithMode:(AUXServerDeviceMode)mode addSleepDIY:(BOOL)addSleepDIY sleepDIYModel:(AUXSleepDIYModel *)sleepDIYModel {
    
    if (addSleepDIY) {
        AUXSleepDIYTimeViewController *sleepDIYTimeViewController = [AUXSleepDIYTimeViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        sleepDIYTimeViewController.mode = mode;
        sleepDIYTimeViewController.addSleepDIY = addSleepDIY;
        sleepDIYTimeViewController.deviceInfo = self.deviceInfo;
        sleepDIYTimeViewController.sleepDIYModel = sleepDIYModel;
        sleepDIYTimeViewController.existedModelList = self.existedModelList;
        sleepDIYTimeViewController.controlType = self.controlType;
        sleepDIYTimeViewController.deviceFeature = self.deviceFeature;
        sleepDIYTimeViewController.oldDevice = self.oldDevice;
        [self.navigationController pushViewController:sleepDIYTimeViewController animated:YES];
    }
}

@end
