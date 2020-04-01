//
//  AUXStoreDomainModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/10/15.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXStoreDomainModel : NSObject

+ (instancetype)sharedInstance;

/**
 baseURL
 */
@property (nonatomic,copy) NSString *domain;
/**
 产品分类
 */
@property (nonatomic,copy) NSString *productType;
/**
 首页
 */
@property (nonatomic,copy) NSString *eshopIndex;
/**
 搜索url
 */
@property (nonatomic,copy) NSString *searchUrl;
/**
 购物车
 */
@property (nonatomic,copy) NSString *cart;
/**
 个人中心
 */
@property (nonatomic,copy) NSString *ucenter;
/**
 订单
 */
@property (nonatomic,copy) NSString *orderList;
/**
 积分
 */
@property (nonatomic,copy) NSString *point;
/**
 优惠券
 */
@property (nonatomic,copy) NSString *coupon;
/**
 我的评价
 */
@property (nonatomic,copy) NSString *ping_list;
/**
 活动记录
 */
@property (nonatomic,copy) NSString *record;
/**
 我的权益
 */
@property (nonatomic,copy) NSString *rights;
/**
 我的地址
 */
@property (nonatomic,copy) NSString *address;
/**
 是否登录
 */
@property (nonatomic,copy) NSString *isLoginPage;
/**
 是否绑定
 */
@property (nonatomic,copy) NSString *isBindAccound;
/**
 是否授权
 */
@property (nonatomic,copy) NSString *isAuthPage;
/**
 是否购物车
 */
@property (nonatomic,copy) NSString *isChatPage;
/**
 授权url
 */
@property (nonatomic,copy) NSString *authRedirectPage;

/**
 Token 指app 的  accesstoken，saas的token
 */
@property (nonatomic,copy) NSString *token;
/**
 搜索的关键字
 */
@property (nonatomic,copy) NSString *keywords;

/**
 判断url是否授权

 @param url url
 @return 返回值 1 为授权 0 未授权
 */
- (BOOL)whtherAuth:(NSString *)url;

/**
 判断url是否登录

 @param url URL
 @return 1 为登录 0 未登录
 */
- (BOOL)whtherLogin:(NSString *)url;

/**
 判断是否是需要绑定

 @param url URL
 @return 1  需要绑定  0 不需要
 */
- (BOOL)whtherBindAccount:(NSString *)url;

/**
 是否是我的订单
 
 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherOrderList:(NSString *)url;

/**
 判断URL是否是购物车

 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherCart:(NSString *)url;

/**
 判读是否是积分
 
 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherPoint:(NSString *)url;

/**
 是否是优惠券

 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherCoupon:(NSString *)url;

/**
 是否是我的权益
 
 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherRights:(NSString *)url;

/**
 是否是我的地址
 
 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherAddress:(NSString *)url;

/**
 判断URL是否是个人中心

 @param url url
 @return 1 是 0 否
 */
- (BOOL)whtherCenter:(NSString *)url;

/**
 是否是商品分类

 @param url URL
 @return 1 是 0 否
 */
- (BOOL)whtherProductType:(NSString *)url;

/**
 获取url对应的重定向路径

 @param redirect 重定向路径
 @return 返回值
 */
- (NSString *)getAuth:(NSString *)redirect;

/**
 用户搜索商品

 @param keywords 搜索关键字
 @return 返回的url
 */
- (NSString *)searchUrlWithKeywords:(NSString *)keywords;

- (NSString*)encodeString:(NSString*)unencodedString;

- (NSString*)decodeString:(NSString*)encodedString;

@end

NS_ASSUME_NONNULL_END
