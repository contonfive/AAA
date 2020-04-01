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

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "AUXUser.h"
#import "AUXSchedulerModel.h"
#import "AUXSleepDIYModel.h"
#import "AUXDeviceShareInfo.h"
#import "AUXDeviceModel.h"
#import "AUXDeviceInfo.h"
#import "AUXPeakValleyModel.h"
#import "AUXSmartPowerModel.h"
#import "AUXElectricityConsumptionCurveModel.h"
#import "AUXElectricityConsumptionCurvePointModel.h"
#import "AUXFaultInfo.h"
#import "AUXSharingUser.h"
#import "AUXSharingDevice.h"
#import "AUXAppVersionModel.h"
#import "AUXMessageContentModel.h"
#import "AUXShareDeviceModel.h"
#import "AUXSceneAddModel.h"
#import "AUXSceneDetailModel.h"
#import "AUXChannelTypeModel.h"
#import "AUXStoreDomainModel.h"
#import "AUXPushLimitModel.h"
#import "AUXLaunchAdModel.h"
#import "AUXSceneLogModel.h"
#import "AUXHomepageVersionInfo+CoreDataClass.h"
#import "AUXFeedbackListModel.h"



NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AUXNetworkError) {
    AUXNetworkErrorNone = 200,                    // 成功
    AUXNetworkErrorUnAuthorized = 401,                    // 未授权
    AUXNetworkErrorInvalidCode = 60005,  // 验证码无效
    AUXNetworkErrorInvalidCode1 = 9037,  // 同一号码发送次数太多,一天内同一号码发送相同内容次数:2,当前次数为:2" UserInfo={NSLocalizedDescription=同一号码发送次数太多,一天内同一号码发送相同内容次数:2,当前次数为:2
    
    AUXNetworkErrorInvalidAccessToken = 60006,  // access token 无效
    AUXNetworkErrorExpiredAccessToken = 60007,  // access token 过期
    AUXNetworkErrorIncorrectPassword = 60009,   // 密码错误
    AUXNetworkErrorAccountAlreadyExist = 60104, // 账号已存在
    AUXNetworkErrorphoneNotExis = 60133, // 账号已存在
    
    AUXNetworkErrorAccountCacheExpired = 60106, // 用户账号缓存过期
    AUXNetworkErrorAccountNotExist = 60107, // 账号不存在
    AUXNetworkErrorIncorrectAccountOrPassword = 64001,   // 账号或密码错误
    AUXNetworkErrorRegisterFailed = 64002,   // 注册失败
    AUXNetworkErrorOldPasswordError = 64006,  // 旧密码错误
    AUXNetworkErrorPhoneAlreadyRegistered = 64007,   // 该手机号已注册
    AUXNetworkErrorInvalidPassword = 64009,  // 密码格式不正确
    AUXNetworkErrorWrongOldPassword = 64010,    // 旧密码不正确
    AUXNetworkErrorDeviceNotExist = 65001,  // 设备不存在
    AUXNetworkErrorUserNotAssociateWithDevice = 65002,  // 用户设备关联不存在
    AUXNetworkErrorInvalidQRCode = 65004,  // 无效的二维码
    AUXNetworkErrorExpiredQRCode = 65005,  // 二维码已失效
    AUXNetworkErrorSharingDeviceNotExist = 65006,  // 设备分享不存在
    AUXNetworkErrorDeviceAlreadyBound = 65008, // 设备已经被绑定
    AUXNetworkErrorSharingDeviceToYourself = 65009, // 设备不能分享给自己
    AUXNetworkErrorInvalidSNCode = 65011, // SN长度最大为64
    AUXNetworkErrorShareAlreadyAccepted = 65018, // 不能重复分享
    AUXNetworkErrorNotDeviceOwner = 65021, // 设备的主人不是你
    AUXNetworkErrorSleepDIYTimeConflict = 68002, // 睡眠DIY传入时间段冲突
    AUXNetworkErrorSleepDIYOpening = 68005, // 开启中的睡眠DIY不能修改
    AUXNetworkErrorSleepDIYConflict = 68007, // 睡眠DIY开启时间冲突，请检查总时间是否小于12个小时，或时间交叉
    AUXNetworkErrorAccountNotExist2 = 9005, // PASS用户不存在
    AUXNetworkErrorExpiredCode2 = 9009,  // 验证码过期
    AUXNetworkErrorInvalidCode2 = 9010,  // 无效的验证码
    AUXNetworkErrorPhoneAlreadyExist = 9018, // 手机号已经存在
    AUXNetworkErrorIncorrectAccountOrPassword2 = 9020,   // 用户名或密码错误
    AUXNetworkErrorUnbindDeviceFailed = 9099,   // 删除绑定设备失败
    AUXNetworkErrorADoesNotsupport = 73013,   // "奥克斯A+暂不支持该机型，请使用阿里智能APP配网"

};

