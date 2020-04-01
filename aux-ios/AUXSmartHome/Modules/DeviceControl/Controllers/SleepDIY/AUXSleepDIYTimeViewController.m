//
//  AUXSleepDIYTimeViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/13.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSleepDIYTimeViewController.h"
#import "AUXSleepDIYDeviceSetViewController.h"

#import "AUXTimePeriodPickerTableViewCell.h"
#import "AUXPeakVallyFooterView.h"

#import "UITableView+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXSleepDIYTimeViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) AUXTimePeriodPickerTableViewCell *pickerCell;
@end

@implementation AUXSleepDIYTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerCellWithNibName:@"AUXTimePeriodPickerTableViewCell"];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];

}

#pragma mark atcion
- (IBAction)sureAtcion:(id)sender {
    
    if (self.sleepDIYModel.deviceManufacturer == 1) {
        NSInteger startHour = self.sleepDIYModel.startHour;
        NSInteger endHour = self.sleepDIYModel.endHour;
        BOOL result = NO;
        
        if (endHour > startHour) {
            if (endHour > startHour + 12) {
                result = YES;
            } else if (endHour <= startHour + 12) {
                result = NO;
                self.sleepDIYModel.definiteTime = endHour - startHour;
            }
        } else if (endHour < startHour) {
            if (startHour + 12 < 24) {
                result = YES;
            } else if (startHour + 12 >= 24) {
                if (endHour > (startHour + 12) % 24) {
                    result = YES;
                } else if (endHour <= (startHour + 12) % 24) {
                    result = NO;
                    self.sleepDIYModel.definiteTime = endHour + (24 - startHour);
                }
            }
        }
        
        if (result) { // 判断当前设置的开始结束时间是否超过12小时
            [self showErrorViewWithMessage:@"睡眠DIY时间最大设置12小时"];
            return ;
        }
        
        if (startHour == endHour) {
            [self showErrorViewWithMessage:@"睡眠DIY开始时间不能等于结束时间"];
            return ;
        }
    } else {
        
        [self.pickerCell pickerView:self.pickerCell.startPickerView didSelectRow:self.pickerCell.startHourRow inComponent:0];
        
    }
    
    if (self.addSleepDIY) {
        AUXSleepDIYDeviceSetViewController *sleepDIYDeviceSetVC = [AUXSleepDIYDeviceSetViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        sleepDIYDeviceSetVC.mode = self.mode;
        sleepDIYDeviceSetVC.addSleepDIY = self.addSleepDIY;
        sleepDIYDeviceSetVC.deviceInfo = self.deviceInfo;
        sleepDIYDeviceSetVC.sleepDIYModel = self.sleepDIYModel;
        sleepDIYDeviceSetVC.existedModelList = self.existedModelList;
        sleepDIYDeviceSetVC.controlType = self.controlType;
        sleepDIYDeviceSetVC.deviceFeature = self.deviceFeature;
        sleepDIYDeviceSetVC.oldDevice = self.oldDevice;
        [self.navigationController pushViewController:sleepDIYDeviceSetVC animated:YES];
    } else {
        if (self.editSuccessBlock) {
            self.editSuccessBlock(self.sleepDIYModel);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 282;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (!self.oldDevice) {
        return nil;
    }
    
    AUXPeakVallyFooterView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"AUXPeakVallyFooterView" owner:nil options:nil] firstObject];
    footerView.contentLabel.text = @"从睡眠DIY开启后开始计算";
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXTimePeriodPickerTableViewCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:@"AUXTimePeriodPickerTableViewCell" forIndexPath:indexPath];
    self.pickerCell = pickerCell;
    
    pickerCell.titleLabel.hidden = YES;
    
    if (self.sleepDIYModel.deviceManufacturer == 0) {
        pickerCell.onlyShowStartPickView = YES;
    }
    
    pickerCell.pickerType = AUXTimePeriodPickerTypeOfSleepDIY;
    
    if (pickerCell.pickViewTop.constant != -30) {
        pickerCell.pickViewTop.constant = -30;
        [pickerCell setNeedsDisplay];
    }
    
    if (self.sleepDIYModel.deviceManufacturer == 0) {
        [pickerCell selectStartHour:self.sleepDIYModel.definiteTime animated:NO];
    } else {

        [pickerCell selectStartHour:self.sleepDIYModel.startHour animated:NO];
        [pickerCell selectEndHour:self.sleepDIYModel.endHour animated:NO];
    }
    
    @weakify(self);
    pickerCell.didSelectTimeBlock = ^(NSInteger startHour, NSInteger startMinute, NSInteger endHour, NSInteger endMinute) {
        @strongify(self);
        
        if (self.sleepDIYModel.deviceManufacturer == 0) {
            self.sleepDIYModel.definiteTime = startHour;
        } else {
            self.sleepDIYModel.startHour = startHour;
            self.sleepDIYModel.startMinute = startMinute;
            self.sleepDIYModel.endHour = endHour;
            self.sleepDIYModel.endMinute = endMinute;
            
        }
        
    };

    return pickerCell;
}

@end
