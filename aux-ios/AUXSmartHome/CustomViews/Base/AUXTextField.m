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

#import "AUXTextField.h"

#import <QMUIKit/QMUIKit.h>

@interface AUXTextField () <UITextFieldDelegate>

@property (nonatomic, weak) UIButton *showOrHidePasswordButton;

@end

@implementation AUXTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.iconImage) {
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:self.iconImage];
        iconImageView.contentMode = UIViewContentModeCenter;
        
        CGFloat imageWidth = 32;
        
        if (self.leftPadding != 0) {
            UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageWidth+self.leftPadding, 0)];
            
            [iconView addSubview:iconImageView];
            
            iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:iconImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:iconView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.leftPadding];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:iconImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:iconView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:iconImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:iconView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:iconImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:iconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            [iconView addConstraints:@[leftConstraint, topConstraint, bottomConstraint, rightConstraint]];
            
            self.leftView = iconView;
            
        } else {
            CGRect frame = CGRectMake(0, 0, imageWidth, 0);
            iconImageView.frame = frame;
            self.leftView = iconImageView;
        }
        
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
    if (self.showOrHidePassword) {
        UIButton *showOrHidePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [showOrHidePasswordButton setImage:[UIImage imageNamed:@"text_input_password_show"] forState:UIControlStateNormal];
        [showOrHidePasswordButton setImage:[UIImage imageNamed:@"text_input_password_hide"] forState:UIControlStateSelected];
        [showOrHidePasswordButton sizeToFit];
        [showOrHidePasswordButton addTarget:self action:@selector(actionShowOrHidePassword:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect frame = showOrHidePasswordButton.frame;
        frame.size.width = 40;
        showOrHidePasswordButton.frame = frame;
        
        self.showOrHidePasswordButton = showOrHidePasswordButton;
        self.rightView = showOrHidePasswordButton;
        self.rightViewMode = UITextFieldViewModeAlways;
    }
    
    if (self.showsBottomLine) {
        self.qmui_borderPosition = QMUIViewBorderPositionBottom;
    }
}

#pragma mark - Actions

- (void)actionShowOrHidePassword:(id)sender {
    self.secureTextEntry = !self.secureTextEntry;
    self.showOrHidePasswordButton.selected = !self.showOrHidePasswordButton.selected;
    
    if (!self.secureTextEntry) {
        NSString *text = self.text;
        self.text = @"";
        self.text = text;
    }
}

@end