typedef NS_ENUM(NSUInteger, AUXNetworkRequestType) {
    AUXNetworkRequestTypeNone = 0,
    AUXNetworkRequestTypeAccessToken = 1 << 0,  // 正在请求 access token
    AUXNetworkRequestTypeLogin = 1 << 1,        // 正在登录
    AUXNetworkRequestTypeDeviceList = 1 << 2,   // 正在获取设备列表
};


typedef void (^AUXNetworkCompletionHandler)(id _Nullable responseObject, NSError *responseError);


@protocol AUXNetworkManagerDelegate <NSObject>

@optional

- (void)networkManagerDidGetAccessToken:(nullable NSString *)accessToken expireDate:(NSTimeInterval)expireDate error:(nonnull NSError *)error;
- (void)networkManagerDidLogin:(nullable AUXUser *)user error:(nonnull NSError *)error;
- (void)networkManagerDidGetDeviceList:(nullable NSArray<AUXDeviceInfo *> *)deviceInfoList error:(nonnull NSError *)error;

@end


@interface AUXNetworkManager : AFHTTPSessionManager

/// 当前网络请求状态 (用于避免进行重复的网络请求)
@property (nonatomic, assign) AUXNetworkRequestType networkRequestType;

/**
 设置 delegate 且实现了相关的方法之后，对应的请求的 completion block 不会再被调用。
 需要考虑清楚才使用 delegate ，在不再需要的时候及时置为 nil。
 */
@property (nonatomic, weak) id<AUXNetworkManagerDelegate> delegate;

+ (instancetype)manager;

/**
 根据错误码获取错误信息。
 
 @param code 错误码
 @return 错误信息，错误码未匹配时，返回nil。
 */
+ (nullable NSString *)getErrorMessageWithCode:(NSInteger)code;

/**
 获取 access token (其他所有网络请求都需要附带 access token 去访问服务器)
 
 @param completion -- error
 */
- (void)getAccessToken:(void (^)(NSError *error))completion;

/**
 清除授权
 */
- (void)clearAuthorization;

#pragma mark - 用户

/**
 用户登录
 
 @param account 账号
 @param password 密码
 @param completion -- user 用户信息
 */
- (void)userLoginWithAccount:(NSString *)account password:(NSString *)password completion:(void (^)(AUXUser * _Nullable user, NSError *error))completion;

/**
 注销用户
 
 @param completion -- error
 */
- (void)userLogoutWithcompletion:(void (^)(NSError *error))completion;

/**
 注册
 
 @param account 账号
 @param password 密码
 @param code 验证码
 @param completion -- user 用户信息
 */
- (void)registerWithAccount:(NSString *)account password:(NSString *)password code:(NSString *)code completion:(void (^)(AUXUser * _Nullable user, NSError *error))completion;

/**
 忘记密码发送验证码
 
 @param phone 手机号
 */
