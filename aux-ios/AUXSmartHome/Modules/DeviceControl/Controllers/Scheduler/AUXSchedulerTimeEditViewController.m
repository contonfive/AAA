//
//  AUXSchedulerTimeEditViewController.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSchedulerTimeEditViewController.h"
#import "AUXSchedulerDeviceEditViewController.h"
#import "AUXTimePickerTableViewCell.h"
#import "AUXSchedulerCycleTableViewCell.h"

#import "UITableView+AUXCustom.h"
#import "NSError+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXConfiguration.h"
#import "AUXNetworkManager.h"

@interface AUXSchedulerTimeEditViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic,assign) BOOL showEntireCycleView;
@end

@implementation AUXSchedulerTimeEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.addScheduler) {
        // 新增定时，创建默认数据
        [self creatScheduler];
    } else {
        self.navigationController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.tableView registerCellWithNibName:@"AUXTimePickerTableViewCell"];
    [self.tableView registerCellWithNibName:@"AUXSchedulerCycleTableViewCell"];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kAUXScreenWidth, 12)];
    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
}

/// 创建默认的定时
- (void)creatScheduler {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components: NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    
    _schedulerModel = [[AUXSchedulerModel alloc] init];
    _schedulerModel.schedulerId = @"-1";
    _schedulerModel.deviceOperate = 1;
    _schedulerModel.mode = AUXServerDeviceModeCool;
    _schedulerModel.windSpeed = AUXServerWindSpeedLow;
    _schedulerModel.hour = dateComponents.hour;
    _schedulerModel.minute = dateComponents.minute;
    _schedulerModel.temperature = 26;
    _schedulerModel.on = YES;
    _schedulerModel.deviceId = self.deviceInfo.deviceId;

    
    for (int i = 0; i < 7; i++) {
        _schedulerModel.repeatValue |= 1 << i;
    }
    
    unsigned int address = 0;
    
    [[NSScanner scannerWithString:self.address] scanHexInt:&address];
    
    _schedulerModel.dst = address;
}

#pragma mark atcions

- (IBAction)confirmAtcion:(id)sender {
    
    if (AUXWhtherNullString(self.schedulerModel.repeatDescription) || [self.schedulerModel.repeatDescription isEqualToString:@"不重复"]) {
        [self showErrorViewWithMessage:@"请选择重复时间"];
        return ;
    }
    
    if (self.addScheduler) {
        AUXSchedulerDeviceEditViewController *schedulerEditDeviceViewController = [AUXSchedulerDeviceEditViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
        schedulerEditDeviceViewController.deviceInfo = self.deviceInfo;
        schedulerEditDeviceViewController.device = self.device;
        schedulerEditDeviceViewController.address = self.address;
        schedulerEditDeviceViewController.existedSchedulerArray = self.existedSchedulerArray;
        schedulerEditDeviceViewController.addScheduler = self.addScheduler;
        schedulerEditDeviceViewController.schedulerModel = self.schedulerModel;
        schedulerEditDeviceViewController.hardwaretype = self.hardwaretype;
        
        [self.navigationController pushViewController:schedulerEditDeviceViewController animated:YES];
    } else {
        
        if (self.editSuccessBlock) {
            self.editSuccessBlock(self.schedulerModel);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 282;
    } else {
        return 195;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [self tableView:tableView timePickerCellForRowAtIndexPath:indexPath];
    } else {
        cell = [self tableView:tableView cycleCellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

// 时间
- (UITableViewCell *)tableView:(UITableView *)tableView timePickerCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXTimePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXTimePickerTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.hidden = YES;
    [cell selectHour:self.schedulerModel.hour minute:self.schedulerModel.minute animated:NO];
    
    @weakify(self);
    cell.didSelectTimeBlock = ^(NSInteger hour, NSInteger minute) {
        @strongify(self);
        self.schedulerModel.hour = hour;
        self.schedulerModel.minute = minute;
    };
    
    cell.bottomView.hidden = NO;
    
    return cell;
}

// 周期
- (UITableViewCell *)tableView:(UITableView *)tableView cycleCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUXSchedulerCycleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSchedulerCycleTableViewCell" forIndexPath:indexPath];
    
    cell.multiSelection = YES;
    cell.selectsOneAtLeast = YES;
    
    for (AUXChooseButton *btn in cell.cycleBtnsCollection) {
        
        if ([btn.titleLabel.text isEqualToString:self.schedulerModel.repeatDescription]) {
            btn.selected = YES;
            break;
        }
    }
    
    if ([self.schedulerModel.repeatDescription containsString:@" "] || [self.schedulerModel.repeatDescription containsString:@"、"] || [self.schedulerModel.repeatDescription containsString:@"周"]) {
        AUXChooseButton *btn = [cell.cycleBtnsCollection lastObject];
        btn.selected = YES;
        cell.customDayView.hidden = NO;
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (int i = 0; i < 7; i++) {
            if ((self.schedulerModel.repeatValue & 1 << i) != 0) {
                [indexSet addIndex:i];
            }
        }
        
        [cell selectsButtonsAtIndexes:indexSet];
    }
    
    @weakify(self);
    cell.didSelectBlock = ^(NSInteger index) {
        @strongify(self);
        self.schedulerModel.repeatValue |= (1 << index);
    };
    
    cell.didDeselectBlock = ^(NSInteger index) {
        @strongify(self);
        self.schedulerModel.repeatValue ^= (1 << index);
    };
    
    @weakify(cell);
    cell.cycleBtnDidSlectedBlcok = ^(NSInteger tag) {
        @strongify(self , cell);
        switch (tag) {
            case 0:{ //每天
                for (int i = 0; i < 7; i++) {
                    self.schedulerModel.repeatValue |= (1 << i);
                }
                break;
            }
            case 1:{ //双休日
                for (int i = 0; i < 7; i++) {
                    self.schedulerModel.repeatValue = self.schedulerModel.repeatValue & (0 << i);
                }
                self.schedulerModel.repeatValue |= (1 << 5);
                self.schedulerModel.repeatValue |= (1 << 6);
                break;
            }
            case 2:{ // 工作日
                for (int i = 0; i < 7; i++) {
                    self.schedulerModel.repeatValue = self.schedulerModel.repeatValue & (0 << i);
                }
                for (int i = 0; i < 5; i++) {
                    self.schedulerModel.repeatValue |= (1 << i);
                }
                break;
            }

            case 3: {   //自定义
                
                for (int i = 0; i < 7; i++) {
                    self.schedulerModel.repeatValue = self.schedulerModel.repeatValue & (0 << i);
                }
            }
                
                break;
            default:
                break;
        }
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
