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

#import "AUXBaseTableViewCell.h"

@interface AUXTimePeriodPickerTableViewCell : AUXBaseTableViewCell

@property (nonatomic, assign) BOOL disableMode;     // 是否可以滚动。默认为NO，即可以滚动。

@property (nonatomic,assign) BOOL firstDisableMode;
@property (nonatomic,assign) BOOL secondDisableMode;

@property (nonatomic,assign) BOOL onlyShowStartPickView;

@property (nonatomic,assign) AUXTimePeriodPickerType pickerType;

@property (nonatomic, assign) NSInteger startHour;
@property (nonatomic, assign) NSInteger startMinute;
@property (nonatomic, assign) NSInteger endHour;
@property (nonatomic, assign) NSInteger endMinute;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startPickViewTriling;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerUnitLabelLeading;


@property (weak, nonatomic) IBOutlet UIPickerView *startPickerView;
@property (nonatomic, assign) NSInteger startHourRow;
@property (nonatomic, assign) NSInteger hourNumberOfRows;   // 行数。默认为10000。

@property (nonatomic, copy) void (^didSelectTimeBlock)(NSInteger startHour, NSInteger startMinute, NSInteger endHour, NSInteger endMinute);

- (void)selectStartHour:(NSInteger)hour animated:(BOOL)animated;
- (void)selectEndHour:(NSInteger)hour animated:(BOOL)animated;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end
