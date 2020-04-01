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

#import "AUXChooseButton.h"

#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"

@interface AUXChooseButton ()

@property (nonatomic, strong) UIColor *normalTitleColor;

@end

@implementation AUXChooseButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _roundRect = YES;
        _showsBorder = YES;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.normalBackgroundColor) {
        self.normalBackgroundColor = [UIColor whiteColor];
    }
    
    if (!self.selectedBackgroundColor) {
        self.selectedBackgroundColor = [AUXConfiguration sharedInstance].blueColor;
    }
    
    if (!self.disabledSelectedBackgroundColor) {
        self.disabledSelectedBackgroundColor = [UIColor colorWithHex:0xc6c6c6];
    }
    
    self.normalTitleColor = [self titleColorForState:UIControlStateNormal];
    
    if (!self.borderColor) {
        self.borderColor = self.normalTitleColor;
    }
    
    if (self.showsBorder) {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = self.borderColor.CGColor;
    }
    
    if (self.circleSide) {
        CGFloat height = CGRectGetHeight(self.frame);
        self.layer.cornerRadius = height / 2.0;
    } else if (self.roundRect) {
        if (self.cornerRadius <= 0) {
            self.cornerRadius = 5.0;
        }
        self.layer.cornerRadius = self.cornerRadius;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.circleSide) {
        CGFloat height = CGRectGetHeight(self.frame);
        self.layer.cornerRadius = height / 2.0;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateUI];
}

- (void)setDisableMode:(BOOL)disableMode {
    _disableMode = disableMode;
    self.userInteractionEnabled = !disableMode;
    
    if (self.disableStyle == AUXChooseButtonDisableStyleGrayAlways) {
        UIColor *titleColor = disableMode ? [UIColor whiteColor] : self.normalTitleColor;
        [self setTitleColor:titleColor forState:UIControlStateNormal];
    }
    
    [self updateUI];
}

- (void)updateUI {
    if (self.selected) {
        // 可以点击
        if (!self.disableMode) {
            self.backgroundColor = self.selectedBackgroundColor;
            self.layer.borderColor = self.selectedBackgroundColor.CGColor;
        }
        else {
            self.backgroundColor = self.disabledSelectedBackgroundColor;
            self.layer.borderColor = self.disabledSelectedBackgroundColor.CGColor;
        }
    } else {
        if (self.disableStyle == AUXChooseButtonDisableStyleGrayAlways) {
            // 可以点击
            if (!self.disableMode) {
                self.backgroundColor = self.normalBackgroundColor;
                self.layer.borderColor = self.borderColor.CGColor;
            }
            else {
                self.backgroundColor = self.disabledSelectedBackgroundColor;
                self.layer.borderColor = self.disabledSelectedBackgroundColor.CGColor;
            }
        } else {
            self.backgroundColor = self.normalBackgroundColor;
            self.layer.borderColor = self.borderColor.CGColor;
        }
    }
}

@end