- (void)forgetPwdPhone:(NSString *)phone completion:(void (^)(NSString *code , NSError * _Nonnull error))completion;

/**
 注册时验证码发送
 
 @param phone 手机号
 */
- (void)registryPhone:(NSString *)phone completion:(void (^)(NSString *code , NSError * _Nonnull error))completion;

/**
 第三方账号绑定手机号
 
 @param phone 手机号
 */
- (void)thirdBindAccountSMSCode:(NSString *)phone completion:(void (^)(NSError * _Nonnull error))completion;

/**
 重置密码
 
 @param account 账号
 @param password 新密码
 @param code 验证码
 @param completion -- error
 */
- (void)resetPasswordWithAccount:(NSString *)account password:(NSString *)password code:(NSString *)code completion:(void (^)(NSError *error))completion;

/**
 修改密码
 
 @param passwordOld 旧密码
 @param passwordNew 新密码
 @param completion -- error
 */
- (void)changePasswordWithPasswordOld:(NSString *)passwordOld passwordNew:(NSString *)passwordNew completion:(void (^)(NSError *error))completion;

/**
 获取用户信息
 */
- (void)getUserInfoWithCompletion:(void (^)(AUXUser * _Nullable user, NSError *error))completion;

/**
 更新用户信息
 
 @param user user
 */
- (void)updateUserInfoWithUser:(AUXUser *)user completion:(void (^)(NSError *error))completion;

- (void)updatePortrait:(NSData *)portrait progress:(void (^)(NSProgress *uploadProgress))progress completion:(void (^)(NSString * _Nullable path, NSError * _Nullable error))completion;

#pragma mark - SN码、设备型号

/**
 获取设备型号
 
 @param deviceSN 设备SN码
 @param completion -- deviceModel 设备型号
 */
- (void)getDeviceModelWithSN:(NSString *)deviceSN completion:(void (^)(AUXDeviceModel * _Nullable deviceModel, NSError *error))completion;

/**
 获取设备型号列表
 
 @param completion -- deviceModelList 设备型号列表
 */
- (void)getDeviceModelListWithCompletion:(void (^)(NSArray<AUXDeviceModel *> * _Nullable deviceModelList, NSError *error))completion;

#pragma mark - 设备

/**
 绑定设备
 
 @param deviceInfo 设备信息
 @param completion -- deviceId
 */
- (void)bindDeviceWithDeviceInfo:(AUXDeviceInfo *)deviceInfo completion:(void (^)(NSString * _Nullable deviceId, NSError *error))completion;

/**
 解绑设备
 
 @param deviceId 设备id
 @param completion -- error
 */
- (void)unbindDeviceWithDeviceId:(NSString *)deviceId completion:(void (^)(NSError *error))completion;

/**
 获取设备列表
 
 @param completion -- deviceInfoList 设备列表
 */
- (void)getDeviceListWithCompletion:(void (^)(NSArray<AUXDeviceInfo *> * _Nullable deviceInfoList, NSError *error))completion;

/**
 更新设备信息
 
 @param mac 设备mac地址
 @param deviceSN SN码
 @param alias 设备别名
 @param completion -- error
 */
- (void)updateDeviceInfoWithMac:(NSString *)mac deviceSN:(nullable NSString *)deviceSN alias:(nullable NSString *)alias completion:(void (^)(NSError *error))completion;

#pragma mark - 集中控制

/**
 获取集中控制功能列表
 
 @param completion -- feature 集中控制功能列表
 */
- (void)getMultiControlFunctionListWithCompletion:(void (^)(NSString * _Nullable feature, NSError *error))completion;

/**
 保存集中控制
 
 @param dic 集中控制相关数据
 @param completion 成功失败
 */
-(void)saveSceneCenterontrolWithDic:(NSDictionary*)dic compltion:(void (^) (BOOL result, NSError *error,NSDictionary *dict))completion;


