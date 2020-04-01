//
//  AUXTopContactModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTopContactModel.h"

@implementation AUXTopContactModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"guid" : @"Id"};
}

- (NSString *)local {
    
    NSString *local = [NSString string];
    if (self.Province) {
        local = [local stringByAppendingString:self.Province];
        local = [local stringByAppendingString:@" "];
    }
    if (self.City) {
        local = [local stringByAppendingString:self.City];
        local = [local stringByAppendingString:@" "];
    }
    if (self.County) {
        local = [local stringByAppendingString:self.County];
        local = [local stringByAppendingString:@" "];
    }
    if (self.Town) {
        local = [local stringByAppendingString:self.Town];
        local = [local stringByAppendingString:@" "];
    }
    if (self.Address) {
        local = [local stringByAppendingString:self.Address];
    }
    
    return local;
}

- (CGFloat)addressHeight {
    CGSize size = [self.local boundingRectWithSize:CGSizeMake(kAUXScreenWidth - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    return size.height;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
