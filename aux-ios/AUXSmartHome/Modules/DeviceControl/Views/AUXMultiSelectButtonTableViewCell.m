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

#import "AUXMultiSelectButtonTableViewCell.h"

@implementation AUXMultiSelectButtonTableViewCell

+ (CGFloat)properHeight {
    return 90;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _multiSelection = NO;
    _selectsOneAtLeast = YES;
    _disableMode = NO;
    
    for (AUXChooseButton *button in self.chooseButtonCollection) {
        [button addTarget:self action:@selector(actionChooseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDisableMode:(BOOL)disableMode {
    _disableMode = disableMode;
    
    for (AUXChooseButton *button in self.chooseButtonCollection) {
        button.disableMode = disableMode;
    }
}

- (NSMutableIndexSet *)selectedIndexSet {
    if (!_selectedIndexSet) {
        _selectedIndexSet = [[NSMutableIndexSet alloc] init];
    }
    
    return _selectedIndexSet;
}

- (void)selectsButtonsAtIndexes:(NSIndexSet *)indexSet {
    NSUInteger index = indexSet.firstIndex;
    
    if (self.multiSelection) {
        while (index != NSNotFound) {
            [self selectsButtonAtIndex:index];
            
            index = [indexSet indexGreaterThanIndex:index];
        }
    } else {
        [self selectsButtonAtIndex:index];
    }
}

- (void)selectsButtonAtIndex:(NSInteger)index {
    if (self.multiSelection) {
        AUXChooseButton *button = [self.contentView viewWithTag:kAUXChooseButtonTag + index];
        
        if (button) {
            button.selected = YES;
            [self.selectedIndexSet addIndex:index];
        }
    } else {
        if (index < self.chooseButtonCollection.count) {
            for (AUXChooseButton *button in self.chooseButtonCollection) {
                button.selected = (button.tag == kAUXChooseButtonTag + index);
            }
            
            [self.selectedIndexSet removeAllIndexes];
            [self.selectedIndexSet addIndex:index];
        }
    }
}

- (void)disablesButtonsAtIndexes:(NSIndexSet *)indexSet {
    
    for (AUXChooseButton *button in self.chooseButtonCollection) {
        
        NSInteger index = button.tag - kAUXChooseButtonTag;
        
        if (indexSet && [indexSet containsIndex:index]) {
            button.disableMode = YES;
        } else {
            button.disableMode = NO;
        }
    }
}

- (void)actionChooseButtonClicked:(AUXChooseButton *)sender {
    
    NSInteger index = sender.tag - kAUXChooseButtonTag;
    
    if (self.multiSelection) {
        
        BOOL selected = !sender.selected;
        
        if (selected) {
            [self.selectedIndexSet addIndex:index];
            sender.selected = selected;
            
            if (self.didSelectBlock) {
                self.didSelectBlock(index);
            }
        } else if (self.selectedIndexSet.count > 1) {
            [self.selectedIndexSet removeIndex:index];
            sender.selected = selected;
            
            if (self.didDeselectBlock) {
                self.didDeselectBlock(index);
            }
        } else {
            if (!self.selectsOneAtLeast) {
                if (self.selectedIndexSet.count > 0) {
                    [self.selectedIndexSet removeIndex:index];
                    sender.selected = selected;
                    
                    if (self.didDeselectBlock) {
                        self.didDeselectBlock(index);
                    }
                }
            }
        }
    } else {
        [self selectsButtonAtIndex:index];
        
        if (self.didSelectBlock) {
            self.didSelectBlock(index);
        }
    }
}

@end