/**
 重置集中控制

 @param sceneId 场景ID
 @param dic 集中控制相关数据
 @param completion 成功失败
 */
- (void)reSetSceneCenterontrolWithSceneId:(NSString*)sceneId Dic:(NSDictionary*)dic compltion:(void (^) (BOOL result, NSError *error))completion;
#pragma mark - 定时

/**
 获取定时列表
 
 @param deviceId 设备id
 @param address 设备地址。单元机传nil，多联机子设备传0x01~0x40。
 @param completion -- schedulerList 定时列表
 */
- (void)getSchedulerListWithDeviceId:(NSString *)deviceId address:(NSString *)address completion:(void (^)(NSArray<AUXSchedulerModel *> * _Nullable schedulerList, NSError *error))completion;

/**
 添加定时
 
 @param schedulerModel 定时
 @param completion -- schedulerId 定时id
 */
- (void)addSchedulerWithModel:(AUXSchedulerModel *)schedulerModel completion:(void (^)(NSString * _Nullable schedulerId, NSError *error))completion;

/**
 更新定时
 
 @param schedulerModel 定时
 @param completion -- error
 */
- (void)updateSchedulerWithModel:(AUXSchedulerModel *)schedulerModel completion:(void (^)(NSError *error))completion;

/**
 开启/关闭定时
 
 @param schedulerId 定时id
 @param on YES=开启，NO=关闭
 @param completion -- error
 */
- (void)switchSchedulerWithId:(NSString *)schedulerId on:(BOOL)on completion:(void (^)(NSError *error))completion;

/**
 删除定时
 
 @param schedulerId 定时id
 @param completion -- error
 */
- (void)deleteSchedulerWithId:(NSString *)schedulerId completion:(void (^)(NSError *error))completion;

#pragma mark - 睡眠DIY

/**
 获取睡眠DIY列表
 
 @param deviceId deviceId
 @param completion -- sleepDIYList 睡眠DIY列表
 */
- (void)getSleepDIYListWithDeviceId:(NSString *)deviceId completion:(void (^)(NSArray<AUXSleepDIYModel *> * _Nullable sleepDIYList, NSError *error))completion;

/**
 添加睡眠DIY
 
 @param sleepDIYModel 睡眠DIY
 @param completion -- sleepDiyId
 */
- (void)addSleepDIYWithModel:(AUXSleepDIYModel *)sleepDIYModel completion:(void (^)(NSString * _Nullable sleepDiyId, NSError *error))completion;

/**
 修改睡眠DIY
 
 @param sleepDIYModel 睡眠DIY
 @param completion -- error
 */
- (void)updateSleepDIYWithModel:(AUXSleepDIYModel *)sleepDIYModel completion:(void (^)(NSError *error))completion;

/**
 删除睡眠DIY
 
 @param sleepDiyId 睡眠DIY id
 @param completion -- error
 */
- (void)deleteSleepDIYWithId:(NSString *)sleepDiyId completion:(void (^)(NSError *error))completion;

/**
 开启/关闭睡眠DIY
 
 @param sleepDiyId 睡眠DIY id
 @param on YES=开启，NO=关闭
 @param completion -- error
 */
- (void)switchSleepDIYWithId:(NSString *)sleepDiyId on:(BOOL)on completion:(void (^)(NSError *error))completion;

/**
 关闭所有的睡眠DIY
 
 @param deviceId 设备id
 @param completion -- error
 */
- (void)turnOffAllSleepDIYWithDeviceId:(NSString *)deviceId completion:(void (^)(NSError *error))completion;

#pragma mark - 设备分享

/**
 获取分享列表
 
 @param deviceId 设备id
 @param completion -- deviceShareInfoList 分享列表
 */
- (void)getDeviceShareListWithDeviceId:(nullable NSString *)deviceId completion:(void (^)(NSArray<AUXDeviceShareInfo *> * _Nullable deviceShareInfoList, NSError *error))completion;

