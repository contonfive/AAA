//
//  AUXTopContactModel.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/9/20.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXTopContactModel : NSObject

@property (nonatomic,copy) NSString *Name;
@property (nonatomic,copy) NSString *guid;
@property (nonatomic,copy) NSString *Phone;
@property (nonatomic,copy) NSString *Province;
@property (nonatomic,copy) NSString *ProvinceId;
@property (nonatomic,copy) NSString *City;
@property (nonatomic,copy) NSString *CityId;
@property (nonatomic,copy) NSString *County;
@property (nonatomic,copy) NSString *CountyId;
@property (nonatomic,copy) NSString *Town;
@property (nonatomic,copy) NSString *TownId;
@property (nonatomic,copy) NSString *Address;
@property (nonatomic,copy) NSString *Userphone;
@property (nonatomic,copy) NSString *local;
@property (nonatomic,assign) CGFloat addressHeight;
@property (nonatomic,assign) BOOL IsDefault;



@end

NS_ASSUME_NONNULL_END
