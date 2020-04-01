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

#import "AUXDatePickerPopupViewController.h"

#import "AUXConfiguration.h"
#import "NSDate+AUXCustom.h"

@interface AUXDatePickerPopupViewController ()

@property (nonatomic, assign) AUXElectricityCurveDateType dateType;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateComponents *dateComponents;

@property (nonatomic, assign) NSInteger startYear;

@property (nonatomic, assign) NSInteger selectedYear;
@property (nonatomic, assign) NSInteger selectedMonth;
@property (nonatomic, assign) NSInteger selectedDay;

@end

@implementation AUXDatePickerPopupViewController

- (instancetype)initWithDateType:(AUXElectricityCurveDateType)dateType minYear:(NSInteger)minYear {
    self = [super init];
    
    if (self) {
        self.dateType = dateType;
        self.calendar = [NSCalendar currentCalendar];
        self.date = [NSDate date];
        self.dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
        self.startYear = minYear;
        
        self.selectedYear = self.startYear;
        self.selectedMonth = 1;
        self.selectedDay = 1;
        
        switch (dateType) {
            case AUXElectricityCurveDateTypeYear:   // 只选择年份
                [self initSubviewsForYearPicker];
                break;
                
            case AUXElectricityCurveDateTypeMonth:  // 选择年月
                [self initSubviewsForMonthPicker];
                break;
                
            default:
                [self initSubviewsForDayPicker];    // 选择年月日
                break;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UILabel *)createIndicateLabelWithText:(NSString *)text {
    UILabel *indicateLabel = [[UILabel alloc] init];
    indicateLabel.textColor = [UIColor blackColor];
    indicateLabel.font = [UIFont systemFontOfSize:13];
    indicateLabel.text = text;
    [indicateLabel sizeToFit];
    indicateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    return indicateLabel;
}

- (void)initSubviewsForYearPicker {
    self.pickerTitle = @"年份";
    self.indicateLeading = 40;
    self.indicateString = @"年";
}

- (void)initSubviewsForMonthPicker {
    self.pickerTitle = @"月份";
    
    UILabel *yearIndicateLabel = [self createIndicateLabelWithText:@"年"];
    UILabel *monthIndicateLabel = [self createIndicateLabelWithText:@"月"];
    
    [self.pickerContentView addSubview:yearIndicateLabel];
    [self.pickerContentView addSubview:monthIndicateLabel];
    
    NSLayoutConstraint *yearCenterY = [NSLayoutConstraint constraintWithItem:yearIndicateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView.indicateLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *yearCenterX = [NSLayoutConstraint constraintWithItem:yearIndicateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:35];
    
    NSLayoutConstraint *monthCenterY = [NSLayoutConstraint constraintWithItem:monthIndicateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView.indicateLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *monthCenterX = [NSLayoutConstraint constraintWithItem:monthIndicateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:25];
    
    [self.pickerContentView addConstraints:@[yearCenterX, yearCenterY, monthCenterX, monthCenterY]];
}

- (void)initSubviewsForDayPicker {
//    self.pickerTitle = self.title;
    self.indicateLeading = 25;
    self.indicateString = @"月";
    
    UILabel *yearIndicateLabel = [self createIndicateLabelWithText:@"年"];
    UILabel *dayIndicateLabel = [self createIndicateLabelWithText:@"日"];
    
    [self.pickerContentView addSubview:yearIndicateLabel];
    [self.pickerContentView addSubview:dayIndicateLabel];
    
    NSLayoutConstraint *yearCenterY = [NSLayoutConstraint constraintWithItem:yearIndicateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView.indicateLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *yearCenterX = [NSLayoutConstraint constraintWithItem:yearIndicateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:5];
    
    NSLayoutConstraint *monthCenterY = [NSLayoutConstraint constraintWithItem:dayIndicateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView.indicateLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *monthCenterX = [NSLayoutConstraint constraintWithItem:dayIndicateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pickerContentView attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:55];
    
    [self.pickerContentView addConstraints:@[yearCenterX, yearCenterY, monthCenterX, monthCenterY]];
}

#pragma mark - Selection

- (void)selectYear:(NSInteger)year animated:(BOOL)animated {
    
    NSInteger numberOfComponents = [self.pickerContentView.pickerView numberOfComponents];
    
    if (numberOfComponents == 0) {
        return;
    }
    
    NSInteger numberOfRows = [self.pickerContentView.pickerView numberOfRowsInComponent:0];
    
    NSInteger row = year - self.startYear;
    
    self.selectedYear = year;
    
    if (numberOfRows >=row) {
         [self.pickerContentView.pickerView selectRow:row inComponent:0 animated:animated];
    }
    
    
    
 
}

- (void)selectMonth:(NSInteger)month animated:(BOOL)animated {
    
    NSInteger numberOfComponents = [self.pickerContentView.pickerView numberOfComponents];
    
    if (numberOfComponents <= 1) {
        return;
    }
    
    NSInteger numberOfRows = [self.pickerContentView.pickerView numberOfRowsInComponent:1];
    
    NSInteger row = month - 1;
    
    if (row >= numberOfRows) {
        return;
    }
    
    self.selectedMonth = month;
    
    [self.pickerContentView.pickerView selectRow:row inComponent:1 animated:animated];
}

- (void)selectDay:(NSInteger)day animated:(BOOL)animated {
    
    NSInteger numberOfComponents = [self.pickerContentView.pickerView numberOfComponents];
    
    if (numberOfComponents <= 2) {
        return;
    }
    
    NSInteger numberOfRows = [self.pickerContentView.pickerView numberOfRowsInComponent:2];
    
    NSInteger row = day - 1;
    
    if (row >= numberOfRows) {
        return;
    }
    
    self.selectedDay = day;
    
    [self.pickerContentView.pickerView selectRow:row inComponent:2 animated:animated];
}

#pragma mark - Actions

- (void)actionConfirm:(UIButton *)sender {
    switch (self.dateType) {
        case AUXElectricityCurveDateTypeYear:
            if (self.didSelectYearBlock) {
                self.didSelectYearBlock(self.selectedYear);
            }
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            if (self.didSelectYearAndMonthBlock) {
                self.didSelectYearAndMonthBlock(self.selectedYear, self.selectedMonth);
            }
            break;
            
        default:
            if (self.didSelectDateBlock) {
                self.didSelectDateBlock(self.selectedYear, self.selectedMonth, self.selectedDay);
            }
            break;
    }
    
    [self hideWithAnimated:NO completion:nil];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger component = 1;
    
    switch (self.dateType) {
        case AUXElectricityCurveDateTypeDay:
            component = 3;
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            component = 2;
            break;
            
        default:
            break;
    }
    
    return component;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger row;
    
    switch (component) {
        case 0:
            row = self.dateComponents.year - self.startYear + 1;
            break;
            
        case 1:
            if (self.selectedYear == self.dateComponents.year) {
                row = self.dateComponents.month;
            } else {
                row = 12;
            }
            break;
            
        default:
            if (self.selectedYear == self.dateComponents.year && self.selectedMonth == self.dateComponents.month) {
                row = self.dateComponents.day;
            } else {
                row = [NSDate numberOfDaysInMonth:self.selectedMonth forYear:self.selectedYear];
            }
            break;
    }
    
    return row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    UIColor *color;
    
    NSInteger selectedRow = 0;
    
    switch (component) {
        case 0: // 年
            title = [NSString stringWithFormat:@"%@", @(self.startYear + row)];
            selectedRow = self.selectedYear - self.startYear;
            break;
            
        case 1: // 月
            title = [NSString stringWithFormat:@"%@", @(row + 1)];
            selectedRow = self.selectedMonth - 1;
            break;
            
        default: // 日
            title = [NSString stringWithFormat:@"%@", @(row + 1)];
            selectedRow = self.selectedDay - 1;
            break;
    }
    
    if (row == selectedRow) {
        color = [AUXConfiguration sharedInstance].blueColor;
    } else {
        color = [UIColor blackColor];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: color}];
    
    return attributedString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0: {
            self.selectedYear = self.startYear + row;
            
            if (self.selectedYear == self.dateComponents.year && self.dateType != AUXElectricityCurveDateTypeYear) {
                NSInteger numberOfMonths = [self pickerView:pickerView numberOfRowsInComponent:1];
                
                if (self.selectedMonth > numberOfMonths) {
                    self.selectedMonth = numberOfMonths;
                }
            }
            
            if ((self.selectedMonth == 2 || self.selectedMonth == self.dateComponents.month) && self.dateType == AUXElectricityCurveDateTypeDay) {
                NSInteger numberOfDays = [self pickerView:pickerView numberOfRowsInComponent:2];
                
                if (self.selectedDay > numberOfDays) {
                    self.selectedDay = numberOfDays;
                }
            }
            
            [pickerView reloadAllComponents];
        }
            break;
            
        case 1: {
            self.selectedMonth = row + 1;
            
            // 选择了月之后，更新天数。
            if (self.dateType == AUXElectricityCurveDateTypeDay) {
                NSInteger numberOfDays = [self pickerView:pickerView numberOfRowsInComponent:2];
                
                if (self.selectedDay > numberOfDays) {
                    self.selectedDay = numberOfDays;
                }
            }
            [pickerView reloadAllComponents];
        }
            break;
            
        default: {
            self.selectedDay = row + 1;
            
            [pickerView reloadComponent:2];
        }
            break;
    }
}

@end
