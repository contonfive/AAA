//
//  AUXSoapManager.m
//  AUXSmartHome
//
//  Created by 陈凯 on 11/09/2018.
//  Copyright © 2018 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSoapManager.h"
#import "XMLWriter.h"

#import "NSError+AUXCustom.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>

#define SERVER_KEY                              @"7895EICD85TF98EG"
#define NAME_SPACE                              @"http://tempuri.org"
//售后正式环境
#define URL_BASE @"https://ecicss.aux-home.com/GetBaseInfo.asmx"
#define URL_WORK_ORDER @"https://ecicss.aux-home.com/GetWorkOrderInfo.asmx"
#define URL_SERVICE_ORDER @"https://ecicss.aux-home.com/GetServiceOrderInfo.asmx"

//售后测试环境
//#define URL_BASE @"http://47.96.237.242:8078/GetBaseInfo.asmx"
//#define URL_WORK_ORDER @"http://47.96.237.242:8078/GetWorkOrderInfo.asmx"
//#define URL_SERVICE_ORDER @"http://47.96.237.242:8078/GetServiceOrderInfo.asmx"


//#define kUserPhone @"13723893106"

// field key
static NSString * const kAUXFieldCode = @"code";
static NSString * const kAUXFieldMessage = @"message";
static NSString * const kAUXFieldData = @"data";

@interface AUXSoapManager()

@end

@implementation AUXSoapManager

