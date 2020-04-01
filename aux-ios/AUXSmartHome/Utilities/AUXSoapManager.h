//
//  AUXSoapManager.h
//  AUXSmartHome
//
//  Created by 陈凯 on 11/09/2018.
//  Copyright © 2018 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

#import "AUXAddressModel.h"
#import "AUXProvinceModel.h"
#import "AUXCityModel.h"
#import "AUXCountyModel.h"
#import "AUXTownModel.h"
#import "AUXWorkOrderModel.h"
#import "AUXEvaluationModel.h"
#import "AUXServiceOrderModel.h"

#import "AUXTopContactModel.h"
#import "AUXSubmitWorkOrderModel.h"
#import "AUXPickListModel.h"
#import "AUXUserprofileModel.h"


typedef void (^AUXSoapCompletionHandler)(id _Nullable responseObject, NSError *responseError);

@interface AUXSoapManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark 获取省、市、区县、街道
/**
 获取省份
 */
- (void)getProvinceListCompletion:(void (^)(NSArray <AUXAddressModel *> * provienceArray,NSError * _Nonnull error))completion;

/**
 获取市

 @param provinceId 省份id
 */
- (void)getCityList:(NSString *)provinceId completion:(void (^)(NSArray <AUXAddressModel *> * cityListArray,NSError * _Nonnull error))completion;

/**
 获取区县

 @param cityId 市id
 */
- (void)getCountyList:(NSString *)cityId completion:(void (^)(NSArray <AUXAddressModel *> * countyListArray,NSError * _Nonnull error))completion;

/**
 获取街道
 
 @param countyId 市id
 */
- (void)getTownList:(NSString *)countyId completion:(void (^)(NSArray <AUXAddressModel *> * townListArray,NSError * _Nonnull error))completion;

#pragma mark 联系人
/**
 获取我的联系人列表

 @param pageIndex 页码
 @param pageSize 页面大小
 @param phone 用户手机号码
 */
- (void)getContactsWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize phone:(NSString *)phone completion:(void (^)(NSArray <AUXTopContactModel *>* contactsListArray,NSError * _Nonnull error))completion;

/**
 设置为默认联系人

 @param guid 联系人的id
 @param isDefault 是否默认
 */
- (void)setTopContactDefaultWithId:(NSString *)guid isDefault:(BOOL)isDefault userPhone:(NSString *)userPhone completion:(void (^)(BOOL result,NSError * _Nonnull error))completion;

/**
 获取默认联系人

 @param phone 手机号码
 */
- (void)getDefaultTopContactWithPhone:(NSString *)phone completion:(void (^)(AUXTopContactModel * contactModel,NSError * _Nonnull error))completion;

/**
 保存联系人信息

 @param model 联系人模型
 */
- (void)saveContactWithModel:(AUXTopContactModel *)model completion:(void (^)(NSString * guid,NSError * _Nonnull error))completion;

/**
 删除联系人

 @param guid 要删除的联系人id
 */
- (void)deleteTopContactWithId:(NSString *)guid completion:(void (^)(BOOL result,NSError * _Nonnull error))completion;

#pragma mark 预约安装/维修
/**
 提交预约安装或维修信息

 @param afterSaleType 提交的类型
 @param submitWorkOrderModel 信息奉还封装的模型
 @param userPhone 用户电话
 */
- (void)saveWorkOrderWithType:(AUXAfterSaleType)afterSaleType SubmitWorkOrderModel:(AUXSubmitWorkOrderModel *)submitWorkOrderModel Userphone:(NSString *)userPhone completion:(void (^)(BOOL result,NSError * _Nonnull error))completion;

#pragma mark 获取产品线
/**
 获取产品线(目前只有家庭空调和商用空调)
 */
- (void)getProductGroupCompletion:(void (^)(NSArray <AUXPickListModel *> *productlistArray,NSError * _Nonnull error))completion;

#pragma mark 获取所有产品列表
- (void)getAllProductWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize phone:(NSString *)phone completion:(void (^)(NSArray <AUXProduct *>* contactsListArray,NSError * _Nonnull error))completion;

