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

#import "AUXIntelligentElectricityOperationCell.h"

@implementation AUXIntelligentElectricityOperationCell

+ (CGFloat)properHeight {
    return 172;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
        [_imageArray addObject:self.fastImageView];
        [_imageArray addObject:self.balanseImageView];
        [_imageArray addObject:self.standardImageView];
    }
    return _imageArray;
}

@end