/**
 获取子用户列表
 
 @param completion -- subuserList 子用户列表
 */
- (void)getDeviceShareSubuserListWithCompletion:(void (^)(NSArray<NSDictionary *> * _Nullable subuserList, NSError *error))completion;

/**
 获取二维码
 
 @param deviceIdArray 设备id列表
 @param type 分享类型 (分享给家人、朋友)
 @param completion -- qrContent 二维码内容
 */
- (void)getDeviceShareQRContentWithDeviceIdArray:(NSArray<NSString *> *)deviceIdArray type:(AUXDeviceShareType)type completion:(void (^)(NSString * _Nullable qrContent, NSError *error))completion;

/**
 接受二维码分享 (设备分享)
 
 @param qrContent 二维码内容
 @param completion -- error
 */
- (void)acceptDeviceShareWithQRContent:(NSString *)qrContent completion:(void (^)(NSError *error))completion;

/**
 根据分享的二维码内容生成分享的文字信息
 
 @param qrContent 二维码内容
 @param name 名字
 @param deviceName 设备名字
 @param completion 完成回调
 */
- (void)getDeviceShareMessageWithQRContent:(NSString *)qrContent name:(NSString *)name deviceName:(NSArray<NSString *> *)deviceName ownerUid:(NSString *)ownerUid completion:(void (^)(NSString * _Nullable message, NSError * error))completion;

/**
 根据剪切板的内容来绑定设备
 
 @param clipbordShareData 剪切板的内容
 @param completion 完成回调
 */
- (void)acceptDeviceShareWithClipbordShareData:(NSString *)clipbordShareData completion:(void (^)(NSError * _Nonnull error))completion;

/**
 根据剪切板内容获取绑定设备的信息
 
 @param clipbordShareData 剪切板的内容
 @param completion 完成回调
 */
- (void)getDeviceShareWithClipbordShareData:(NSString *)clipbordShareData completion:(void (^)(AUXShareDeviceModel * model, NSError * error))completion;

/**
 解除分享
 
 @param shareId 分享id
 @param completion -- error
 */
- (void)deleteDeviceShareWithShareId:(NSString *)shareId completion:(void (^)(NSError *error))completion;

- (void)familySharingDeviceListWithCompletion:(void (^)(NSArray * _Nullable array, NSError * _Nonnull error))completion;

- (void)friendSharingDeviceListWithCompletion:(void (^)(NSArray * _Nullable array, NSError * _Nonnull error))completion;

- (void)userSharingDeviceListWithUid:(NSString *)uid userType:(NSString *)userType batchNo:(NSString * _Nullable)batchNo completion:(void (^)(NSArray * _Nullable array, NSError * _Nonnull error))completion;

- (void)userSharingDeviceDeleteWithUid:(NSString *)uid userType:(NSString *)userType batchNo:(NSString * _Nullable)batchNo deviceId:(NSString * _Nullable)deviceId completion:(void (^)(NSError * _Nonnull error))completion;

#pragma mark - 峰谷节电

/**
 查询峰谷节电设置
 
 @param deviceId 设备id
 @param completion -- peakValleyModel 峰谷节电设置
 */
- (void)getPeakValleyWithDeviceId:(NSString *)deviceId completion:(void (^)(AUXPeakValleyModel * _Nullable peakValleyModel, NSError *error))completion;

/**
 新增峰谷节电设置
 
 @param peakValleyModel 峰谷节电设置
 @param completion - peakValleyId 峰谷节电id
 */
- (void)addPeakValley:(AUXPeakValleyModel *)peakValleyModel completion:(void (^)(NSString * _Nullable peakValleyId, NSError *error))completion;

/**
 更新峰谷节电设置
 
 @param peakValleyModel 峰谷节电设置
 @param completion -- error
 */
- (void)updatePeakValley:(AUXPeakValleyModel *)peakValleyModel completion:(void (^)(NSError *error))completion;

