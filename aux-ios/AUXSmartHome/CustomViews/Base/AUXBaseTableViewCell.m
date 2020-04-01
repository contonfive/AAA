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
#import "UIView+MIExtensions.h"
#import "UIColor+AUXCustom.h"

@implementation AUXBaseTableViewCell

+ (CGFloat)properHeight {
    return 45.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    
    [self.contentView insertSubview:self.bottomView atIndex:self.contentView.subviews.count];
    
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(15, self.height - 1, kAUXScreenWidth - 15, 1)];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"F6F6F6"];
        _bottomView.hidden = YES;
    }
    return _bottomView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
