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

#import <QMUIKit/QMUIKit.h>

#import "AUXPickerContentView.h"

@interface AUXPickerPopupViewController : QMUIModalPresentationViewController <UIPickerViewDelegate, UIPickerViewDataSource>
        
@property (nonatomic, weak) AUXPickerContentView *pickerContentView;

/// 当前选中的行数
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *selectedRowDict;

// 数据源1。如果设置了 componentDataSource，将会忽略 minValue、maxValue。
@property (nonatomic, strong) NSArray<NSArray *> *componentDataSource;
// 数据源2。这里只适合只有一个 component 的情况。
@property (nonatomic, assign) NSInteger minValue;   // 最小值。默认为0。
@property (nonatomic, assign) NSInteger maxValue;   // 最大值。默认为0。
@property (nonatomic, assign) NSInteger valueStep;  // 步进。默认为1。

@property (nonatomic, strong) NSString *pickerTitle;        // 标题
@property (nonatomic, strong) NSString *indicateString;     // 单位
@property (nonatomic, assign) CGFloat indicateLeading;

@property (nonatomic,assign) BOOL showLeftAndRightUnitLabel;

@property (nonatomic, copy) void (^confirmBlock)(NSArray<NSNumber *> *selectedRows);

@property (nonatomic, copy) void (^reloadBlock)(NSMutableDictionary<NSNumber *,NSNumber *> *selectedRowDict);

- (void)initSubviews;

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

- (void)actionCancel:(UIButton *)sender;
- (void)actionConfirm:(UIButton *)sender;

@end
