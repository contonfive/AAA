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

#import "AUXMessageManagerHeaderView.h"
#import "UIColor+AUXCustom.h"

@implementation AUXMessageManagerHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"F2F4F6"];
        
        CGFloat screenWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
        UILabel *headLabel = [[UILabel alloc]init];
        
        headLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        headLabel.frame = CGRectMake((screenWidth - 90) / 2, 13, 90, 21);
        headLabel.backgroundColor = [UIColor colorWithHexString:@"D8D8D8"];
        headLabel.textColor = [UIColor whiteColor];
        headLabel.textAlignment = NSTextAlignmentCenter;
        headLabel.layer.cornerRadius = 3;
        headLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:headLabel];
        self.titleLabel = headLabel;

    }
    return self;
}

- (void)setBackColor:(UIColor *)backGolor {
    self.contentView.backgroundColor = backGolor;
}

@end
