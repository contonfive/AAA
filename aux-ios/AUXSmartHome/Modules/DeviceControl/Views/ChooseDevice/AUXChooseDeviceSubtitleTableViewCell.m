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

#import "AUXChooseDeviceSubtitleTableViewCell.h"

#import "AUXConfiguration.h"

@implementation AUXChooseDeviceSubtitleTableViewCell

- (void)setTotalCount:(NSInteger)totalCount {
    _totalCount = totalCount;
    
    NSString *countStr = [NSString stringWithFormat:@"%@", @(totalCount)];
    NSString *text = [NSString stringWithFormat:@"共%@台", countStr];
    NSRange range = [text rangeOfString:countStr];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[AUXConfiguration sharedInstance].blueColor range:range];
    self.subtitleLabel1.attributedText = attributedText;
}

- (void)setSelectedCount:(NSInteger)selectedCount {
    _selectedCount = selectedCount;
    
    if (selectedCount == 0) {
        self.subtitleLabel2.textColor = [UIColor lightGrayColor];
        self.subtitleLabel2.attributedText = nil;
        self.subtitleLabel2.text = @"选择子设备";
    } else {
        self.subtitleLabel2.textColor = [UIColor darkGrayColor];
        
        NSString *countStr = [NSString stringWithFormat:@"%@", @(selectedCount)];
        NSString *text = [NSString stringWithFormat:@"已选%@台", countStr];
        NSRange range = [text rangeOfString:countStr];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[AUXConfiguration sharedInstance].blueColor range:range];
        self.subtitleLabel2.attributedText = attributedText;
    }
}

@end
