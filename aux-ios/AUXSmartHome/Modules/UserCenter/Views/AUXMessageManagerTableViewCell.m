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

#import "AUXMessageManagerTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+AUXCustom.h"
#import "UILabel+AUXCustom.h"
#import "NSString+AUXCustom.h"

@implementation AUXMessageManagerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.messageImageView.layer.cornerRadius = 5;
    self.messageImageView.layer.masksToBounds = YES;
}

- (void)setMessageInfoModel:(AUXMessageContentModel *)messageInfoModel {
    _messageInfoModel = messageInfoModel;
    
    if (_messageInfoModel) {
        
        if (!AUXWhtherNullString(_messageInfoModel.title)) {
            self.messageTitleLabel.text = _messageInfoModel.title;
        }
        
        if (!AUXWhtherNullString(_messageInfoModel.body)) {
            self.messageBodyLabel.text = _messageInfoModel.body;
        }
        
        if (AUXWhtherNullString(_messageInfoModel.linkedUrl)) {
            self.indicatorImageView.hidden = YES;
        }
        
        if (_messageInfoModel.pushTime) {
            NSString *hmTime = [[_messageInfoModel.pushTime description] substringWithRange:NSMakeRange(11, 5)];
            self.dateLabel.text = [NSString stringWithFormat:@"- %@ -" , hmTime];
        }
        
        if (AUXWhtherNullString(_messageInfoModel.sourceValue)) {
            self.indicatorImageView.hidden = YES;
        }
        
        if (!AUXWhtherNullString(_messageInfoModel.linkedUrl)) {
            NSString *linkedUrl = _messageInfoModel.linkedUrl;
            if (![linkedUrl hasPrefix:@"http"]) {
                linkedUrl = nil;
            }
        }
        
        NSString *imageUrl = _messageInfoModel.imageUrl;
        if (AUXWhtherNullString(imageUrl)) {
            self.messageImageViewHeight.constant = 0;
        } else {
            
            self.messageImageViewHeight.constant = _messageInfoModel.imageSize.height;
            [self.messageImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutIfNeeded];
        });
    }
}

@end