+ (instancetype)sharedInstance {
    static AUXSoapManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AUXSoapManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark 地理位置(省、市、县区、镇)
- (void)getProvinceListCompletion:(void (^)(NSArray <AUXAddressModel *> * provienceArray,NSError * _Nonnull error))completion {
    [self soapDataBaseWithMethod:@"GetProvinceListView" params:nil completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in (NSArray *)responseObject) {
                AUXAddressModel *provinceModel = [[AUXAddressModel alloc]init];
                [provinceModel yy_modelSetWithDictionary:dict];
                [array addObject:provinceModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
        
    }];
}

- (void)getCityList:(NSString *)provinceId completion:(void (^)(NSArray <AUXAddressModel *> * cityListArray,NSError * _Nonnull error))completion; {
    NSDictionary *params = @{@"id": provinceId};
    [self soapDataBaseWithMethod:@"GetCityListView" params:params completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in responseObject) {
                AUXAddressModel *cityModel = [[AUXAddressModel alloc]init];
                [cityModel yy_modelSetWithDictionary:dict];
                [array addObject:cityModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
        
    }];
}

- (void)getCountyList:(NSString *)cityId completion:(void (^)(NSArray <AUXAddressModel *> * countyListArray,NSError * _Nonnull error))completion {
    NSDictionary *params = @{@"id": cityId};
    [self soapDataBaseWithMethod:@"GetCountyListView" params:params completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in responseObject) {
                AUXAddressModel *countyModel = [[AUXAddressModel alloc]init];
                [countyModel yy_modelSetWithDictionary:dict];
                [array addObject:countyModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
        
    }];
}

- (void)getTownList:(NSString *)countyId completion:(void (^)(NSArray <AUXAddressModel *> * townListArray,NSError * _Nonnull error))completion {
    NSDictionary *params = @{@"id": countyId};
    [self soapDataBaseWithMethod:@"GetTownListView" params:params completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in responseObject) {
                AUXAddressModel *townModel = [[AUXAddressModel alloc]init];
                [townModel yy_modelSetWithDictionary:dict];
                [array addObject:townModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
        
    }];
}

#pragma mark 联系人
- (void)getContactsWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize phone:(NSString *)phone completion:(void (^)(NSArray <AUXTopContactModel *>* contactsListArray,NSError * _Nonnull error))completion {
    NSDictionary *params = @{@"pageIndex": @(pageIndex) , @"pageSize": @(pageSize) ,@"userphone": phone};
    [self soapDataBaseWithMethod:@"GetTopContactList" params:params completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in responseObject) {
                AUXTopContactModel *topContactModel = [[AUXTopContactModel alloc]init];
                [topContactModel yy_modelSetWithDictionary:dict];
                [array addObject:topContactModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
        
    }];
}

- (void)setTopContactDefaultWithId:(NSString *)guid isDefault:(BOOL)isDefault userPhone:(NSString *)userPhone completion:(void (^)(BOOL result,NSError * _Nonnull error))completion {
    NSDictionary *parames = @{@"Id" : guid , @"isDefault" : @(isDefault) , @"userphone" : userPhone};
    [self soapDataBaseWithMethod:@"SetTopContactDefault" params:parames completion:^(id responseObject, NSError *err) {
        BOOL result = YES;
        
        if (!responseObject) {
            result = NO;
        }
        if (completion) {
            completion(result , err);
        }
    }];
}


- (void)getDefaultTopContactWithPhone:(NSString *)phone completion:(void (^)(AUXTopContactModel * contactModel,NSError * _Nonnull error))completion {
    NSDictionary *parames = @{@"userphone" : phone};
    [self soapDataBaseWithMethod:@"GetDefaultTopContact" params:parames completion:^(id responseObject, NSError *err) {
        AUXTopContactModel *topContactModel = [[AUXTopContactModel alloc]init];
        
        if (responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            [topContactModel yy_modelSetWithDictionary:dict];
        }
        
        if (completion) {
            completion(topContactModel , err);
        }
    }];
}

- (void)saveContactWithModel:(AUXTopContactModel *)model completion:(void (^)(NSString * guid,NSError * _Nonnull error))completion {
    
    NSMutableDictionary *params = [(NSDictionary *)[model yy_modelToJSONObject] mutableCopy];
    [params removeObjectForKey:@"Userphone"];
    NSString* string = [XMLWriter XMLStringFromDictionary:params];
    NSDictionary *parames = @{@"model" : string , @"userphone" : model.Userphone};
//    NSDictionary *parames = @{@"model" : string , @"userphone" : model.Userphone};
    
    [self soapDataBaseWithMethod:@"SaveTopContactInfo" params:parames completion:^(id responseObject, NSError *err) {
        NSString *guid = nil;
        if (responseObject) {
            guid = responseObject;
        }
        if (completion) {
            completion(guid , err);
        }
    }];
}

- (void)deleteTopContactWithId:(NSString *)guid completion:(void (^)(BOOL result,NSError * _Nonnull error))completion {
    NSDictionary *parames = @{@"Id" : guid};
    [self soapDataBaseWithMethod:@"DeleteTopContactInfo" params:parames completion:^(id responseObject, NSError *err) {
        BOOL result = YES;
        
        if (!responseObject) {
            result = NO;
        }
        if (completion) {
            completion(result , err);
        }
    }];
}

#pragma mark 获取所有产品列表
- (void)getAllProductWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize phone:(NSString *)phone completion:(void (^)(NSArray <AUXProduct *>* contactsListArray,NSError * _Nonnull error))completion {
    NSDictionary *params = @{@"pageIndex": @(pageIndex) , @"pageSize": @(pageSize) ,@"userphone": phone};
    [self soapDataWorkOrderWithMethod:@"GetAllProduct" params:params completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in responseObject) {
                AUXTopContactModel *topContactModel = [[AUXTopContactModel alloc]init];
                [topContactModel yy_modelSetWithDictionary:dict];
                [array addObject:topContactModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
        
    }];
}

#pragma mark 获取产品线
- (void)getProductGroupCompletion:(void (^)(NSArray <AUXPickListModel *> *productlistArray,NSError * _Nonnull error))completion {
    [self soapDataWorkOrderWithMethod:@"GetProductGroup" params:nil completion:^(id responseObject, NSError *err) {
        
        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            for (NSDictionary *dict in responseObject) {
                AUXPickListModel *model = [[AUXPickListModel alloc]init];
                [model yy_modelSetWithDictionary:dict];
                [array addObject:model];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
    }];
}

#pragma mark 预约安装/维修
- (void)saveWorkOrderWithType:(AUXAfterSaleType)afterSaleType SubmitWorkOrderModel:(AUXSubmitWorkOrderModel *)submitWorkOrderModel Userphone:(NSString *)userPhone completion:(void (^)(BOOL result,NSError * _Nonnull error))completion {
    NSDictionary *submitWorkDict = (NSDictionary *)[submitWorkOrderModel yy_modelToJSONObject];
    
    NSString *string = [XMLWriter XMLStringFromDictionary:submitWorkDict];
    
    NSDictionary *params = @{@"type": @(afterSaleType) , @"model": string ,@"userphone": userPhone};
    [self soapDataWorkOrderWithMethod:@"SaveWorkOrder" params:params completion:^(id responseObject, NSError *err) {
        
        BOOL result = YES;
        
        if (!responseObject) {
            result = NO;
        }
        if (completion) {
            completion(result , err);
        }
    }];
}

#pragma mark 工单
- (void)getWorkOrderListWithQueryValue:(NSString *)queryValue pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize type:(NSInteger)type Userphone:(NSString *)Userphone completion:(void (^)(NSArray <AUXWorkOrderModel *>* workOrderListArray,NSError * _Nonnull error))completion {
    
    NSDictionary *params = @{@"pageIndex" : @(pageIndex) , @"pageSize" : @(pageSize) , @"type" : @(type) , @"userphone" : Userphone};
    [self soapDataWorkOrderWithMethod:@"GetWorkOrderList" params:params completion:^(id responseObject, NSError *err) {
        
         NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
           
            for (NSDictionary *dict in (NSArray *)responseObject) {
                AUXWorkOrderModel *workOrderModel = [[AUXWorkOrderModel alloc]init];
                [workOrderModel yy_modelSetWithDictionary:dict];
                [array addObject:workOrderModel];
            }
        }
        
        if (completion) {
            completion(array , err);
        }
    }];
    
}

- (void)getWorkOrderDetailWithGuid:(NSString *)guid entityName:(NSString *)entityName completion:(void (^)(AUXSubmitWorkOrderModel * workOrderDetailModel,NSError * _Nonnull error))completion {
    
    NSDictionary *params = @{@"id" : guid, @"entityName" : entityName};
    [self soapDataWorkOrderWithMethod:@"GetWorkOrderDetail" params:params completion:^(id responseObject, NSError *err) {
        
        AUXSubmitWorkOrderModel * workOrderDetailModel = [[AUXSubmitWorkOrderModel alloc]init];
        if (responseObject) {
            [workOrderDetailModel yy_modelSetWithDictionary:responseObject];
        }
        
        if (completion) {
            completion(workOrderDetailModel , err);
        }
    }];
}

- (void)getProgressWithOid:(NSString *)oid entityName:(NSString *)entityName completion:(void (^)(AUXProduct * productModel,NSError * _Nonnull error))completion {
    NSDictionary *params = @{@"oid" : oid , @"entityName" : entityName};
    [self soapDataServiceOrderWithMethod:@"GetProgress" params:params completion:^(id responseObject, NSError *err) {
       
        AUXProduct *product = [[AUXProduct alloc]init];
        if (responseObject) {
            [product yy_modelSetWithDictionary:responseObject];
        }
        
        if (completion) {
            completion(product , err);
        }
        
    }];
}

#pragma mark 服务评价
- (void)createEvaluationWithMemo:(NSString *)Memo Grade:(NSString *)Grade Oid:(NSString *)Oid EntityName:(NSString *)EntityName ImgIds:(NSArray <NSString *>*)ImgIds completion:(void (^)(BOOL result,NSError * _Nonnull error))completion {
    
    NSDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:Grade , @"Grade" , Oid , @"Oid" , EntityName , @"EntityName" ,  Memo , @"Memo" , nil];
    if (ImgIds) {
        [dict setValue:ImgIds forKey:@"ImgIds"];
    }
    
    NSString *string = [XMLWriter XMLStringFromDictionary:dict];
    NSDictionary *params = @{@"evaluation" : string};
    
    [self soapDataServiceOrderWithMethod:@"CreateEvaluation" params:params completion:^(id responseObject, NSError *err) {
        BOOL result = YES;

        if (err.code != 200) {
            result = NO;
        }
        
        if (completion) {
            completion(result , err);
        }
    }];
}

