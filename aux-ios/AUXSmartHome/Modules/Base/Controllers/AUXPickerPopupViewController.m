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

#import "AUXConfiguration.h"

@interface AUXPickerPopupViewController ()

@end

@implementation AUXPickerPopupViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initSubviews];
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
    return UIStatusBarStyleLightContent;
}

- (void)initSubviews {
    self.valueStep = 1;
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    AUXPickerContentView *pickerContentView = [AUXPickerContentView instantiateFromNib];
    pickerContentView.frame = CGRectMake(0, 0, width, 240);
    pickerContentView.pickerView.delegate = self;
    [pickerContentView.cancelButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [pickerContentView.confirmButton addTarget:self action:@selector(actionConfirm:) forControlEvents:UIControlEventTouchUpInside];
    
    self.contentView = pickerContentView;
    self.pickerContentView = pickerContentView;
    self.modal = YES;
    self.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        pickerContentView.frame = CGRectSetXY(pickerContentView.frame, CGFloatGetCenter(CGRectGetWidth(containerBounds), CGRectGetWidth(pickerContentView.frame)), CGRectGetHeight(containerBounds) - CGRectGetHeight(pickerContentView.frame));
    };
    self.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        pickerContentView.frame = CGRectSetY(pickerContentView.frame, CGRectGetHeight(containerBounds));
        dimmingView.alpha = 0;
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            dimmingView.alpha = 1;
            pickerContentView.frame = contentViewFrame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    self.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            dimmingView.alpha = 0.0;
            pickerContentView.frame = CGRectSetY(pickerContentView.frame, CGRectGetHeight(containerBounds));
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    [pickerContentView.pickerView reloadAllComponents];
}

- (NSMutableDictionary<NSNumber *,NSNumber *> *)selectedRowDict {
    if (!_selectedRowDict) {
        _selectedRowDict = [[NSMutableDictionary alloc] init];
    }
    
    return _selectedRowDict;
}

- (void)setShowLeftAndRightUnitLabel:(BOOL)showLeftAndRightUnitLabel {
    _showLeftAndRightUnitLabel = showLeftAndRightUnitLabel;
    if (_showLeftAndRightUnitLabel) {
        self.pickerContentView.leftUnitLabel.hidden = NO;
        self.pickerContentView.rightUnitLabel.hidden = NO;
    }
}

- (void)setComponentDataSource:(NSArray<NSArray *> *)componentDataSource {
    _componentDataSource = componentDataSource;
    [self.pickerContentView.pickerView reloadAllComponents];
}

- (void)setPickerTitle:(NSString *)pickerTitle {
    _pickerTitle = pickerTitle;
    self.pickerContentView.titleLabel.text = pickerTitle;
}

- (void)setIndicateString:(NSString *)indicateString {
    _indicateString = indicateString;
    
    if (indicateString && indicateString.length > 0) {
        self.pickerContentView.indicateLabel.hidden = NO;
        self.pickerContentView.indicateLabel.text = indicateString;
    } else {
        self.pickerContentView.indicateLabel.hidden = YES;
    }
}

- (void)setIndicateLeading:(CGFloat)indicateLeading {
    _indicateLeading = indicateLeading;
    
    self.pickerContentView.indicateLabelLeading.constant = indicateLeading;
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    [self.selectedRowDict setObject:@(row) forKey:@(component)];
    [self.pickerContentView.pickerView selectRow:row inComponent:component animated:animated];
}

- (void)actionCancel:(UIButton *)sender {
    [self hideWithAnimated:YES completion:nil];
}

- (void)actionConfirm:(UIButton *)sender {
    
    NSMutableArray<NSNumber *> *selectedRows = [[NSMutableArray alloc] init];
    
    if (self.componentDataSource) {
        for (int i = 0; i < [self.componentDataSource count]; i++) {
            NSInteger selectedRow = [self.pickerContentView.pickerView selectedRowInComponent:i];
            [selectedRows addObject:@(selectedRow)];
        }
    } else {
        NSInteger selectedRow = [self.pickerContentView.pickerView selectedRowInComponent:0];
        [selectedRows addObject:@(selectedRow)];
    }
    
    if (self.confirmBlock) {
        self.confirmBlock(selectedRows);
    }
    
    [self hideWithAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.componentDataSource ? self.componentDataSource.count : 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger row;
    
    if (self.componentDataSource) {
        row = [self.componentDataSource[component] count];
    } else {
        row = (self.maxValue - self.minValue) / self.valueStep + 1;
    }
    
    return row;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    UIColor *color = [UIColor blackColor];
    
    if (self.componentDataSource) {
        NSArray *titleArray = self.componentDataSource[component];
        title = titleArray[row];
    } else {
        title = [NSString stringWithFormat:@"%@", @(self.minValue + row * self.valueStep)];
    }
    
    if (self.selectedRowDict[@(component)]) {
        if (self.selectedRowDict[@(component)].integerValue == row) {
            color = [AUXConfiguration sharedInstance].blueColor;
        }
    } else if (row == 0) {
        color = [AUXConfiguration sharedInstance].blueColor;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: color}];
    
    return attributedString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.selectedRowDict setObject:@(row) forKey:@(component)];
    [pickerView reloadComponent:component];
    
    if (self.reloadBlock) {
        self.reloadBlock(self.selectedRowDict);
    }
}

@end
