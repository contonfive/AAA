/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXElectricityConsumptionCurveViewController.h"
#import "AUXElectricityConsumptionCurveChildViewController.h"
#import "AUXDatePickerPopupViewController.h"

#import "AUXChooseButton.h"
#import "AUXElectricityWaveCollectionViewCell.h"

#import "UIColor+AUXCustom.h"
#import "NSDate+AUXCustom.h"
#import "UILabel+AUXCustom.h"
#import "AUXDefinitions.h"
#import "AUXNetworkManager.h"
#import "AUXConfiguration.h"


static NSString * const AUXECYearFormatterString = @"yyyy年";
static NSString * const AUXECMonthFormatterString = @"yyyy年M月";
static NSString * const AUXECDayFormatterString = @"yyyy年M月d日";


@interface AUXElectricityConsumptionCurveViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, QMUINavigationControllerDelegate>

// 日期类型 (日、月、年)
@property (weak, nonatomic) IBOutlet UIView *dateTypeView;
@property (weak, nonatomic) IBOutlet AUXChooseButton *dayButton;   // 日
@property (weak, nonatomic) IBOutlet AUXChooseButton *monthButton; // 月
@property (weak, nonatomic) IBOutlet AUXChooseButton *yearButton;  // 年
@property (strong, nonatomic) IBOutletCollection(AUXChooseButton) NSArray *dateTypeButtonCollection;

// 日期
@property (weak, nonatomic) IBOutlet UIView *dateView;
// (不直接使用button.titleLabel的原因是，button设置title时会闪动一下。)
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;        // 日期
@property (weak, nonatomic) IBOutlet UIButton *dateButton;      // 选择日期
@property (weak, nonatomic) IBOutlet UIButton *dateLeftButton;  // 上一个日期
@property (weak, nonatomic) IBOutlet UIButton *dateRightButton; // 下一个日期

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// 手机当前的日期
@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger currentMonth;
@property (nonatomic, assign) NSInteger currentDay;
@property (nonatomic, assign) NSInteger currentHour;

// 可供选择的最小的日期
@property (nonatomic, assign) NSInteger minYear;
@property (nonatomic, assign) NSInteger minMonth;
@property (nonatomic, assign) NSInteger minDay;

@property (nonatomic, assign) AUXDeviceSource deviceSource;

// 底部总用电量
@property (weak, nonatomic) IBOutlet UIView *bottomConsumptionView;
@property (weak, nonatomic) IBOutlet UILabel *bottomConsumptionLabel;   // 总用电量
@property (weak, nonatomic) IBOutlet UILabel *bottomIndicateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomUnitLabel;      // 单位
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *waveCollectionView;  // 波平、波峰、波谷总用电量

@property (weak, nonatomic) IBOutlet UIView *curveContainerView;    // 曲线图
@property (nonatomic, weak) AUXElectricityConsumptionCurveChildViewController *curveChildViewController;

@property (nonatomic, strong) AUXElectricityConsumptionCurveModel *curveModel;

@property (nonatomic, strong) NSArray<NSNumber *> *waveTypeArray;

@end

@implementation AUXElectricityConsumptionCurveViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    _currentDateType = AUXElectricityCurveDateTypeDay;
    
    _curveModel = [[AUXElectricityConsumptionCurveModel alloc] init];
    _curveModel.dateType = _currentDateType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用电曲线";
    
    // 手机当前的日期
    self.calendar = [NSCalendar currentCalendar];
    self.date = [NSDate date];
    self.dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:self.date];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = AUXECDayFormatterString;
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:self.date];
    self.currentYear = self.dateComponents.year;
    self.currentMonth = self.dateComponents.month;
    self.currentDay = self.dateComponents.day;
    self.currentHour = self.dateComponents.hour;
    
    // 可选择的最小日期
    self.minYear = 2015;
    self.minMonth = 1;
    self.minDay = 1;
    
    self.curveModel.dateType = self.currentDateType;
    self.curveModel.source = self.deviceSource;
    [self.curveModel setCurrentDateWithComponents:self.dateComponents];
    [self.curveModel setRequestDateWithComponents:self.dateComponents];
    
    // 曲线图
    self.curveChildViewController.dateType = self.currentDateType;
    self.curveChildViewController.year = self.currentYear;
    self.curveChildViewController.month = self.currentMonth;
    self.curveChildViewController.day = self.currentDay;
    self.curveChildViewController.source = self.deviceSource;
    
    // 旧设备用电数据不区分波峰波谷
    if (self.deviceSource == AUXDeviceSourceGizwits) {
        self.waveTypeArray = @[@(AUXElectricityCurveWaveTypeNormal), @(AUXElectricityCurveWaveTypeValley), @(AUXElectricityCurveWaveTypePeak)];
    }
    
    [self updateUIWithDateType:self.currentDateType];
    
    [self.instructionLabel setLabelAttributedString:@"仅供参考" color:[UIColor colorWithHexString:@"10BFCA"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getElectricityConsumptionData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"electricityConsumptionCurveSegue"]) {
        self.curveChildViewController = (AUXElectricityConsumptionCurveChildViewController *)segue.destinationViewController;
    }
}

- (void)initSubviews {
    [super initSubviews];
    [self createTitleLabel];
    
    self.dateTypeView.layer.cornerRadius = 6.0;
    
    self.bottomConsumptionLabel.text = @"0";
    self.waveCollectionView.hidden = YES;
}

#pragma mark - Setters & Getters

- (void)setCurrentDateType:(AUXElectricityCurveDateType)currentDateType {
    _currentDateType = currentDateType;
    self.curveModel.dateType = currentDateType;
    self.curveChildViewController.dateType = currentDateType;
}

- (AUXDeviceSource)deviceSource {
    if (self.deviceInfo) {
        return self.deviceInfo.source;
    }
    
    return AUXDeviceSourceGizwits;
}

#pragma mark - Actions

/// 更改日期类型 (日、月、年)
- (IBAction)actionChangeDateType:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    
    switch (sender.tag) {
        case 100:   // 日用电曲线
            self.currentDateType = AUXElectricityCurveDateTypeDay;
            break;
            
        case 101:   // 月用电曲线
            self.currentDateType = AUXElectricityCurveDateTypeMonth;
            break;
            
        default:    // 年用电曲线
            self.currentDateType = AUXElectricityCurveDateTypeYear;
            break;
    }
    
//    if (self.currentDateType != AUXElectricityCurveDateTypeDay) {
//        self.waveCollectionView.hidden = YES;
//    } else {
//        self.waveCollectionView.hidden = NO;
//    }
    
    [self updateUIWithDateType:self.currentDateType];
    
    [self getElectricityConsumptionData];
    
    if (self.didChangeDateTypeBlock) {
        self.didChangeDateTypeBlock(self.currentDateType);
    }
    
    
}

- (void)updateUIWithDateType:(AUXElectricityCurveDateType)dateType {
    
    AUXChooseButton *selectedButton;
    
    switch (dateType) {
        case AUXElectricityCurveDateTypeDay:
            self.dateFormatter.dateFormat = AUXECDayFormatterString;
            self.bottomIndicateLabel.text = @"日用电总量：";
            selectedButton = self.dayButton;
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            self.dateFormatter.dateFormat = AUXECMonthFormatterString;
            self.bottomIndicateLabel.text = @"月用电总量：";
            selectedButton = self.monthButton;
            break;
            
        default:
            self.dateFormatter.dateFormat = AUXECYearFormatterString;
            self.bottomIndicateLabel.text = @"年用电总量：";
            selectedButton = self.yearButton;
            break;
    }
    
    if (self.dateComponents.year == self.currentYear) {
        if (self.dateComponents.month > self.currentMonth) {
            self.dateComponents.month = self.currentMonth;
            self.dateComponents.day = 1;
            self.date = [self.calendar dateFromComponents:self.dateComponents];
        }
    }
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:self.date];
    
    for (AUXChooseButton *button in self.dateTypeButtonCollection) {
        button.selected = [selectedButton isEqual:button];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:[UIColor colorWithHexString:@"F6F6F6"]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"256BBD"] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    }
    
    // 清空当前用电曲线数据
    [self.curveModel clearAllPointModels];
    [self updateCurveView];
}