- (void)getEvaluationWithOid:(NSString *)oid eid:(NSString *)eid entityName:(NSString *)entityName completion:(void (^)(AUXEvaluationModel * evaluationModel,NSError * _Nonnull error))completion {
    NSDictionary *params = @{@"oid" : oid , @"eid" : eid , @"entityName" : entityName};
    [self soapDataServiceOrderWithMethod:@"GetEvaluation" params:params completion:^(id responseObject, NSError *err) {
        
        AUXEvaluationModel *evaluationModel = [[AUXEvaluationModel alloc]init];
        if (responseObject) {
            [evaluationModel yy_modelSetWithDictionary:responseObject];
        }
        
        if (completion) {
            completion(evaluationModel , err);
        }
        
    }];
}

- (void)getServiceOrderWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize Userphone:(NSString *)Userphone completion:(void (^)(NSArray <AUXServiceOrderModel *> * serviceOrderModelList,NSError * _Nonnull error))completion {

    NSDictionary *params = @{@"pageIndex" : @(pageIndex) , @"pageSize" : @(pageSize) , @"userPhone" : Userphone};
    [self soapDataServiceOrderWithMethod:@"GetServiceOrder" params:params completion:^(id responseObject, NSError *err) {

        NSMutableArray *array = [NSMutableArray array];
        if (responseObject) {
            
            for (NSDictionary *dict in (NSArray *)responseObject) {
                AUXServiceOrderModel *serviceOrderModel = [[AUXServiceOrderModel alloc]init];
                [serviceOrderModel yy_modelSetWithDictionary:dict];
                [array addObject:serviceOrderModel];
            }
        }

        if (completion) {
            completion(array , err);
        }
    }];
}

