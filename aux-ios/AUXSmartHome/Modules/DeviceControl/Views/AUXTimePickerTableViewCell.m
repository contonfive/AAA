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

#import "AUXTimePickerTableViewCell.h"

#import "AUXConfiguration.h"

#import "UIColor+AUXCustom.h"

@interface AUXTimePickerTableViewCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UILabel *centerTipLabel;

@property (nonatomic, assign) NSInteger hourRow;
@property (nonatomic, assign) NSInteger minuteRow;

@property (nonatomic, assign) NSInteger hourNumberOfRows;   // 行数。默认为10000。
@property (nonatomic, assign) NSInteger minuteNumberOfRows;

@property (nonatomic, assign) BOOL cyclePicking;    // 是否允许循环选择。默认为NO。

@end

@implementation AUXTimePickerTableViewCell

+ (CGFloat)properHeight {
    return 240.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    _cyclePicking = NO;
    _hourNumberOfRows = 24;
    _minuteNumberOfRows = 60;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 不知道什么原因，pickerView加到tableViewCell之后，两条线条的背景色会没有值。
    UIColor *grayColor = [UIColor colorWithHexString:@"F6F6F6"];
    
    if (self.pickerView.subviews.count >= 3) {
        self.pickerView.subviews[1].backgroundColor = grayColor;
        self.pickerView.subviews[2].backgroundColor = grayColor;
    }
}

- (void)setCyclePicking:(BOOL)cyclePicking {
    _cyclePicking = cyclePicking;
    
    if (cyclePicking) {
        _hourNumberOfRows = 24 * 500;
        _minuteNumberOfRows = 60 * 500;
    } else {
        _hourNumberOfRows = 24;
        _minuteNumberOfRows = 60;
    }
}

- (void)selectHour:(NSInteger)hour minute:(NSInteger)minute animated:(BOOL)animated {
    _hour = hour;
    _minute = minute;
    
    self.hourRow = hour + (self.hourNumberOfRows / 24) / 2 * 24 ;
    [self.pickerView selectRow:self.hourRow inComponent:0 animated:animated];
    
    self.minuteRow = minute + (self.minuteNumberOfRows / 60) / 2 * 60;
    [self.pickerView selectRow:self.minuteRow inComponent:1 animated:animated];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger row = 0;
    
    row = (component == 0) ? self.hourNumberOfRows : self.minuteNumberOfRows;
    
    return row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 80;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    UIColor *color = [UIColor blackColor];
    
    NSString *title;
    NSInteger value;
    
    if (component == 0) {
        value = row % 24;
    } else {
        value = row % 60;
    }
    
    title = [NSString stringWithFormat:@"%02d", (int)value];
    
    NSInteger selectedRow = 0;
    
    selectedRow = (component == 0) ? self.hourRow : self.minuteRow;
    
    if (selectedRow == row) {
        color = [UIColor colorWithHexString:@"256BBD"];
    } else {
        color = [UIColor colorWithHexString:@"666666"];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: color}];
    
    return attributedString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        self.hourRow = row;
        _hour = row % 24;
    } else {
        self.minuteRow = row;
        _minute = row % 60;
    }
    
    [pickerView reloadComponent:component];
    
    if (self.didSelectTimeBlock) {
        self.didSelectTimeBlock(self.hour, self.minute);
    }
}

@end