/// 上一日、上一月、上一年
- (IBAction)actionGetLastDate:(id)sender {
    
    switch (self.currentDateType) {
        case AUXElectricityCurveDateTypeYear: {
            // 上一年
            NSInteger year = self.dateComponents.year;
            
            if (year == self.minYear) {
                break;
            }
            
            year -= 1;
            
            [self didSelectYear:year];
        }
            break;
            
        case AUXElectricityCurveDateTypeMonth: {
            // 上一月
            NSInteger year = self.dateComponents.year;
            NSInteger month = self.dateComponents.month;
            
            if (year == self.minYear && month == self.minMonth) {
                break;
            }
            
            month -= 1;
            
            if (month == 0) {
                month = 12;
                year -= 1;
            }
            
            [self didSelectYear:year month:month];
        }
            break;
            
        default: {
            // 上一日
            NSInteger year = self.dateComponents.year;
            NSInteger month = self.dateComponents.month;
            NSInteger day = self.dateComponents.day;
            
            if (year == self.minYear && month == self.minMonth && day == self.minDay) {
                break;
            }
            
            day -= 1;
            
            if (day == 0) {
                month -= 1;
                
                if (month == 0) {
                    month = 12;
                    year -= 1;
                }
                
                day = [NSDate numberOfDaysInMonth:month forYear:year];
            }
            
            [self didSelectYear:year month:month day:day];
        }
            break;
    }
}

/// 下一日、下一月、下一年
- (IBAction)actionGetNextDate:(id)sender {
    
    switch (self.currentDateType) {
        case AUXElectricityCurveDateTypeYear: {
            // 下一年
            NSInteger year = self.dateComponents.year;
            
            if (year == self.currentYear) {
                break;
            }
            
            year += 1;
            
            [self didSelectYear:year];
        }
            break;
            
        case AUXElectricityCurveDateTypeMonth: {
            // 下一月
            NSInteger year = self.dateComponents.year;
            NSInteger month = self.dateComponents.month;
            
            if (year == self.currentYear && month == self.currentMonth) {
                break;
            }
            
            month += 1;
            
            if (month == 13) {
                month = 1;
                year += 1;
            }
            
            [self didSelectYear:year month:month];
        }
            break;
            
        default: {
            // 下一日
            NSInteger year = self.dateComponents.year;
            NSInteger month = self.dateComponents.month;
            NSInteger day = self.dateComponents.day;
            
            if (year == self.currentYear && month == self.currentMonth && day == self.currentDay) {
                break;
            }
            
            day += 1;
            
            if (day > [NSDate numberOfDaysInMonth:month forYear:year]) {
                month += 1;
                
                if (month == 13) {
                    month = 1;
                    year += 1;
                }
                
                day = 1;
            }
            
            [self didSelectYear:year month:month day:day];
        }
            break;
    }
}