- (void)getServiceRecordWithProductGroup:(NSString *)productGroup productName:(NSString *)productName channelType:(NSInteger)channelType pageType:(NSInteger)pageType pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize userPhone:(NSString *)userPhone completion:(void (^)(NSArray <AUXServiceOrderModel *> * serviceOrderModelList,NSError * _Nonnull error))completion {
    
    NSDictionary *params = @{@"productGroup" : productGroup , @"productName" : productName , @"channelType" : @(channelType) , @"pageType" : @(pageType) , @"pageIndex" : @(pageIndex) , @"pageSize" : @(pageSize) , @"userphone" : userPhone};
    [self soapDataServiceOrderWithMethod:@"GetServiceRecord" params:params completion:^(id responseObject, NSError *err) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in (NSArray *)responseObject) {
            AUXServiceOrderModel *serviceOrderModel = [[AUXServiceOrderModel alloc]init];
            [serviceOrderModel yy_modelSetWithDictionary:dict];
            [array addObject:serviceOrderModel];
        }
        
        if (completion) {
            completion(array , err);
        }
    }];
}

#pragma mark 金卡激活
- (void)CheckGoldenCardWithNumber:(NSString *)number completion:(void(^)(BOOL result , NSString *message))completion {
    NSDictionary *params = @{@"cardId" : number};
    [self soapDataServiceOrderWithMethod:@"CheckGoldenCard" params:params completion:^(id responseObject, NSError *err) {
        BOOL result;
        NSString *message = nil;
        responseObject = (NSDictionary *)responseObject;
        result = [responseObject[@"data"] boolValue];
        message = responseObject[@"message"];
        
        if (completion) {
            completion(result , message);
        }
    }];
}

- (void)GetUserprofileWithNumber:(NSString *)number completion:(void(^)(AUXUserprofileModel *userProfileModel , NSString *message))completion {
    NSDictionary *params = @{@"number" : number};
    [self soapDataServiceOrderWithMethod:@"GetUserprofile" params:params completion:^(id responseObject, NSError *err) {
        AUXUserprofileModel *userProfileModel = [[AUXUserprofileModel alloc]init];
        NSString *message = nil;
        if (responseObject[@"data"]) {
            NSDictionary *data = responseObject[@"data"];
            [userProfileModel yy_modelSetWithDictionary:data];
        } else {
            message = responseObject[@"message"];
        }
        if (completion) {
            completion(userProfileModel , message);
        }
    }];
}

- (void)useGoldenCardWithCardId:(NSString *)cardId number:(NSString *)number userphone:(NSString *)userphone completion:(void(^)(BOOL result , NSString *message))completion {
    NSDictionary *params = @{@"cardId" : cardId , @"number" : number , @"userphone" : userphone};
    [self soapDataServiceOrderWithMethod:@"UseGoldenCard" params:params completion:^(id responseObject, NSError *err) {
        BOOL result;
        NSString *message = nil;
        
        result = [responseObject[@"data"] boolValue];
        message = responseObject[@"message"];
        
        if (completion) {
            completion(result , message);
        }
    }];
}