#pragma mark - 智能用电

/**
 查询智能用电规则
 
 @param deviceId 设备id
 @param completion - smartPowerModel 智能用电设置
 */
- (void)getSmartPowerWithDeviceId:(NSString *)deviceId completion:(void (^)(AUXSmartPowerModel * _Nullable smartPowerModel, NSError *error))completion;

/**
 开启智能用电
 
 @param smartPowerModel 智能用电设置
 @param completion -- error
 */
- (void)turnOnSmartPower:(AUXSmartPowerModel *)smartPowerModel completion:(void (^)(NSError *error))completion;

/**
 关闭智能用电
 
 @param deviceId 设备id
 @param completion -- error
 */
- (void)turnOffSmartPower:(NSString *)deviceId completion:(void (^)(NSError *error))completion;

#pragma mark - 用电曲线

/**
 查询旧设备的用电曲线 (旧设备只有波平数据) (从古北云获取)
 
 @param mac 设备mac地址
 @param subIndex 子设备index，主设备传0。
 @param date 日期
 @param dateType 查询类型 (年、月、日)
 @param completion -- pointModelArray 波平数据
 */
- (void)getElectricityConsumptionCurveWithMac:(NSString *)mac subIndex:(NSInteger)subIndex date:(NSDate *)date dateType:(AUXElectricityCurveDateType)dateType completion:(void (^)(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable pointModelArray, NSError *error))completion;

/**
 查询旧设备当天用电曲线
 
 @param mac 设备mac地址
 */
- (void)getTodayElectricityConsumptionCurveWithMac:(NSString *)mac completion:(nonnull void (^)(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable, NSError * _Nonnull))completion;

/**
 查询新设备的用电曲线 (从SaaS获取)
 
 @param did 设备did
 @param date 日期
 @param dateType 查询类型 (年、月、日)
 @param completion -- curveModel 曲线模型
 */
- (void)getElectricityConsumptionCurveWithDid:(NSString *)did date:(NSDate *)date dateType:(AUXElectricityCurveDateType)dateType completion:(void (^)(AUXElectricityConsumptionCurveModel * _Nullable curveModel, NSError *error))completion;

#pragma mark - 故障、滤网

/**
 获取故障列表
 
 @param mac 设备mac地址
 @param completion -- faultInfoList 故障列表
 */
- (void)getFaultListWithMac:(NSString *)mac completion:(void (^)(NSArray<AUXFaultInfo *> * _Nullable faultInfoList, NSError *error))completion;

/**
 获取历史故障列表
 
 @param completion -- faultInfoList 故障列表
 */
- (void)getHistoryFaultListWithCompletion:(void (^)(NSArray<AUXFaultInfo *> * _Nullable faultInfoList, NSError *error))completion;

/**
 更新滤网状态 (滤网已清洗)
 
 @param mac 设备mac地址
 @param completion -- error
 */
- (void)updateFilterStatus:(NSString *)mac completion:(void (^)(NSError *error))completion;

/**
 故障报修
 
 @param mac 设备mac地址
 @param deviceSN 设备SN码
 @param faultType 故障信息
 @param completion -- error
 */
- (void)reportFaultWithMac:(NSString *)mac deviceSN:(NSString *)deviceSN faultType:(NSString *)faultType completion:(void (^)(NSError *error))completion;

#pragma mark 配网失败信息

- (void)reportConnectFaultWithInfo:(NSDictionary *)info completion:(void (^)(NSError * _Nullable error))completion;
#pragma mark - 配网成功信息

- (void)reportConnectSuccessWithInfo:(NSDictionary *)info completion:(void (^)(NSError * _Nullable error))completion;

#pragma mark 推送消息

- (void)getMessageWithUid:(NSString *)uid fromDate:(NSString *)date completion:(void (^)(NSMutableArray * _Nullable dateInfoArray, NSMutableArray * _Nullable recordArray ,NSError * _Nonnull error))completion;