/// 弹出日期 pickerView
- (IBAction)actionSelectDate:(id)sender {
    
    AUXDatePickerPopupViewController *datePickerPopupViewController = [[AUXDatePickerPopupViewController alloc] initWithDateType:self.currentDateType minYear:self.minYear];
    
    datePickerPopupViewController.pickerTitle = @"日期";

    // 这里不用加 break
    switch (self.currentDateType) {
        case AUXElectricityCurveDateTypeDay:
            [datePickerPopupViewController selectDay:self.dateComponents.day animated:NO];
        
        case AUXElectricityCurveDateTypeMonth:
            [datePickerPopupViewController selectMonth:self.dateComponents.month animated:NO];
            
        default:
            [datePickerPopupViewController selectYear:self.dateComponents.year animated:NO];
            break;
    }
    
    [datePickerPopupViewController showWithAnimated:YES completion:nil];
    
    @weakify(self);
    datePickerPopupViewController.didSelectYearBlock = ^(NSInteger year) {
        @strongify(self);
        [self didSelectYear:year];
    };
    
    datePickerPopupViewController.didSelectYearAndMonthBlock = ^(NSInteger year, NSInteger month) {
        @strongify(self);
        [self didSelectYear:year month:month];
    };
    
    datePickerPopupViewController.didSelectDateBlock = ^(NSInteger year, NSInteger month, NSInteger day) {
        @strongify(self);
        [self didSelectYear:year month:month day:day];
    };
}

// 选择了年份
- (void)didSelectYear:(NSInteger)year {
    NSInteger month = self.dateComponents.month;
    
    [self didSelectYear:year month:month];
}

// 选择了年月
- (void)didSelectYear:(NSInteger)year month:(NSInteger)month {
    
    NSInteger day = 1;
    
    [self didSelectYear:year month:month day:day];
}

// 选择了年月日
- (void)didSelectYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    
    [self.dateComponents setValue:year forComponent:NSCalendarUnitYear];
    [self.dateComponents setValue:month forComponent:NSCalendarUnitMonth];
    [self.dateComponents setValue:day forComponent:NSCalendarUnitDay];
    self.date = [self.calendar dateFromComponents:self.dateComponents];
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:self.date];
    
    [self.curveModel setRequestDateWithComponents:self.dateComponents];
    
    [self getElectricityConsumptionData];
}

#pragma mark - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.waveTypeArray count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    CGFloat width = CGRectGetWidth(self.waveCollectionView.frame);
    CGFloat left = (width - 90 * 3) / 2.0 - 10.0;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, left, 0, left);
    
    return edgeInsets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXElectricityWaveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    AUXElectricityCurveWaveType waveType = [self.waveTypeArray[indexPath.item] integerValue];
    
    switch (waveType) {
        case AUXElectricityCurveWaveTypeNormal:
            cell.titleLabel.text = @"波平";
            cell.value = self.curveModel.sumWaveFlatElectricity;
            cell.indicateColor = [AUXConfiguration sharedInstance].curveNormalColor;
            break;
            
        case AUXElectricityCurveWaveTypePeak:
            cell.titleLabel.text = @"波峰";
            cell.value = self.curveModel.sumPeakElectricity;
            cell.indicateColor = [AUXConfiguration sharedInstance].curvePeakColor;
            break;
            
        default:
            cell.titleLabel.text = @"波谷";
            cell.value = self.curveModel.sumValleyElectricity;
            cell.indicateColor = [AUXConfiguration sharedInstance].curveValleyColor;
            break;
    }
    
    return cell;
}

#pragma mark - 网络请求

/// 获取用电曲线
- (void)getElectricityConsumptionData {
    
    if (!self.deviceInfo || self.deviceInfo.virtualDevice) {
        [self getElectricityConsumptionTestData];
        return;
    }
    
    // 旧设备
    if (self.device.bLDevice) {
        [self getOldElectricityConsumptionData];
        return;
    }
    
    // 新设备
    [self showLoadingHUD];
    
    [[AUXNetworkManager manager] getElectricityConsumptionCurveWithDid:self.deviceInfo.did date:self.date dateType:self.currentDateType completion:^(AUXElectricityConsumptionCurveModel * _Nullable curveModel, NSError * _Nonnull error) {
        
        [self hideLoadingHUD];
        
        switch (error.code) {
            case AUXNetworkErrorNone:
                [self.curveModel updatePowerCurveDatasWithModel:curveModel];
                [self.curveModel analysePowerCurveDatas];
                [self updateCurveView];
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                
                if (error.code == 401) {
                    [self showErrorViewWithMessage:@"查询用电曲线失败"];
                } else {
                    [self showErrorViewWithError:error defaultMessage:@"查询用电曲线失败"];
                }
                break;
        }
    }];
}

