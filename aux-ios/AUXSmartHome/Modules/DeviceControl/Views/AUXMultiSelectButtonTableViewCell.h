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
#import "AUXChooseButton.h"

static NSInteger const kAUXChooseButtonTag = 100;

/**
 拥有多个选择按钮的tableViewCell (定时界面选择风速、循环周期；智能用电选择模式、循环周期；等等)
 */
@interface AUXMultiSelectButtonTableViewCell : AUXBaseTableViewCell

/// 按钮集合，按钮的 tag 需要从 100 开始按顺序累加。请在 xib 或者 storyboard 中建立联系。
@property (strong, nonatomic) IBOutletCollection(AUXChooseButton) NSArray *chooseButtonCollection;

@property (nonatomic, assign) BOOL multiSelection;  // 是否可以选择多个。默认为NO。
@property (nonatomic, assign) BOOL selectsOneAtLeast;    // 至少也要选中一个按钮。NO=可以全部不选中。默认为YES。

@property (nonatomic, assign) BOOL disableMode;     // YES=全部按钮都不可以点击，NO=可以点击。默认为NO。

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexSet;    // 当前选中的按钮

@property (nonatomic, copy) void (^didSelectBlock)(NSInteger index);
@property (nonatomic, copy) void (^didDeselectBlock)(NSInteger index);

/**
 选中按钮。

 @param indexSet 要选中的按钮的下标集合。(当multiSelection为NO，只会选中indexSet的第一个index。)
 @note indexSet以外的按钮会设置为未选中。
 */
- (void)selectsButtonsAtIndexes:(NSIndexSet *)indexSet;

- (void)selectsButtonAtIndex:(NSInteger)index;

/**
 设置按钮不可点击。

 @param indexSet 要设置的按钮的下标集合。为 nil 时，会设置所有按钮位可以点击。
 */
- (void)disablesButtonsAtIndexes:(NSIndexSet *)indexSet;

@end
