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

#import "AUXTimePeriodPickerTableViewCell.h"

#import "AUXConfiguration.h"

#import "UIColor+AUXCustom.h"

@interface AUXTimePeriodPickerTableViewCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *endPickerView;
@property (weak, nonatomic) IBOutlet UILabel *centerTipLabel;

@property (nonatomic, assign) NSInteger startMinuteRow;
@property (nonatomic, assign) NSInteger endHourRow;
@property (nonatomic, assign) NSInteger endMinuteRow;


@property (nonatomic, assign) NSInteger minuteNumberOfRows;

@end

@implementation AUXTimePeriodPickerTableViewCell

+ (CGFloat)properHeight {
    return 253.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.startPickerView.delegate = self;
    self.startPickerView.dataSource = self;
    self.endPickerView.delegate = self;
    self.endPickerView.dataSource = self;
    
    _disableMode = NO;
    
    _hourNumberOfRows = 24;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 不知道什么原因，pickerView加到tableViewCell之后，两条线条的背景色会没有值。
    UIColor *grayColor = [UIColor colorWithHexString:@"F6F6F6"];
    
    if (self.startPickerView.subviews.count >= 3) {
        self.startPickerView.subviews[1].backgroundColor = grayColor;
        self.startPickerView.subviews[2].backgroundColor = grayColor;
    }
    
    if (self.endPickerView.subviews.count >= 3) {
        self.endPickerView.subviews[1].backgroundColor = grayColor;
        self.endPickerView.subviews[2].backgroundColor = grayColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark setters
- (void)setPickerType:(AUXTimePeriodPickerType)pickerType {
    _pickerType = pickerType;
    
    if (_pickerType == AUXTimePeriodPickerTypeOfSleepDIY && self.onlyShowStartPickView) {
        _hourNumberOfRows = 12;
    }
}

- (void)setDisableMode:(BOOL)disableMode {
    _disableMode = disableMode;
    
    self.startPickerView.userInteractionEnabled = !disableMode;
    self.endPickerView.userInteractionEnabled = !disableMode;
    
    [self.startPickerView reloadAllComponents];
    [self.endPickerView reloadAllComponents];
}

- (void)setFirstDisableMode:(BOOL)firstDisableMode {
    _firstDisableMode = firstDisableMode;
    
    self.startPickerView.userInteractionEnabled = !firstDisableMode;
    [self.startPickerView reloadAllComponents];
}

- (void)setSecondDisableMode:(BOOL)secondDisableMode {
    _secondDisableMode = secondDisableMode;
    
    self.endPickerView.userInteractionEnabled = !secondDisableMode;
    [self.endPickerView reloadAllComponents];
}

- (void)setOnlyShowStartPickView:(BOOL)onlyShowStartPickView {
    _onlyShowStartPickView = onlyShowStartPickView;
    
    if (_onlyShowStartPickView) {
        self.startPickViewTriling.constant = kAUXScreenWidth / 2;
        self.endPickerView.hidden = YES;
        self.startPickerView.hidden = NO;
        self.centerUnitLabelLeading.constant = 25;
        self.centerTipLabel.text = @"小时";
    }
}

- (void)selectStartHour:(NSInteger)hour animated:(BOOL)animated {
    _startHour = hour;
    self.startHourRow = hour;
    [self.startPickerView selectRow:self.startHourRow inComponent:0 animated:animated];
}

- (void)selectEndHour:(NSInteger)hour animated:(BOOL)animated {
    _endHour = hour;
    
    self.endHourRow = hour;
    [self.endPickerView selectRow:self.endHourRow inComponent:0 animated:animated];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.hourNumberOfRows;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    UIColor *color = [UIColor blackColor];
    NSInteger value;
    if (self.pickerType == AUXTimePeriodPickerTypeOfSleepDIY && self.onlyShowStartPickView) {
        value = row % self.hourNumberOfRows + 1;
    } else {
        value = row % self.hourNumberOfRows;
    }
    
    NSString *title = [NSString stringWithFormat:@"%02d:00", (int)value];
    
    if (self.onlyShowStartPickView) {
        title = [NSString stringWithFormat:@"%02d", (int)value];
    }
    
    NSInteger selectedRow = 0;
    
    if ([pickerView isEqual:self.startPickerView]) {
        selectedRow = self.startHourRow;
    } else {
        selectedRow = self.endHourRow;
    }
    
    if (selectedRow == row && !self.disableMode) {
        color = [AUXConfiguration sharedInstance].blueColor;
    } else {
        color = [UIColor grayColor];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: color}];
    
    return attributedString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if ([pickerView isEqual:self.startPickerView]) {
        self.startHourRow = row;
        _startHour = row % self.hourNumberOfRows;
    } else {
        self.endHourRow = row;
        _endHour = row % self.hourNumberOfRows;
    }
    
    if (self.onlyShowStartPickView) {
        _startHour += 1;
    }
    
    [pickerView reloadComponent:component];
    
    if (self.didSelectTimeBlock) {
        self.didSelectTimeBlock(self.startHour, self.startMinute, self.endHour, self.endMinute);
    }
}

@end
