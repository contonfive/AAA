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

#import "AUXPickerPopupViewController.h"

#import "AUXDefinitions.h"

@interface AUXDatePickerPopupViewController : AUXPickerPopupViewController

/// 当 dateType 为 AUXElectricityCurveDateTypeYear 时，只会回调该block。
@property (nonatomic, copy) void (^didSelectYearBlock)(NSInteger year);

/// 当 dateType 为 AUXElectricityCurveDateTypeMonth 时，只会回调该block。
@property (nonatomic, copy) void (^didSelectYearAndMonthBlock)(NSInteger year, NSInteger month);

/// 当 dateType 为 AUXElectricityCurveDateTypeDay 时，只会回调该block。
@property (nonatomic, copy) void (^didSelectDateBlock)(NSInteger year, NSInteger month, NSInteger day);

- (instancetype)initWithDateType:(AUXElectricityCurveDateType)dateType minYear:(NSInteger)minYear;

- (void)selectYear:(NSInteger)year animated:(BOOL)animated;
- (void)selectMonth:(NSInteger)month animated:(BOOL)animated;
- (void)selectDay:(NSInteger)day animated:(BOOL)animated;

@end