#pragma mark 工单
/**
 工单查询

 @param queryValue 查询条件
 @param pageIndex 页码 从1开始
 @param pageSize 页面大小
 @param type 查询类型:1：一键安装查询;2：一键维修查询;
 @param Userphone 用户手机号码
 */
- (void)getWorkOrderListWithQueryValue:(NSString *)queryValue pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize type:(NSInteger)type Userphone:(NSString *)Userphone completion:(void (^)(NSArray <AUXWorkOrderModel *>* workOrderListArray,NSError * _Nonnull error))completion;

/**
 获取工单详细信息

 @param guid 工单ID
 @param entityName 实体名称
 */
- (void)getWorkOrderDetailWithGuid:(NSString *)guid entityName:(NSString *)entityName completion:(void (^)(AUXSubmitWorkOrderModel * workOrderDetailModel,NSError * _Nonnull error))completion;

/**
 进度查询

 @param oid 服务id
 @param entityName 实体名称
 */
- (void)getProgressWithOid:(NSString *)oid entityName:(NSString *)entityName completion:(void (^)(AUXProduct * productModel,NSError * _Nonnull error))completion;

#pragma mark 服务评价

/**
 创建服务评价

 @param Memo 备注
 @param Grade 星级
 @param Oid 工单id
 @param EntityName 家用还是商用
 @param ImgIds 图片
 */
- (void)createEvaluationWithMemo:(NSString *)Memo Grade:(NSString *)Grade Oid:(NSString *)Oid EntityName:(NSString *)EntityName ImgIds:(NSArray <NSString *>*)ImgIds completion:(void (^)(BOOL result,NSError * _Nonnull error))completion;

/**
 获取服务评价
 
 @param oid 服务id
 @param eid 服务评价单id
 @param entityName 实体名称
 */
- (void)getEvaluationWithOid:(NSString *)oid eid:(NSString *)eid entityName:(NSString *)entityName completion:(void (^)(AUXEvaluationModel * evaluationModel,NSError * _Nonnull error))completion;

/**
 获取未评价的服务列表

 @param pageIndex 页面
 @param pageSize 页面大小
 @param Userphone 用户手机
 */
- (void)getServiceOrderWithPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize Userphone:(NSString *)Userphone completion:(void (^)(NSArray <AUXServiceOrderModel *> * serviceOrderModelList,NSError * _Nonnull error))completion;

/**
 获取产品服务记录

 @param productGroup 产品线名称
 @param productName 产品名称
 @param channelType 购买单位类型
 @param pageType 传1表示商用，2表示家用
 @param pageIndex 页码
 @param pageSize 每页条数
 @param userPhone 用户手机号
 */
- (void)getServiceRecordWithProductGroup:(NSString *)productGroup productName:(NSString *)productName channelType:(NSInteger)channelType pageType:(NSInteger)pageType pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize userPhone:(NSString *)userPhone completion:(void (^)(NSArray <AUXServiceOrderModel *> * serviceOrderModelList,NSError * _Nonnull error))completion;

#pragma mark 金卡激活
/**
 测试金卡是否可用

 @param number 金卡卡号
 */
- (void)CheckGoldenCardWithNumber:(NSString *)number completion:(void(^)(BOOL result , NSString *message))completion;

/**
 查询设备档案信息

 @param number 设备序列号
 */
- (void)GetUserprofileWithNumber:(NSString *)number completion:(void(^)(AUXUserprofileModel *userProfileModel , NSString *message))completion;

/**
 激活金卡

 @param cardId 金卡id
 @param number 设备序列号
 @param userphone 用户手机
 */
- (void)useGoldenCardWithCardId:(NSString *)cardId number:(NSString *)number userphone:(NSString *)userphone completion:(void(^)(BOOL result , NSString *message))completion;

/**
 创建用户

 @param userPhone 用户手机号
 */
- (void)createUserPhone:(NSString *)userPhone completion:(void(^)(BOOL result , NSString *message))completion;

@end
