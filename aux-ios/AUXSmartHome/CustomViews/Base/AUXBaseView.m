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

#import "AUXBaseView.h"

@implementation AUXBaseView

+ (instancetype)instantiateFromNibWithNibName:(NSString *)nibName {
    return [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil].firstObject;
}

+ (instancetype)instantiateFromNib {
    return [self instantiateFromNibWithNibName:NSStringFromClass([self class])];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadNib];
    [self initSubviews];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadNib];
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadNib];
        [self initSubviews];
    }
    return self;
}

- (void)loadNib {
    
}

- (void)initSubviews {
    
}

@end
