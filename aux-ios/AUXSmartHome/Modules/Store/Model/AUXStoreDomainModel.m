//
//  AUXStoreDomainModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXStoreDomainModel.h"
#import "AUXUser.h"

@implementation AUXStoreDomainModel

+ (instancetype)sharedInstance {
    static AUXStoreDomainModel *storeDomainModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeDomainModel = [[AUXStoreDomainModel alloc]init];
    });
    return storeDomainModel;
}

- (NSString *)domain {
    return _domain;
}

- (BOOL)whtherAuth:(NSString *)url {
    if (url != nil && _isAuthPage != nil) {
         return [url containsString:_isAuthPage];
    }
    return NO;
   
}

- (BOOL)whtherLogin:(NSString *)url {
    if (url != nil && _isLoginPage != nil) {
        return [url containsString:_isLoginPage];
    }
    return NO;
}

- (BOOL)whtherBindAccount:(NSString *)url {
    
    BOOL result = NO;
    if ([self whtherOrderList:url]) {
        result = YES;
    } else if ([self whtherCart:url]) {
        result = YES;
    } else if ([self whtherPoint:url]) {
        result = YES;
    } else if ([self whtherCoupon:url]) {
        result = YES;
    } else if ([self whtherRights:url]) {
        result = YES;
    } else if ([self whtherAddress:url]) {
        result = YES;
    } else if ([self whtherCenter:url]) {
        result = YES;
    }
    
    if (result) {
        return [AUXUser isBindAccount];
    }
    return NO;
}

- (BOOL)whtherCart:(NSString *)url {
    if (url != nil && _cart != nil) {
        return [url containsString:_cart];
    }
    return NO;
}

- (BOOL)whtherCenter:(NSString *)url {
    if (url != nil && _ucenter != nil) {
         return [url containsString:_ucenter];
    }
    return NO;
}

- (BOOL)whtherPoint:(NSString *)url {
    if (url != nil && _point != nil) {
         return [url containsString:_point];
    }
    return NO;
}

- (BOOL)whtherProductType:(NSString *)url {
    if (url != nil && _productType != nil) {
         return [url containsString:_productType];
    }
    return NO;
}

- (BOOL)whtherOrderList:(NSString *)url {
    if (url != nil && _orderList != nil) {
       return [url containsString:_orderList];
    }
    return NO;
}

- (BOOL)whtherCoupon:(NSString *)url {
    if (url != nil && _coupon != nil) {
        return [url containsString:_coupon];
    }
    return NO;
}

- (BOOL)whtherRights:(NSString *)url {
    if (url != nil && _rights != nil) {
       return [url containsString:_rights];
    }
    return NO;
}

- (BOOL)whtherAddress:(NSString *)url {
    if (url != nil && _address != nil) {
        return [url containsString:_address];
    }
    return NO;
}

- (NSString *)productType {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _productType]];
}

- (NSString *)eshopIndex {
    return [NSString stringWithFormat:@"%@%@" , _domain , _eshopIndex];
}

- (NSString *)searchUrlWithKeywords:(NSString *)keywords {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , [_searchUrl stringByReplacingOccurrencesOfString:@"{{keywords}}" withString:keywords]]];
}

- (NSString *)cart {
    
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _cart]];
}

- (NSString *)ucenter {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _ucenter]];
}

- (NSString *)orderList {

    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _orderList]];
}

- (NSString *)point {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _point]];
}

- (NSString *)coupon {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _coupon]];
}

- (NSString *)ping_list {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _ping_list]];
}

- (NSString *)record {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _record]];
}

- (NSString *)rights {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _rights]];
}

- (NSString *)address {
    return [self getAuth:[NSString stringWithFormat:@"%@%@" , _domain , _address]];
}

- (NSString *)isBindAccound {
    return @"&type=bindAccount";
}

- (NSString *)getAuth:(NSString *)redirect {
    
    if ([AUXUser isLogin]) {
        NSString *edcodeURL = [self encodeString:redirect];
        NSString *token = [AUXUser defaultUser].accessToken;
        NSString *authRedirectPage = [self.authRedirectPage stringByReplacingOccurrencesOfString:@"{{token}}" withString:token];
        authRedirectPage = [authRedirectPage stringByReplacingOccurrencesOfString:@"{{redirectUrl}}" withString:edcodeURL];
        return [NSString stringWithFormat:@"%@%@" , self.domain , authRedirectPage];
    } else {
        return redirect;
    }
}


- (NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *encodedString=(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)unencodedString,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    
    return encodedString;
}

//URLDEcode

- (NSString*)decodeString:(NSString*)encodedString {
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *decodedString=(__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                 (__bridge CFStringRef)encodedString,CFSTR(""),CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}


- (NSString *)description
{
    return [self yy_modelDescription];
}
@end
