//
//  AUXNotificationComponentPromptTableViewCell.m
//  AUXSmartHome
//
//  Created by 奥克斯家研--张海昌 on 2018/5/30.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXNotificationComponentPromptTableViewCell.h"
#import "UIColor+AUXCustom.h"

#import "AUXConfiguration.h"

@implementation AUXNotificationComponentPromptTableViewCell

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

- (void)setDataDict:(NSDictionary *)dataDict {
    _dataDict = dataDict;
    
    
    NSString *title = _dataDict[@"title"];
    UIImage *image = [UIImage imageNamed:_dataDict[@"image"]];
    CGFloat iconHeight = [_dataDict[@"height"] floatValue];
    
    NSMutableAttributedString *attributedString = nil;
    self.titlabel.textColor = [UIColor colorWithHexString:@"666666"];

    self.iconImageView.image = image;
    
    if (self.indexPath.row == 0) {
        NSRange notificationRange = [title rangeOfString:@"通知中心"];
        NSRange editRange = [title rangeOfString:@"“编辑”"];
        attributedString = [[NSMutableAttributedString alloc]initWithString:title];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:notificationRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:editRange];
        
    } else if (self.indexPath.row == 1) {
        NSRange addRange = [title rangeOfString:@"“奥克斯A+”添加"];
        NSRange successRange = [title rangeOfString:@"“完成”"];
        attributedString = [[NSMutableAttributedString alloc]initWithString:title];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:addRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:successRange];
    } else if (self.indexPath.row == 2) {
        NSRange componentRange = [title rangeOfString:@"“小组件”"];
        attributedString = [[NSMutableAttributedString alloc]initWithString:title];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:componentRange];
    }
    
    if (attributedString) {
        self.titlabel.attributedText = attributedString;
        self.titlabel.font = [UIFont systemFontOfSize:16];
    }
    
    
    self.iconImageViewHeight.constant = iconHeight;
    [self layoutIfNeeded];
}

@end