- (void)getRemotationWithUid:(NSString *)uid fromDate:(NSString *)date completion:(void (^)(NSMutableArray * _Nullable dateInfoArray, NSMutableArray * _Nullable recordArray ,NSError * _Nonnull error))completion;

- (void)getMessageNoReadCompletion:(void (^)(NSString * count,NSError * _Nonnull error))completion;

- (void)updateAllMessageStateCompletion:(void (^)(BOOL result,NSError * _Nonnull error))completion;

#pragma mark - 语意接口

- (void)speechAnalyseWithUid:(NSString *)uid speech:(NSString *)speech deviceList:(NSArray<AUXAudioDevice *> *)deviceList completion:(void (^)(NSString * _Nullable answer, NSMutableArray<NSNumber *> *cmdTypeList, NSArray<AUXAnswerAudioDevice *> * _Nullable deviceList, NSError * _Nullable error))completion;

#pragma mark - 首页

/**
 查询首页版本信息
 
 @param completion -- homepageVersionInfo 首页版本信息
 */
- (void)getHomepageVersionInfoWithCompletion:(void (^)(AUXHomepageVersionInfo * _Nullable homepageVersionInfo, NSError *error))completion;

/**
 下载首页
 
 @param zipUri 压缩包地址
 @param savePath 压缩包保存路径
 @param completion -- filePath 压缩包本地保存路径
 */
- (void)downloadHomepage:(NSString *)zipUri savePath:(NSString *)savePath completion:(void (^)(NSURL * _Nullable filePath, NSError * _Nullable error))completion;

/**
 qq用户登录
 
 @param token 验证token
 @param openId 用户id
 
 */
- (void)loginBy3rdWithSrc:(NSString *)src code:(NSString *)code token:(NSString *)token openId:(NSString *)openId completion:(void (^)(AUXUser * _Nullable user, NSString * _Nullable token, NSString * _Nullable openId, NSError * _Nonnull error))completion;

- (void)bindAccountWithUid:(NSString *)uid phone:(NSString *)phone smsCode:(NSString *)smsCode completion:(void (^)(NSError * _Nonnull error))completion;

#pragma mark 场景
/**
 创建场景
 */
- (void)createSceneWith:(AUXSceneAddModel *)sceneAddModel completion:(void (^)(AUXSceneDetailModel *detailModel , NSError *error))completion;
/**
 用户首页场景列表
 */
- (void)homePagelistSceneCompletion:(void (^)(NSArray<AUXSceneDetailModel *>* detailModelList , NSError * error))completion;

/**
 场景首页列表
 */
- (void)listSceneWithKey:(NSString *)key Completion:(void (^)(NSArray<AUXSceneDetailModel *>* detailModelList , NSError * error))completion;

/**
 执行手动场景
 
 @param sceneId 场景ID
 */
- (void)manualSceneWithSceneId:(NSString *)sceneId completion:(void (^)(BOOL result , NSError * error))completion;
/**
 执行位置场景
 */
- (void)placeSceneWithSceneId:(NSString *)sceneId completion:(void (^)(BOOL success , NSError * error))completion;

/**
 获取开启的位置场景列表
 */
- (void)openPlaceSceneWithCompletion:(void (^)(NSArray<AUXSceneDetailModel *>* detailModelList , NSError * error))completion;

/**
 获取自动场景列表和手动场景列表
 
 @param key 关键字 可为nil
 */
- (void)getAutoAndManualListSceneWithKey:(NSString *)key completion:(void (^)(NSArray <NSMutableArray <AUXSceneDetailModel *>*>* detailModelList , NSError * error))completion;
/**
 场景详情
 */
- (void)detailSceneWithSceneId:(NSString *)sceneId completion:(void (^)(AUXSceneDetailModel *detailModel , NSError * error))completion;
/**
 编辑场景
 */