#pragma mark 创建用户
- (void)createUserPhone:(NSString *)userPhone completion:(void(^)(BOOL result , NSString *message))completion {
    NSDictionary *parames = @{@"userphone" : userPhone};
    
    [self soapDataBaseWithMethod:@"CreateUserphone" params:parames completion:^(id responseObject, NSError *err) {
        responseObject = (NSDictionary *)responseObject;
        
        BOOL result = YES;
        NSString *message = nil;
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code != 200) {
            result = NO;
            message = responseObject[@"message"];
        }
        if (err) {
            result = NO;
        }
        if (completion) {
            completion(result , message);
        }
    }];
}

#pragma mark soap请求封装
- (void)soapDataBaseWithMethod:(NSString *)method params:(NSDictionary *)params completion:(void (^)(id responseObject, NSError * err))completion {
    [self soapData:URL_BASE method:method params:params completion:completion];
}

- (void)soapDataWorkOrderWithMethod:(NSString *)method params:(NSDictionary *)params completion:(void (^)(id responseObject, NSError * err))completion {
    [self soapData:URL_WORK_ORDER method:method params:params completion:completion];
}

- (void)soapDataServiceOrderWithMethod:(NSString *)method params:(NSDictionary *)params completion:(void (^)(id responseObject, NSError * err))completion {
    [self soapData:URL_SERVICE_ORDER method:method params:params completion:completion];
}

- (void)soapData:(NSString *)url method:(NSString *)method params:(NSDictionary *)params completion:(void (^)(id responseObject, NSError * err))completion {
    
    NSString *soapStr = [self createSoapStr:method params:params];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@/%@", NAME_SPACE, method] forHTTPHeaderField:@"SOAPAction"];
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapStr;
    }];
    
    [manager POST:url parameters:soapStr progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *patternStr = [NSString stringWithFormat:@"(?<=%@Result\\>).*(?=</%@Result>)", method, method];
        NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:patternStr options:NSRegularExpressionCaseInsensitive error:nil];
        NSDictionary *dict = [NSDictionary dictionary];
        for (NSTextCheckingResult *checkingResult in [regular matchesInString:result options:0 range:NSMakeRange(0, result.length)]) {
            dict = [NSJSONSerialization JSONObjectWithData:[[result substringWithRange:checkingResult.range] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        }
        
        if ([method isEqualToString:@"GetUserprofile"] || [method isEqualToString:@"CheckGoldenCard"] || [method isEqualToString:@"UseGoldenCard"] || [method isEqualToString:@"CreateUserphone"]) {
            if (completion) {
                completion(dict, nil);
            }
            return ;
        }
        
        [self handleSuccessWithResponseObject:dict completion:completion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}


- (void)handleSuccessWithResponseObject:(nullable id)responseObject completion:(AUXSoapCompletionHandler)completion {
    
    NSError *error = nil;
    
    NSInteger code = -9999;
    NSString *message = @"Reserve";
    
    id dataObject = nil;
    
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        code = [responseDict[kAUXFieldCode] integerValue];
        message = responseDict[kAUXFieldMessage];
        
        if (code == 200) {
            dataObject = responseDict[kAUXFieldData];
        }
    }
    
    error = [NSError errorWithCode:code message:message];
    
    if (completion) {
        completion(dataObject, error);
    }
}

- (NSString *)createSoapStr:(NSString *)method params:(NSDictionary *)params {
    NSDate *now = [NSDate date];
    NSString *time = [NSString stringWithFormat:@"%ld", (long)[now timeIntervalSince1970]];
    NSString *key = [self md5DigestWithString:[NSString stringWithFormat:@"%@%@", SERVER_KEY, time]];
    
    NSMutableString *paramStr = [[NSMutableString alloc] init];
    if (paramStr) {
        for (NSString *key in params) {
            [paramStr appendString:[NSString stringWithFormat:@"<%@>%@</%@>", key, params[key], key]];
        }
    }
    NSString *soapStr = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                         <soap:Envelope xmlns:xsi=\"https://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"https://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                         <soap:Body>\
                         <%@ xmlns=\"http://tempuri.org/\">\
                         <security>%@</security>\
                         <timestamp>%@</timestamp>\
                         %@\
                         </%@>\
                         </soap:Body>\
                         </soap:Envelope>", method, key, time, paramStr, method];
    
    return soapStr;
}

- (NSString *)md5DigestWithString:(NSString *)str {
    const char *input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    return [digest substringWithRange:NSMakeRange(8, 16)];
}

@end