/// 获取旧设备的用电曲线 (古北云)
- (void)getOldElectricityConsumptionData {
    NSString *mac = self.deviceInfo.mac;
    
    [self showLoadingHUD];
    
    BOOL isToday = NO;
    if (self.currentDateType == AUXElectricityCurveDateTypeDay) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        if ([[formatter stringFromDate:[NSDate date]] isEqualToString:[formatter stringFromDate:self.date]]) {
            isToday = YES;
        }
    }
    
    if (isToday) {
        [[AUXNetworkManager manager] getTodayElectricityConsumptionCurveWithMac:mac completion:^(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable pointModelArray, NSError * _Nonnull error) {
            [self hideLoadingHUD];
            
            if (error.code == AUXNetworkErrorNone) {
                // 旧设备只有波平数据。
                self.curveModel.pointModelList = [NSArray arrayWithArray:pointModelArray];
                [self updateCurveView];
            } else {
                if (error.code == 401) {
                    [self showErrorViewWithMessage:@"查询用电曲线失败"];
                } else {
                    [self showErrorViewWithError:error defaultMessage:@"查询用电曲线失败"];
                }
            }
        }];
    } else {
        [[AUXNetworkManager manager] getElectricityConsumptionCurveWithMac:mac subIndex:0 date:self.date dateType:self.currentDateType completion:^(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable pointModelArray, NSError * _Nonnull error) {
            
            [self hideLoadingHUD];
            
            if (error.code == AUXNetworkErrorNone) {
                // 旧设备只有波平数据。
                self.curveModel.pointModelList = [NSArray arrayWithArray:pointModelArray];
                [self updateCurveView];
            } else {
                if (error.code == 401) {
                    [self showErrorViewWithMessage:@"查询用电曲线失败"];
                } else {
                    [self showErrorViewWithError:error defaultMessage:@"查询用电曲线失败"];
                }
            }
        }];
    }
}

/// 更新曲线
- (void)updateCurveView {
    if (!self.deviceInfo.virtualDevice) {
        // 不是虚拟体验时，才清楚多余的数据
        [self.curveModel removeUnnecessaryPointModels];
    }
    
    self.curveChildViewController.pointModelList = self.curveModel.pointModelList;
    
    self.curveChildViewController.year = self.dateComponents.year;
    self.curveChildViewController.month = self.dateComponents.month;
    self.curveChildViewController.day = self.dateComponents.day;
    
    [self.curveChildViewController updateCurve];
    
    NSInteger totalDegree = [self.curveModel calculateTotalDegrees];
    
    self.bottomConsumptionLabel.text = [NSString stringWithFormat:@"%@", @(totalDegree)];
    
    // 旧设备不显示波平、波峰、波谷数据
    if (self.device.bLDevice) {
        return;
    }
    
    // 日用电曲线没有波峰波谷时段时，隐藏波峰波谷数据视图
//    switch (self.currentDateType) {
//        case AUXElectricityCurveDateTypeDay:
//            self.waveCollectionView.hidden = (self.curveModel.timePeriodArray.count == 0);
//            break;
//
//        default:
//            self.waveCollectionView.hidden = NO;
//            break;
//    }
    
    [self.waveCollectionView reloadData];
}

#pragma mark - 用的曲线测试数据

- (void)getElectricityConsumptionTestData {
    
    switch (self.currentDateType) {
        case AUXElectricityCurveDateTypeYear:
            [self.curveModel setYearTestData];
            self.bottomIndicateLabel.text = @"年用电总量：";
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            [self.curveModel setMonthTestData];
            self.bottomIndicateLabel.text = @"月用电总量：";
            break;
            
        default:
            [self.curveModel setDayTestData];
            self.bottomIndicateLabel.text = @"日用电总量：";
            break;
    }
    
    [self updateCurveView];
}

@end