- (void)editSceneWithSceneId:(NSString *)sceneId sceneAddModel:(AUXSceneAddModel *)sceneAddModel completion:(void (^)(AUXSceneDetailModel *detailModel , NSError *error))completion;
/**
 关闭或打开场景
 */
- (void)powerSceneWithSceneId:(NSString *)sceneId state:(NSInteger)state completion:(void (^)(AUXSceneDetailModel *detailModel , NSError * error))completion;

/**
 编辑场景名称
 */
- (void)renameSceneWithSceneId:(NSString *)sceneId sceneName:(NSString *)sceneName completion:(void (^)(AUXSceneDetailModel *detailModel , NSError * error))completion;

/**
 删除场景
 */
- (void)deleteSceneWithSceneId:(NSString *)sceneId completion:(void (^)(BOOL result , NSError * error))completion;


/**
 获取场景日志
 
 @param page 页码
 @param size 长度
 @param completion 返回日志model
 */
-(void)getSceneHistroyWithpage:(NSInteger)page Size:(NSInteger)size compltion:(void (^) (NSDictionary * dic, NSError * error))completion;
#pragma mark - App最新版本信息
/**
 获取App最新版本信息
 
 @param completion 返回回调
 */
- (void)getAppVersionInfoWithCompletion:(void (^)(AUXAppVersionModel * _Nullable appVersionModel, NSError *error))completion;

#pragma mark 获取售后的购买地址
- (void)getAfterSaleChanneltypeCompletion:(void(^)(NSArray <AUXChannelTypeModel *> *channelTypeList))completion;

#pragma mark 获取商城的配置文件
- (void)getStoreConfigurationModelWithCompletion:(void (^) (AUXStoreDomainModel *storeModel , NSError * error))completion;

#pragma mark 意见反馈
- (void)saveFeedBackInfo:(NSDictionary *)dict compltion:(void (^) (BOOL result, NSError *error))completion;

#pragma mark  获取意见反馈的列表
- (void)getFeedbackcompltion:(void (^) (NSDictionary *dic, NSError *error))completion;

#pragma mark  获取意见反馈详情
- (void)getFeedbackDetailByfeedbackId:(NSString*)feedbackId page:(NSInteger)page size:(NSInteger)size compltion:(void (^) (NSDictionary *dic, NSError *error))completion;

#pragma mark  留言上报
- (void)postFeedbackReplyWithDic:(NSDictionary*)dic compltion:(void (^) (BOOL result, NSError *error))completion;


#pragma mark 消息限制
/**
 获取消息限制相信信息
 */
-(void)getPushLimitDetailWithCompltion:(void (^) (AUXPushLimitModel *model , NSError *error))completion;

/**
 更新消息限制
 
 @param model 更新的数据
 */
- (void)updatePushLimitWithModel:(AUXPushLimitModel *)model compltion:(void (^) (AUXPushLimitModel *model , NSError *error))completion;

/**
 设备列表获取所有广告数据
 
 @param completion 获取的数据
 */
- (void)getAllAdvertisingDataCompletion:(void (^)(NSArray <AUXLaunchAdModel *> *array , NSError *error))completion;

/**
 获取当前显示的广告数据
 
 @param completion 完成回调
 */
- (void)getCurrentAdvertisingDataCompletion:(void (^)(AUXLaunchAdModel *model , NSError *error))completion;

#pragma mark  电子说明书


/**
获取所有电子说明书

 @param version 版本
 @param completion 返回所有电子说明书
 */
- (void)getAllelectronicUrlsByVersion:(NSString*)version completion:(void (^)(NSArray *array, NSError * _Nonnull error, NSString *resultversion,NSInteger code))completion;


- (void)getOneElectronicUrlByparameters:(NSDictionary*)parameters completion:(void (^)(NSDictionary *resultDic,NSError * _Nonnull error))completion;
@end

NS_ASSUME_NONNULL_END



