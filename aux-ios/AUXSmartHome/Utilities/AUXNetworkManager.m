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

#import "AUXNetworkManager.h"
#import "AUXLocalNetworkTool.h"
#import "AUXConstant.h"
#import "RACEXTScope.h"
#import "AUXConfiguration.h"
#import "AUXArchiveTool.h"
#import "AUXAdvertisingCache.h"

#import "NSError+AUXCustom.h"
#import "NSDate+AUXCustom.h"

#import <UMAnalytics/MobClick.h>
#import <MagicalRecord/MagicalRecord.h>
#import <AUXACNetwork/AUXACCBridge.h>
#import "AUXMobileInformationTool.h"

//外网
static NSString * const kAUXBaseURL = @"https://smarthome.aux-home.com";
//外网从测试服务器
//static NSString * const kAUXBaseURL = @"http://jdznjjtest.auxgroup.com";
//李肖肖的地址
//static NSString * const kAUXBaseURL = @"http://10.2.41.65:12342";
//内网
//static NSString * const kAUXBaseURL = @"http://10.88.2.224:12342";
//吴建龙的地址
//static NSString * const kAUXBaseURL = @"http://192.168.31.128:12342";
//支马楠的地址
//static NSString * const kAUXBaseURL = @"http://10.2.25.106:12342";
//吴建龙集中控制地址
//static NSString * const kAUXBaseURL = @"http://10.88.2.222";
//正式测试
//static NSString * const kAUXBaseURL = @"http://47.99.148.208:12342";
//傅东伟的日志
//static NSString * const kAUXBaseURL = @"http://10.2.26.139:12342";


//天气接口
static NSString * const kAUXWeatherURL = @"https://air.iotsdk.com?forWhat=Weather";
//商城配置文件
static NSString * const kAUXStoreURL = @"https://saas-app.oss-cn-hangzhou.aliyuncs.com/app/config/EShop_Url_Config_https.json";
//售后的购买单位
static NSString * const kAUXAfterSaleChannelTypeURL = @"https://saas-app.oss-cn-hangzhou.aliyuncs.com/app/config/Artersale_Channeltype_Config.json";

//用户相关
static NSString * const kAUXURLPathAccessToken = @"app/access_token";
//static NSString * const kAUXURLPathAccessToken = @"app/user_access";
static NSString * const kAUXURLPathLogin = @"app/login";
static NSString * const kAUXURLPathLogout = @"app/logout";
static NSString * const kAUXURLPathRegister = @"app/register";
static NSString * const kAUXURLPathForgetPwd = @"app/pwd_sms_code";
static NSString * const kAUXURLPathRegistry = @"app/registry_sms_code";
static NSString * const kAUXURLPathThirdBindAccount = @"app/bind_sms_code";
static NSString * const kAUXURLPathResetPassword = @"app/reset_password";
static NSString * const kAUXURLPathModifyPassword = @"app/modify_password";
static NSString * const kAUXURLPathUserInfo = @"app/users";
static NSString * const kAUXURLPathPortrait = @"app/alicloud/uploadFile";
// 首页
static NSString * const kAUXURLPathHomepage = @"app/newest_index_page";
// 设备
static NSString * const kAUXURLPathDevice = @"app/device";
static NSString * const kAUXURLPathDeviceBindings = @"app/device_bindings";
static NSString * const kAUXURLPathDeviceBindingsNew = @"app/device_bindings_new";
// 集中控制
static NSString * const kAUXURLPathMultiFunctionList = @"app/multi_function_list/list";
// 定时
static NSString * const kAUXURLPathSchedule = @"app/schedule";
static NSString * const kAUXURLPathSchedules = @"app/schedules";
// 睡眠DIY
static NSString * const kAUXURLPathSleep = @"app/sleep";
static NSString * const kAUXURLPathSleepSwitch = @"app/sleep/switch";
static NSString * const kAUXURLPathSleepCloseAll = @"app/sleep/switch/close_all";
// 设备分享
static NSString * const kAUXURLPathMultiDeviceShare = @"app/devices/sharing";
static NSString * const kAUXURLPathDeviceShare = @"app/devices/sharing";
//场景
static NSString * const kAUXURLPathSceneAdd = @"app/scenes";
static NSString * const kAUXURLPathSceneHomePage = @"app/scenes/ownerHomepage";
static NSString * const kAUXURLPathSceneOwner = @"app/scenes/owner";
static NSString * const kAUXURLPathSceneOwnerPart = @"app/scenes/ownerPart";
static NSString * const kAUXURLPathSceneManual = @"app/scenes/Manual";
static NSString * const kAUXURLPathScenePlace = @"app/scenes/place";
static NSString * const kAUXURLPathSceneDelete = @"app/scenes";
static NSString * const kAUXURLPathSceneDetail = @"app/scenes";
static NSString * const kAUXURLPathSceneEdit = @"app/scenes";
static NSString * const kAUXURLPathSceneCloseOpen = @"app/scenes";
static NSString * const kAUXURLPathSceneRename = @"app/scenes";
static NSString * const kAUXURLPathSceneOpenPlace = @"app/scenes/openPlace";
static NSString * const kAUXURLPathSaveSceneCenterControl = @"app/scenes_central";//保存集中控制
static NSString * const kAUXURLPathReSetSceneCenterControl = @"app/scenes_central";//重置中控制

static NSString * const kAUXURLPathScenelog = @"app/scene_history?";//场景日志





//意见反馈
static NSString * const kAUXURLPathFeedBackURL = @"app/feedback_log";
static NSString * const kAUXURLPathFeedBackListURL = @"app/feedback/list";
static NSString * const kAUXURLPathFeedBackDetailURL = @"app/feedback/detail";
static NSString * const kAUXURLPathFeedBackDetailReplyURL = @"app/feedback/reply";



//生成剪切板信息
static NSString * const kAUXURLPathDeviceShareNew = @"app/devices/sharing/createClipbordShare";
//根据剪切板信息分享设备
static NSString * const kAUXURLPathDeviceShareToPeople = @"app/devices/sharing/decodeClipbordShare";
//获取剪切板信息分享设备
static NSString * const kAUXURLPathDeviceShareGetDeviceFromClipbordShare = @"app/devices/sharing/getClipbordShare";

static NSString * const kAUXURLPathDeviceShareList = @"app/devices/sharing/list";
static NSString * const kAUXURLPathDeviceShareQRCode = @"app/devices/sharing/qrcode";
static NSString * const kAUXURLPathDeviceShareSubuser = @"app/devices/sharing/sub_user";
static NSString * const kAUXURLPathDeviceHomeShareList = @"app/devices/sharing/family_center/family";
static NSString * const kAUXURLPathDeviceFriendShareList = @"app/devices/sharing/family_center/friends";
// 获取家庭中心-用户分享
static NSString * const kAUXURLPathDeviceUserShareList = @"app/devices/sharing/family_center/devices";
static NSString * const kAUXURLPathDeviceUserShareDelete = @"app/devices/sharing/family_center/devices/relieve";
// SN码、设备型号
static NSString * const kAUXURLPathDeviceSN = @"app/device/sn";
static NSString * const kAUXURLPathDeviceModel = @"app/products/all_models";
// 峰谷节电
static NSString * const kAUXURLPathSaveElectricity = @"app/peak_valley";
// 用电曲线
static NSString * const kAUXURLPathElectricityCurve = @"app/peak_valley_curve";
// 智能用电
static NSString * const kAUXURLPathSmartElectricity = @"app/smart_electricity";
// 故障、滤网
static NSString * const kAUXURLPathFault = @"app/devices/faults";
static NSString * const kAUXURLPathHistoryFault = @"app/devices/faultsHis";
static NSString * const kAUXURLPathFilter = @"app/confirm_filter_washed";
static NSString * const kAUXURLPathReportFault = @"app/device_fault";
// 配网失败信息
static NSString * const kAUXURLPathReportConnectFault = @"app/device_connect_json";
// 推送消息
static NSString * const kAUXURLPathMessage = @"/app/pushRecord/listNew";
static NSString * const kAUXURLPathMessageNoRead = @"/app/pushRecord/notReadCount";
static NSString * const kAUXURLPathMessageHaveBeenReaded = @"/app/pushRecord/updateAllReadState";

//最新版本信息
static NSString * const kAUXURLPathAppVersion = @"app/app_version";
// 第三方登录
static NSString * const kAUXURL3rdLogin = @"app/otherLogin";
static NSString * const kAUXURLBindAccount = @"app/bindOther";

//第三方登录跳过手机号
static NSString* const kAUXURL3rdLoginSkipPhone = @"app/otherLoginSkipPhone";
static NSString* const kAUXURLBindSkipPhoneAccount = @"app/bindOtherSkipPhone";

//消息限制
static NSString* const kAUXURLPushLimitDetail = @"app/appPushLimit/detail";
static NSString* const kAUXURLPushLimitUpdate = @"app/appPushLimit/setSilenceTime";

//开屏广告
static NSString* const kAUXURLPathAllAd = @"app/deviceListAds";
static NSString* const kAUXURLPathCurrentAd = @"app/welcomeAds";

// field key
static NSString * const kAUXFieldCode = @"code";
static NSString * const kAUXFieldMessage = @"message";
static NSString * const kAUXFieldData = @"data";
static NSString * const kAUXFieldContent = @"content";
static NSString * const kAUXFieldPhone = @"phone";
static NSString * const kAUXFieldPassword = @"password";
static NSString * const kAUXFieldNewPassword = @"newPassword";
static NSString * const kAUXFieldDeviceId = @"deviceId";
static NSString * const kAUXFieldSleepDiyId = @"sleepDiyId";
static NSString * const kAUXFieldOn = @"on";

//电子说明书
static NSString * const kAUXURLAllElectronicSpecification = @"app/electronicUrls";
static NSString * const kAUXURLOneElectronicSpecification = @"app/electronicUrl";

@interface AUXNetworkManager ()
@property (nonatomic,assign) NSInteger breakRecursiveIndex;
@end

@implementation AUXNetworkManager

+ (instancetype)manager {
    static AUXNetworkManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUXNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:kAUXBaseURL]];
        
        [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"If-None-Match"];
    });
    
    return manager;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"charset=UTF-8",nil];
        self.requestSerializer.timeoutInterval = 60;
        NSString *accessToken = [AUXUser defaultUser].accessToken;
        if ([accessToken length] > 0) {
            [self setupAuthorizationHeader:accessToken];
        }
    }
    
    return self;
}

- (NSMutableDictionary *)handleSuccessWithResponseObject:(nullable id)responseObject {
    
    NSError *error = nil;
    
    NSInteger code = -9999;
    NSString *message = @"Reserve";
    
    id dataObject = nil;
    
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        code = [responseDict[kAUXFieldCode] integerValue];
        message = responseDict[kAUXFieldMessage];
        
        if (code == AUXNetworkErrorNone) {
            dataObject = responseDict[kAUXFieldData];
        }
    }
    
    error = [NSError errorWithCode:code message:message];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (dataObject) {
        [dict setObject:dataObject forKey:@"dataObject"];
    }
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    return dict;
}

- (void)mobClickStatisticalEventWithParames:(NSDictionary *)parameters urlString:(NSString *)URLString method:(NSString *)method {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (URLString) {
        [dict setObject:URLString forKey:@"URLString"];
    }
    
    NSMutableString *urlString = [dict[@"URLString"] mutableCopy];
    NSString *string;
    
    NSArray *urlArray = [urlString componentsSeparatedByString:@"/"];
    
    if ([urlString hasPrefix:kAUXBaseURL]) {
        if (urlArray[1] != nil) {
            string = urlArray[1];
            if ([string isEqualToString:@"app"]) {
                if (urlArray[2]) {
                    string = urlArray[2];
                }
            }
        }
    } else {
        string = [urlArray lastObject];
    }
    string = [NSString stringWithFormat:@"%@/%@" , method, string];
    [dict setValue:string forKey:@"URLString"];
    [MobClick event:@"request" attributes:dict];
}

- (void)PUTWithDataTaskWithUrlString:(NSString *)urlString Parameters:(NSDictionary *)parameters completion:(AUXNetworkCompletionHandler)completion {
    
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:urlString method:@"PUT"];
    
    NSString *accessToken = [AUXUser defaultUser].accessToken;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"PUT" URLString:urlString parameters:nil error:NULL];
    request.timeoutInterval = 60;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    [request setHTTPBody:jsonData];
    [request setValue:[NSString stringWithFormat:@"bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    
    sessionManager.responseSerializer = responseSerializer;
    
    @weakify(self);
    [[sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if ([self whtherNeedNewAccesstoken:error]) {
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self PUTWithDataTaskWithUrlString:urlString Parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        if (completion) {
            completion(responseObject , error);
        }
        
    }] resume];
}

- (void)POSTWithDataTaskWithUrlString:(NSString *)urlString Parameters:(NSDictionary *)parameters completion:(AUXNetworkCompletionHandler)completion {
    
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:urlString method:@"POST"];
    
    NSString *accessToken = [AUXUser defaultUser].accessToken;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:nil error:NULL];
    request.timeoutInterval = 60;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:jsonData];
    [request setValue:[NSString stringWithFormat:@"bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    
    sessionManager.responseSerializer = responseSerializer;
    
    @weakify(self);
    [[sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if ([self whtherNeedNewAccesstoken:error]) {
            
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self POSTWithDataTaskWithUrlString:urlString Parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        if (completion) {
            completion(responseObject , error);
        }
        
    }] resume];
}

- (void)POSTWithoutCheckingAccessToken:(NSString *)URLString parameters:(id)parameters completion:(void (^)(id _Nullable responseObject, NSError * _Nullable responseError))completion {
    
    [self mobClickStatisticalEventWithParames:parameters urlString:URLString method:@"POST"];
    [self POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)POST:(NSString *)URLString parameters:(id)parameters completion:(AUXNetworkCompletionHandler)completion {
    
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:URLString method:@"POST"];
    @weakify(self);
    
    [self POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        NSMutableDictionary *dict = [self handleSuccessWithResponseObject:responseObject];
        
        id dataObject = dict[@"dataObject"];
        NSError *error = dict[@"error"];
        
        if ([self whtherNeedNewAccesstoken:error]) {
            
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self POST:URLString parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        self.breakRecursiveIndex = 0;
        if (completion && error.code != AUXNetworkErrorAccountCacheExpired) {
            completion(dataObject , error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)GET:(NSString *)URLString parameters:(id)parameters completion:(AUXNetworkCompletionHandler)completion {
    
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    if ((self.networkRequestType & AUXNetworkRequestTypeAccessToken) != 0) { //正在更新 token
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:URLString method:@"GET"];
    
    
    self.requestSerializer.timeoutInterval = 60;

    @weakify(self);
    [self GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        NSMutableDictionary *dict = nil;
        id dataObject = nil;
        NSError *error = nil;
        if ([URLString containsString:@"app/electronicUrls/v"]) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                dict = [(NSDictionary *)responseObject mutableCopy];
                dataObject = dict;
                error = dict[@"error"];
            }
        }else{
            dict = [self handleSuccessWithResponseObject:responseObject];
            dataObject = dict[@"dataObject"];
            error = dict[@"error"];
        }
        
        
        
        if ([self whtherNeedNewAccesstoken:error]) {
            
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self GET:URLString parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        self.breakRecursiveIndex = 0;
        if (completion && error.code != AUXNetworkErrorAccountCacheExpired) {
            completion(dataObject , error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)PUT:(NSString *)URLString parameters:(id)parameters completion:(AUXNetworkCompletionHandler)completion {
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:URLString method:@"PUT"];
    @weakify(self);
    [self PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        NSMutableDictionary *dict = [self handleSuccessWithResponseObject:responseObject];
        
        id dataObject = dict[@"dataObject"];
        NSError *error = dict[@"error"];
        
        if ([self whtherNeedNewAccesstoken:error]) {
            
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self PUT:URLString parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        self.breakRecursiveIndex = 0;
        if (completion && error.code != AUXNetworkErrorAccountCacheExpired) {
            
            completion(dataObject , error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)DELETE:(NSString *)URLString parameters:(id)parameters completion:(AUXNetworkCompletionHandler)completion {
    
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:URLString method:@"DELETE"];
    @weakify(self);
    [self DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        NSMutableDictionary *dict = [self handleSuccessWithResponseObject:responseObject];
        
        id dataObject = dict[@"dataObject"];
        NSError *error = dict[@"error"];
        
        if ([self whtherNeedNewAccesstoken:error]) {
            
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self DELETE:URLString parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        self.breakRecursiveIndex = 0;
        if (completion && error.code != AUXNetworkErrorAccountCacheExpired) {
            completion(dataObject , error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)PATCH:(NSString *)URLString parameters:(id)parameters completion:(AUXNetworkCompletionHandler)completion {
    
    if ([self accesstokenExpire:completion]) {
        return ;
    }
    
    [self mobClickStatisticalEventWithParames:parameters urlString:URLString method:@"PATCH"];
    @weakify(self);
    [self PATCH:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        NSMutableDictionary *dict = [self handleSuccessWithResponseObject:responseObject];
        
        id dataObject = dict[@"dataObject"];
        NSError *error = dict[@"error"];
        
        if ([self whtherNeedNewAccesstoken:error]) {
            
            [self getAccessToken:^(NSError * _Nonnull error) {
                @strongify(self);
                
                if (error.code == AUXNetworkErrorNone) {
                    self.breakRecursiveIndex++;
                    [self PATCH:URLString parameters:parameters completion:completion];
                } else {
                    if (completion) {
                        completion(nil, error);
                    }
                }
            }];
            
            return ;
        }
        
        self.breakRecursiveIndex = 0;
        if (completion && error.code != AUXNetworkErrorAccountCacheExpired) {
            completion(dataObject , error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)setupAuthorizationHeader:(NSString *)accessToken {
    [self.requestSerializer clearAuthorizationHeader];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
}

- (BOOL)accesstokenExpire:(AUXNetworkCompletionHandler)completion {
    if (self.breakRecursiveIndex > 3) {
        self.breakRecursiveIndex = 0;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccessTokenDidExpireNotification object:nil];
        NSError *error = [NSError errorWithCode:60106 message:@"用户账号缓存过期"];
        if (completion) {
            completion(nil, error);
        }
        return YES;
    }
    return NO;
}

#pragma mark - 服务器接口

- (void)clearAuthorization {
    [self.requestSerializer clearAuthorizationHeader];
}

- (BOOL)whtherNeedNewAccesstoken:(NSError *)error {
    
    if (error.code == AUXNetworkErrorExpiredAccessToken || error.code == AUXNetworkErrorInvalidAccessToken || error.code == AUXNetworkErrorUnAuthorized) {
        return YES;
    }
    
    if (error.code == AUXNetworkErrorAccountCacheExpired) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccessTokenDidExpireNotification object:nil];
        return NO;
    }
    
    return NO;
}

- (void)getAccessToken:(void (^)(NSError * _Nonnull))completion {
    
    NSLog(@"获取token值   getAccessToken  %@",    [AUXUser defaultUser].accessToken);
    
    if ((self.networkRequestType & AUXNetworkRequestTypeAccessToken) != 0) { //正在更新 token
        return ;
    }
//    NSString *UUIDString = [AUXUser UUIDString];
    NSString *UUIDString = [AUXMobileInformationTool getDeviceIDInKeychain];//获取永久性UUID的方法
    NSDictionary *parameters = @{@"clientId": UUIDString, @"appid": kAUXAppId};
    
    self.networkRequestType |= AUXNetworkRequestTypeAccessToken;
    
    @weakify(self);
    [self POSTWithoutCheckingAccessToken:kAUXURLPathAccessToken parameters:parameters completion:^(id _Nullable responseObject, NSError * _Nullable responseError) {
        @strongify(self);
        self.networkRequestType ^= AUXNetworkRequestTypeAccessToken;
        
        NSError *error = nil;
        NSString *paasToken = nil;
        NSString *saasToken = nil;
        
        if (!responseError) {
            //NSLog(@"获取 access token 结果 %@", responseObject);
            
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            NSInteger code = -9999;
            NSString *message = @"Reserve";
            
            if (responseDict) {
                code = [responseDict[kAUXFieldCode] integerValue];
                message = responseDict[kAUXFieldMessage];
                
                if (code == AUXNetworkErrorNone) {
                    NSDictionary *dataDict = responseDict[kAUXFieldData];
                    
                    //                    paasToken = dataDict[@"paasToken"];
                    //                    saasToken = dataDict[@"saasToken"];
                    
                    saasToken = dataDict[@"accessToken"];
                    AUXUser *user = [AUXUser defaultUser];
                    user.accessToken = saasToken;
                    //                    user.token = paasToken;
                    [AUXUser archiveUser];
                    
                    [self setupAuthorizationHeader:saasToken];
                }
            }
            
            error = [NSError errorWithCode:code message:message];
        } else {
            if (responseError.code == -1009) {  //无网络环境
                error = responseError;
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:AUXAccessTokenDidExpireNotification object:nil];
                return ;
            }
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark 用户

- (void)userLoginWithAccount:(NSString *)account password:(NSString *)password completion:(void (^)(AUXUser * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldPhone: account,
                                 kAUXFieldPassword: password};
    
    self.networkRequestType |= AUXNetworkRequestTypeLogin;
    
    @weakify(self);
    [self POST:kAUXURLPathLogin parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        @strongify(self);
        self.networkRequestType ^= AUXNetworkRequestTypeLogin;
        
        AUXUser *user = nil;
        
        if (responseObject) {
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            
            NSDictionary *userDict = dataDict[@"appUser"];
            NSDictionary *apiDict = dataDict[@"openApiToken"];
            
            user = [AUXUser defaultUser];
            
            if (userDict) {
                [user yy_modelSetWithDictionary:userDict];
            }
            
            if (apiDict) {
                [user yy_modelSetWithDictionary:apiDict];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                // 更新用户头像后保存
                user.portrait = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:user.headImg]];
                [AUXUser archiveUser];
            });
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkManagerDidLogin:error:)]) {
            [self.delegate networkManagerDidLogin:user error:responseError];
        } else if (completion) {
            completion(user, responseError);
        }
    }];
}

- (void)userLogoutWithcompletion:(void (^)(NSError * _Nonnull))completion {
    
    [self GET:kAUXURLPathLogout parameters:nil completion:^(id _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)registerWithAccount:(NSString *)account password:(NSString *)password code:(NSString *)code completion:(void (^)(AUXUser * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldPhone: account,
                                 kAUXFieldCode: code,
                                 kAUXFieldPassword: password};
    
    [self POST:kAUXURLPathRegister parameters:parameters completion:^(id _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXUser *user = nil;
        
        if (responseObject) {
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            
            NSDictionary *userDict = dataDict[@"appUser"];
            NSDictionary *apiDict = dataDict[@"openApiToken"];
            
            user = [AUXUser defaultUser];
            
            if (userDict) {
                [user yy_modelSetWithDictionary:userDict];
            }
            
            if (apiDict) {
                [user yy_modelSetWithDictionary:apiDict];
            }
            
            // 重置头像
            user.portrait = nil;
            [AUXUser archiveUser];
        }
        
        if (completion) {
            completion(user, responseError);
        }
    }];
}

- (void)registryPhone:(NSString *)phone completion:(void (^)(NSString *code , NSError * _Nonnull error))completion {
    NSDictionary *parameters = @{@"phone" : phone};
    [self POST:kAUXURLPathRegistry parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSString *code;
        if (responseObject) {
            code = responseObject;
        }
        
        if (completion) {
            completion(code , responseError);
        }
    }];
}

- (void)thirdBindAccountSMSCode:(NSString *)phone completion:(void (^)(NSError * _Nonnull error))completion {
    NSDictionary *parameters = @{@"phone" : phone};
    [self POST:kAUXURLPathThirdBindAccount parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)forgetPwdPhone:(NSString *)phone completion:(void (^)(NSString *code , NSError * _Nonnull error))completion {
    NSDictionary *parameters = @{@"phone" : phone};
    [self POST:kAUXURLPathForgetPwd parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSString *code;
        if (responseObject) {
            code = responseObject;
        }
        
        if (completion) {
            completion(code , responseError);
        }
    }];
}

- (void)resetPasswordWithAccount:(NSString *)account password:(NSString *)password code:(NSString *)code completion:(void (^)(NSError * _Nonnull))completion {
    NSDictionary *parameters = @{kAUXFieldPhone: account,
                                 kAUXFieldCode: code,
                                 kAUXFieldNewPassword: password};
    
    [self PUT:kAUXURLPathResetPassword parameters:parameters completion:^(id _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)changePasswordWithPasswordOld:(NSString *)passwordOld passwordNew:(NSString *)passwordNew completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{@"oldPassword": passwordOld,
                                 @"newPassword": passwordNew};
    
    [self PUT:kAUXURLPathModifyPassword parameters:parameters completion:^(id _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)getUserInfoWithCompletion:(void (^)(AUXUser * user, NSError *error))completion {
    [self GET:kAUXURLPathUserInfo parameters:@{} completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXUser *user = [AUXUser defaultUser];
        
        if (responseObject) {
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            
            if (dataDict) {
                [user yy_modelSetWithDictionary:dataDict];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                // 更新用户头像后保存
                user.portrait = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:user.headImg]];
                [AUXUser archiveUser];
            });
        }
        
        if (completion) {
            completion(user , responseError);
        }
    }];
}

- (void)updateUserInfoWithUser:(AUXUser *)user completion:(void (^)(NSError *error))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"country": @"中国"}];
    if (user.nickName) {
        [parameters setObject:user.nickName forKey:@"nickName"];
    }
    if (user.realName) {
        [parameters setObject:user.realName forKey:@"realName"];
    }
    if (user.gender) {
        [parameters setObject:user.gender forKey:@"gender"];
    }
    if (user.region) {
        [parameters setObject:user.region forKey:@"region"];
    }
    if (user.city) {
        [parameters setObject:user.city forKey:@"city"];
    }
    if ([user.birthday length] == 10) {
        [parameters setObject:user.birthday forKey:@"birthday"];
    }
    if (user.headImg && [user.headImg hasPrefix:@"http"]) {
        [parameters setObject:user.headImg forKey:@"headImg"];
    }
    
    [self PUT:kAUXURLPathUserInfo parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        if (responseObject) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [AUXUser defaultUser].portrait = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:user.headImg]];
                [AUXUser archiveUser];
            });
        }
        
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)updatePortrait:(NSData *)portrait progress:(void (^)(NSProgress *uploadProgress))progress completion:(void (^)(NSString * _Nullable path, NSError * _Nullable error))completion
{
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathPortrait] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", [formatter stringFromDate:[NSDate date]]];
        [formData appendPartWithFileData:portrait name:@"uploadFile" fileName:fileName mimeType:@"image/png"];
    } error:nil];
    request.timeoutInterval = 60;
    [request setValue:[NSString stringWithFormat:@"bearer %@", [AUXUser defaultUser].accessToken] forHTTPHeaderField:@"Authorization"];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", nil];
    sessionManager.responseSerializer = responseSerializer;
    
    [[sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%@", uploadProgress);
        if (progress) {
            progress(uploadProgress);
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //        //NSLog(@"%@", response);
        //NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        //NSLog(@"%@", error);
        
        NSString *path;
        if (!error) {
            if (responseObject) {
                NSDictionary *responseDic = [responseObject objectFromJSONData];
                int code = [responseDic[kAUXFieldCode] intValue];
                if (code == AUXNetworkErrorNone) {
                    NSDictionary *dataDic = responseDic[kAUXFieldData];
                    path = dataDic[@"path"];
                } else {
                    error = [NSError errorWithCode:code message:responseDic[kAUXFieldMessage]];
                }
            }
        }
        
        if (completion) {
            completion(path, error);
        }
    }] resume];
}

#pragma mark SN码、设备型号

- (void)getDeviceModelWithSN:(NSString *)deviceSN completion:(void (^)(AUXDeviceModel * _Nullable, NSError * _Nonnull))completion {
    
    NSString *path = [kAUXURLPathDeviceSN stringByAppendingPathComponent:deviceSN];
    
    [self GET:path parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXDeviceModel *deviceModel = nil;
        
        if (responseObject) {
            //            //NSLog(@"获取设备型号结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            
            deviceModel = [AUXDeviceModel yy_modelWithDictionary:dataDict];
            [[AUXConfiguration sharedInstance].deviceModelDictionary setObject:deviceModel forKey:deviceSN];
        } else {
            //            //NSLog(@"获取设备型号失败 %@", responseError);
        }
        
        if (completion) {
            completion(deviceModel, responseError);
        }
    }];
}

- (void)getDeviceModelListWithCompletion:(void (^)(NSArray<AUXDeviceModel *> * _Nullable, NSError * _Nonnull))completion {
    
    [self GET:kAUXURLPathDeviceModel parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXDeviceModel *> *deviceModelList = nil;
        
        if (responseObject) {
            //            //NSLog(@"获取设备型号列表结果 %@", responseObject);
            NSArray *dataArray = (NSArray *)responseObject;
            deviceModelList = [NSArray yy_modelArrayWithClass:[AUXDeviceModel class] json:dataArray];
        } else {
            //            //NSLog(@"获取设备型号列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(deviceModelList, responseError);
        }
    }];
}

#pragma mark 设备

- (void)bindDeviceWithDeviceInfo:(AUXDeviceInfo *)deviceInfo completion:(void (^)(NSString * _Nullable, NSError * _Nonnull))completion {
    NSString *urlString = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathDeviceBindings];
    NSDictionary *dict = (NSDictionary *)[deviceInfo yy_modelToJSONObject];
    [self POSTWithDataTaskWithUrlString:urlString Parameters:dict completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSError *serverError = nil;
        NSString *deviceId = nil;
        
        if (!responseError) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            //            //NSLog(@"绑定设备结果 %@", responseDict);
            
            NSInteger code = -9999;
            NSString *message = @"Reserve";
            
            if (responseDict) {
                code = [responseDict[kAUXFieldCode] integerValue];
                message = responseDict[kAUXFieldMessage];
                
                if (code == AUXNetworkErrorNone) {
                    NSDictionary *dataDict = responseDict[kAUXFieldData];
                    deviceId = dataDict[kAUXFieldDeviceId];
                }
            }
            
            serverError = [NSError errorWithCode:code message:message];
        } else {
            serverError = responseError;
            //            //NSLog(@"绑定设备失败 %@", error);
        }
        
        if (completion) {
            completion(deviceId, serverError);
        }
    }];
}

- (void)unbindDeviceWithDeviceId:(NSString *)deviceId completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldDeviceId: deviceId};
    
    [self DELETE:kAUXURLPathDeviceBindings parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)getDeviceListWithCompletion:(void (^)(NSArray<AUXDeviceInfo *> * _Nullable, NSError * _Nonnull))completion {
    
    self.networkRequestType |= AUXNetworkRequestTypeDeviceList;
    
    @weakify(self);
    [self GET:kAUXURLPathDeviceBindings parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        @strongify(self);
        self.networkRequestType ^= AUXNetworkRequestTypeDeviceList;
        
        NSArray<AUXDeviceInfo *> *deviceInfoList = nil;
        
        if (responseObject) {
            //            //NSLog(@"获取设备列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            deviceInfoList = [NSArray yy_modelArrayWithClass:[AUXDeviceInfo class] json:dataArray];
        } else {
            //            //NSLog(@"获取设备列表失败 %@", responseError);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkManagerDidGetDeviceList:error:)]) {
            [self.delegate networkManagerDidGetDeviceList:deviceInfoList error:responseError];
        } else if (completion) {
            completion(deviceInfoList, responseError);
        }
    }];
}

- (void)updateDeviceInfoWithMac:(NSString *)mac deviceSN:(NSString *)deviceSN alias:(NSString *)alias completion:(void (^)(NSError * _Nonnull))completion {
    
    NSString *path = [kAUXURLPathDevice stringByAppendingPathComponent:mac];
    
    NSDictionary *parameters;
    
    if (deviceSN) {
        parameters = @{@"sn": deviceSN};
    } else if (alias) {
        parameters = @{@"alias": alias};
    }
    
    [self PUT:path parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark 集中控制

- (void)getMultiControlFunctionListWithCompletion:(void (^)(NSString * _Nullable, NSError * _Nonnull))completion {
    
    [self GET:kAUXURLPathMultiFunctionList parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *feature = nil;
        
        if (responseObject) {
            //            //NSLog(@"获取集中控制功能列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            NSDictionary *dataDict = dataArray.firstObject;
            feature = dataDict[@"feature"];
        } else {
            //            //NSLog(@"获取集中控制功能列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(feature, responseError);
        }
    }];
}

- (void)saveSceneCenterontrolWithDic:(NSDictionary*)dic compltion:(void (^) (BOOL result, NSError *error,NSDictionary *dict))completion {
    NSString *urlString = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathSaveSceneCenterControl];
    [self POSTWithDataTaskWithUrlString:urlString Parameters:dic completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        BOOL result = NO;
        NSDictionary *responseDict = nil;
        if (!responseError && responseObject !=nil) {
            responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [responseDict[kAUXFieldCode] integerValue];
            if (code == AUXNetworkErrorNone) {
                result = YES;
            } else {
                responseError = [NSError errorWithCode:code message:responseDict[kAUXFieldMessage]];
            }
        }
        if (completion) {
            completion(result , responseError,responseDict);
        }
    }];
    
}


- (void)reSetSceneCenterontrolWithSceneId:(NSString*)sceneId Dic:(NSDictionary*)dic compltion:(void (^) (BOOL result, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",kAUXBaseURL,kAUXURLPathReSetSceneCenterControl,sceneId];
    [self PUTWithDataTaskWithUrlString:urlString Parameters:dic completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (responseObject) {
        } else {
            NSLog(@"设置额名称场景失败--%@" , responseError);
        }
        if (completion) {
            completion(responseObject , responseError);
        }
        
    }];
    
    
}





#pragma mark 定时

- (void)getSchedulerListWithDeviceId:(NSString *)deviceId address:(NSString *)address completion:(void (^)(NSArray<AUXSchedulerModel *> * _Nullable, NSError * _Nonnull))completion {
    
    NSMutableDictionary *parameters = [@{kAUXFieldDeviceId: deviceId} mutableCopy];
    
    if (address && address.length > 0) {
        unsigned int uAddress = 0;
        [[NSScanner scannerWithString:address] scanHexInt:&uAddress];
        [parameters setObject:@(uAddress) forKey:@"dst"];
    }
    
    [self GET:kAUXURLPathSchedule parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXSchedulerModel *> *schedulerList = nil;
        
        if (responseObject) {
            //            //NSLog(@"获取定时列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            schedulerList = [NSArray yy_modelArrayWithClass:[AUXSchedulerModel class] json:dataArray];
        } else {
            //            //NSLog(@"获取定时列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(schedulerList, responseError);
        }
    }];
}

- (void)addSchedulerWithModel:(AUXSchedulerModel *)schedulerModel completion:(void (^)(NSString * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = [schedulerModel yy_modelToJSONObject];
    
    [self POST:kAUXURLPathSchedule parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *schedulerId = nil;
        
        if (responseObject) {
            //            //NSLog(@"添加定时结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            schedulerId = dataDict[@"id"];
        } else {
            //            //NSLog(@"添加定时失败 %@", responseError);
        }
        
        if (completion) {
            completion(schedulerId, responseError);
        }
    }];
}

- (void)updateSchedulerWithModel:(AUXSchedulerModel *)schedulerModel completion:(void (^)(NSError * _Nonnull))completion {
    NSString *path = [kAUXURLPathSchedules stringByAppendingPathComponent:schedulerModel.schedulerId];
    
    NSDictionary *parameters = [schedulerModel yy_modelToJSONObject];
    
    [self PUT:path parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)deleteSchedulerWithId:(NSString *)schedulerId completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{@"id": schedulerId};
    
    [self DELETE:kAUXURLPathSchedule parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)switchSchedulerWithId:(NSString *)schedulerId on:(BOOL)on completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{@"id": schedulerId,
                                 @"on": @(on)};
    
    [self PUT:kAUXURLPathSchedule parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark 睡眠DIY

- (void)getSleepDIYListWithDeviceId:(NSString *)deviceId completion:(void (^)(NSArray<AUXSleepDIYModel *> * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldDeviceId: deviceId};
    
    [self GET:kAUXURLPathSleep parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXSleepDIYModel *> *sleepDIYList = nil;
        
        if (responseObject) {
            //NSLog(@"获取睡眠DIY列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            sleepDIYList = [NSArray yy_modelArrayWithClass:[AUXSleepDIYModel class] json:dataArray];
        } else {
            //NSLog(@"获取睡眠DIY列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(sleepDIYList, responseError);
        }
    }];
}

- (void)addSleepDIYWithModel:(AUXSleepDIYModel *)sleepDIYModel completion:(void (^)(NSString * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = [sleepDIYModel yy_modelToJSONObject];
    
    [self POST:kAUXURLPathSleep parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *sleepDiyId = nil;
        
        if (responseObject) {
            //NSLog(@"添加睡眠DIY结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            sleepDiyId = dataDict[kAUXFieldSleepDiyId];
        } else {
            //NSLog(@"添加睡眠DIY失败 %@", responseError);
        }
        
        if (completion) {
            completion(sleepDiyId, responseError);
        }
    }];
}

- (void)updateSleepDIYWithModel:(AUXSleepDIYModel *)sleepDIYModel completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = [sleepDIYModel yy_modelToJSONObject];
    
    [self PUT:kAUXURLPathSleep parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)deleteSleepDIYWithId:(NSString *)sleepDiyId completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldSleepDiyId: sleepDiyId};
    
    [self DELETE:kAUXURLPathSleep parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)switchSleepDIYWithId:(NSString *)sleepDiyId on:(BOOL)on completion:(void (^)(NSError * _Nonnull))completion {
    NSDictionary *parameters = @{kAUXFieldOn: @(on), @"sleepDiyId": sleepDiyId};
    
    [self PUT:kAUXURLPathSleepSwitch parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)turnOffAllSleepDIYWithDeviceId:(NSString *)deviceId completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldDeviceId: deviceId};
    
    [self DELETE:kAUXURLPathSleepCloseAll parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark - 设备分享

- (void)getDeviceShareListWithDeviceId:(NSString *)deviceId completion:(void (^)(NSArray<AUXDeviceShareInfo *> * _Nullable, NSError * _Nonnull))completion {
    NSDictionary *parameters = nil;
    
    if (deviceId && deviceId.length > 0) {
        parameters = @{kAUXFieldDeviceId: deviceId};
    }
    
    [self GET:kAUXURLPathDeviceShareList parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXDeviceShareInfo *> *deviceShareInfoList = nil;
        
        if (responseObject) {
            //NSLog(@"获取设备分享列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            deviceShareInfoList = [NSArray yy_modelArrayWithClass:[AUXDeviceShareInfo class] json:dataArray];
        } else {
            //NSLog(@"获取设备分享列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(deviceShareInfoList, responseError);
        }
    }];
}


- (void)getDeviceShareSubuserListWithCompletion:(void (^)(NSArray<NSDictionary *> * _Nullable, NSError * _Nonnull))completion {
    
    [self GET:kAUXURLPathDeviceShareSubuser parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<NSDictionary *> *subuserList = nil;
        
        if (responseObject) {
            //NSLog(@"获取子用户列表结果 %@", responseObject);
            
            subuserList = (NSArray *)responseObject;
        } else {
            //NSLog(@"获取子用户列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(subuserList, responseError);
        }
    }];
}

- (void)getDeviceShareQRContentWithDeviceIdArray:(NSArray<NSString *> *)deviceIdArray type:(AUXDeviceShareType)type completion:(void (^)(NSString * _Nullable, NSError * _Nonnull))completion {
    
    NSString *idString = [deviceIdArray componentsJoinedByString:@","];
    NSDictionary *parameters = @{@"deviceIds": idString,
                                 @"userTag": @(type)};
    
    [self POST:kAUXURLPathMultiDeviceShare parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *qrContent = nil;
        
        if (responseObject) {
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            qrContent = dataDict[@"qrContent"];
            //NSLog(@"获取设备分享二维码结果 %@", responseObject);
        } else {
            //NSLog(@"获取设备分享二维码失败 %@", responseError);
        }
        
        if (completion) {
            completion(qrContent, responseError);
        }
    }];
}

- (void)acceptDeviceShareWithQRContent:(NSString *)qrContent completion:(void (^)(NSError * _Nonnull))completion {
    NSDictionary *parameters = @{@"qrContent": qrContent};
    
    [self PUT:kAUXURLPathDeviceShareQRCode parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}


- (void)getDeviceShareMessageWithQRContent:(NSString *)qrContent name:(NSString *)name deviceName:(NSArray<NSString *> *)deviceName ownerUid:(NSString *)ownerUid completion:(void (^)(NSString * _Nullable, NSError * ))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:name forKey:@"name"];
    [parameters setObject:qrContent forKey:@"qrContent"];
    [parameters setObject:ownerUid forKey:@"ownerUid"];
    if (deviceName.count > 0) {
        NSString *deviceNameString = [deviceName componentsJoinedByString:@","];
        [parameters setObject:deviceNameString forKey:@"deviceName"];
    }
    
    [self POST:kAUXURLPathDeviceShareNew parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *qrContent = nil;
        
        if (responseObject) {
            NSLog(@"获取设备分享二维码的内容成功 %@", responseObject);
            qrContent = responseObject[@"qrContent"];
        } else {
            NSLog(@"获取设备分享二维码的内容失败");
        }
        
        if (completion) {
            completion(qrContent, nil);
        }
    }];
}


- (void)acceptDeviceShareWithClipbordShareData:(NSString *)clipbordShareData completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{@"clipbordShareData": clipbordShareData};
    
    [self POST:kAUXURLPathDeviceShareToPeople parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)getDeviceShareWithClipbordShareData:(NSString *)clipbordShareData completion:(void (^)(AUXShareDeviceModel *, NSError *))completion {
    
    NSDictionary *parameters = @{@"clipbordShareData": clipbordShareData};
    
    [self POST:kAUXURLPathDeviceShareGetDeviceFromClipbordShare parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXShareDeviceModel *model;
        if (responseObject) {
            model = [[AUXShareDeviceModel alloc]init];
            NSDictionary *dict = (NSDictionary *)responseObject;
            [model yy_modelSetWithDictionary:dict];
            
            NSLog(@"根据剪切板内容分享设备成功 %@", responseObject);
        } else {
            NSLog(@"根据剪切板内容分享设备失败 %@", responseError);
        }
        
        if (completion) {
            completion(model, responseError);
        }
    }];
}

- (void)deleteDeviceShareWithShareId:(NSString *)shareId completion:(void (^)(NSError * _Nonnull))completion {
    
    NSString *urlPath = [kAUXURLPathDeviceShare stringByAppendingPathComponent:shareId];
    
    [self DELETE:urlPath parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)familySharingDeviceListWithCompletion:(void (^)(NSArray * _Nullable array, NSError * _Nonnull error))completion {
    
    [self GET:kAUXURLPathDeviceHomeShareList parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXDeviceShareInfo *> *deviceShareInfoList = nil;
        
        if (responseObject) {
            //NSLog(@"获取家人设备分享列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            deviceShareInfoList = [NSArray yy_modelArrayWithClass:[AUXSharingUser class] json:dataArray];
        } else {
            //NSLog(@"获取家人设备分享列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(deviceShareInfoList, responseError);
        }
    }];
}

- (void)friendSharingDeviceListWithCompletion:(void (^)(NSArray * _Nullable array, NSError * _Nonnull error))completion {
    
    [self GET:kAUXURLPathDeviceFriendShareList parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXDeviceShareInfo *> *deviceShareInfoList = nil;
        
        if (responseObject) {
            //NSLog(@"获取好友设备分享列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            deviceShareInfoList = [NSArray yy_modelArrayWithClass:[AUXSharingUser class] json:dataArray];
        } else {
            //NSLog(@"获取好友设备分享列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(deviceShareInfoList, responseError);
        }
    }];
}

- (void)userSharingDeviceListWithUid:(NSString *)uid userType:(NSString *)userType batchNo:(NSString *)batchNo completion:(void (^)(NSArray * _Nullable array, NSError * _Nonnull error))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"uid": uid, @"userTag": userType}];
    if (batchNo) {
        [parameters setObject:batchNo forKey:@"batchNo"];
    }
    
    [self GET:kAUXURLPathDeviceUserShareList parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXDeviceShareInfo *> *deviceShareInfoList = nil;
        
        if (responseObject) {
            //NSLog(@"获取设备分享列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            deviceShareInfoList = [NSArray yy_modelArrayWithClass:[AUXSharingDevice class] json:dataArray];
        } else {
            //NSLog(@"获取家人设备分享列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(deviceShareInfoList, responseError);
        }
    }];
}

- (void)userSharingDeviceDeleteWithUid:(NSString *)uid userType:(NSString *)userType batchNo:(NSString * _Nullable)batchNo deviceId:(NSString * _Nullable)deviceId completion:(void (^)(NSError * _Nonnull error))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"uid": uid,@"userTag": userType}];
    if (batchNo) {
        [parameters setObject:batchNo forKey:@"batchNo"];
    }
    if (deviceId) {
        [parameters setObject:deviceId forKey:@"deviceId"];
    }
    
    [self DELETE:kAUXURLPathDeviceUserShareDelete parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark - 峰谷节电

- (void)getPeakValleyWithDeviceId:(NSString *)deviceId completion:(void (^)(AUXPeakValleyModel * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldDeviceId: deviceId};
    
    [self GET:kAUXURLPathSaveElectricity parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXPeakValleyModel *peakValleyModel = nil;
        
        if (responseObject) {
            //NSLog(@"获取峰谷节电设置结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            if ([dataDict count] > 0) {
                peakValleyModel = [AUXPeakValleyModel yy_modelWithDictionary:dataDict];
            } else {
                peakValleyModel = [[AUXPeakValleyModel alloc] init];
            }
        } else {
            //NSLog(@"获取峰谷节电设置失败 %@", responseError);
        }
        
        if (completion) {
            completion(peakValleyModel, responseError);
        }
    }];
}

- (void)addPeakValley:(AUXPeakValleyModel *)peakValleyModel completion:(void (^)(NSString * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = [peakValleyModel yy_modelToJSONObject];
    
    [self POST:kAUXURLPathSaveElectricity parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *peakValleyId = nil;
        
        if (responseObject) {
            //NSLog(@"新增峰谷节电设置结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            
            if ([dataDict count] > 0) {
                peakValleyId = dataDict[@"peakValleyId"];
            }
        } else {
            //NSLog(@"新增峰谷节电设置失败 %@", responseError);
        }
        
        if (completion) {
            completion(peakValleyId, responseError);
        }
    }];
}

- (void)updatePeakValley:(AUXPeakValleyModel *)peakValleyModel completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = [peakValleyModel yy_modelToJSONObject];
    
    [self PUT:kAUXURLPathSaveElectricity parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark - 智能用电

- (void)getSmartPowerWithDeviceId:(NSString *)deviceId completion:(void (^)(AUXSmartPowerModel * _Nullable, NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{kAUXFieldDeviceId: deviceId};
    
    [self GET:kAUXURLPathSmartElectricity parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXSmartPowerModel *smartPowerModel = nil;
        
        if (responseObject) {
            //NSLog(@"查询智能用电规则结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            
            if ([dataDict count] > 0) {
                smartPowerModel = [AUXSmartPowerModel yy_modelWithDictionary:dataDict];
            } else {
                smartPowerModel = [[AUXSmartPowerModel alloc] init];
            }
        } else {
            //NSLog(@"查询智能用电规则失败 %@", responseError);
        }
        
        if (completion) {
            completion(smartPowerModel, responseError);
        }
    }];
}

- (void)turnOnSmartPower:(AUXSmartPowerModel *)smartPowerModel completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = [smartPowerModel yy_modelToJSONObject];
    
    [self POST:kAUXURLPathSmartElectricity parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)turnOffSmartPower:(NSString *)deviceId completion:(void (^)(NSError * _Nonnull))completion {
    NSDictionary *parameters = @{kAUXFieldDeviceId: deviceId};
    
    [self DELETE:kAUXURLPathSmartElectricity parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark - 用电曲线

#pragma mark 旧设备

- (void)getElectricityConsumptionCurveWithMac:(NSString *)mac subIndex:(NSInteger)subIndex date:(nonnull NSDate *)date dateType:(AUXElectricityCurveDateType)dateType completion:(nonnull void (^)(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable, NSError * _Nonnull))completion {
    
    AUXNetworkManager *manager = [[AUXNetworkManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    NSString *unit;
    NSString *startTimeSuffix = @"-00:00:00";
    NSString *endTimeSuffix = @"-23:59:59";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *startTime = [dateString stringByAppendingString:startTimeSuffix];
    NSString *endTime = [dateString stringByAppendingString:endTimeSuffix];
    
    switch (dateType) {
        case AUXElectricityCurveDateTypeDay:
            unit = @"day";
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            unit = @"month";
            break;
            
        default:
            unit = @"year";
            break;
    }
    
    mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSDictionary *parameters = @{@"device_id": mac,
                                 @"sub_index": @(subIndex),
                                 @"timestart": startTime,
                                 @"timeend": endTime,
                                 @"unit": unit};
    
    NSString *urlString = @"https://auxelecstatistic.ibroadlink.com/statistics/status";
    
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        NSArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = nil;
        
        //NSLog(@"获取旧设备用电曲线结果: %@", responseObject);
        
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = -9999;
        NSString *message = @"Reserve";
        
        if (responseDict) {
            code = [responseDict[kAUXFieldCode] integerValue];
            
            if (code == AUXNetworkErrorNone) {
                NSArray *dataArray = responseDict[@"list"];
                if (![dataArray isKindOfClass:[NSNull class]]) {
                    switch (dateType) {
                        case AUXElectricityCurveDateTypeYear:
                            pointModelArray = [self analyzeYearElectricityCurveData:dataArray];
                            break;
                            
                        case AUXElectricityCurveDateTypeMonth:
                            pointModelArray = [self analyzeMonthElectricityCurveData:dataArray];
                            break;
                            
                        default:
                            pointModelArray = [self analyzeDayElectricityCurveData:dataArray];
                            break;
                    }
                } else {
                    message = @"invalid format";
                }
            }
        }
        
        error = [NSError errorWithCode:code message:message];
        
        if (completion) {
            completion(pointModelArray, error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)getTodayElectricityConsumptionCurveWithMac:(NSString *)mac completion:(nonnull void (^)(NSArray<AUXElectricityConsumptionCurvePointModel *> * _Nullable, NSError * _Nonnull))completion {
    AUXNetworkManager *manager = [[AUXNetworkManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];
    
    NSDictionary *params = @{@"device_id": [mac stringByReplacingOccurrencesOfString:@":" withString:@""],
                             @"sub_index": @(0),
                             @"timestart": [NSString stringWithFormat:@"%04ld-%02ld-%02ld 00:00:00", (long)[dateComponent year], (long)[dateComponent month], (long)[dateComponent day]],
                             @"timeend": [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", (long)[dateComponent year], (long)[dateComponent month], (long)[dateComponent day], (long)[dateComponent hour], (long)[dateComponent minute], (long)[dateComponent second]],
                             @"offset": @(0),
                             @"length": @(0),
                             @"page_start": @(0),
                             @"repetition": @(0)};
    
    [manager GET:@"https://auxelecstatistic.ibroadlink.com/history/status" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        NSArray<AUXElectricityConsumptionCurvePointModel *> *electricityArray = nil;
        
        //NSLog(@"获取当天用电曲线结果: %@", responseObject);
        
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSInteger code = -9999;
        NSString *message = @"Reserve";
        
        if (responseDict) {
            code = [responseDict[kAUXFieldCode] integerValue];
            NSArray *dataArray = responseDict[@"list"];
            if (code == AUXNetworkErrorNone) {
                if (![dataArray isKindOfClass:[NSNull class]]) {
                    electricityArray = [self analyzeToDayElectricityCurveData:dataArray];
                } else {
                    message = @"invalid format";
                }
            }
        }
        
        error = [NSError errorWithCode:code message:message];
        
        if (completion) {
            completion(electricityArray, error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (nullable NSArray<AUXElectricityConsumptionCurvePointModel *> *)analyzeToDayElectricityCurveData:(NSArray *)dataArray {
    float values[24] = {0};
    int lastHour = 0;
    if (dataArray && dataArray.count > 0) {
        for (NSDictionary *info in dataArray) {
            //TODO: change
            int hour = (int)strtoul([[[info objectForKey:@"dtval"] substringWithRange:NSMakeRange(11, 2)] UTF8String], 0, 10);
            NSData *data = [[NSData alloc] initWithBase64EncodedString:[info objectForKey:@"dval"] options:0];
            if (data && [data length] == 35) {
                Byte *bytes = (Byte *)[data bytes];
                NSString *string = [[NSString alloc] initWithFormat:@"%@", data];
                string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
                string = [string substringWithRange: NSMakeRange(1, string.length - 2)];
                
                if ([AUXACCBridge validateBufferHexStr:string]) {
                    values[hour] += bytes[30];
                }
                lastHour = hour;
            }
            //            //NSLog(@"%d, %f", hour, values[hour]);
            //            //NSLog(@"%@", data);
        }
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i <= lastHour; i++) {
        AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
        pointModel.waveFlatElectricity = values[i] * 0.03125;
        pointModel.waveType = AUXElectricityCurveWaveTypeNone;
        pointModel.xValue = i;
        [array addObject:pointModel];
    }
    return array;
}

/// 解析旧设备的年用电曲线 (旧设备数据需要除以32)
- (nullable NSArray<AUXElectricityConsumptionCurvePointModel *> *)analyzeYearElectricityCurveData:(NSArray *)dataArray {
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = nil;
    
    if ([dataArray count] > 0) {
        pointModelArray = [[NSArray yy_modelArrayWithClass:[AUXElectricityConsumptionCurvePointModel class] json:dataArray] mutableCopy];
        
        for (int i = 0; i < 12; i++) {
            // month i 有数据，直接设备 xValue 的值
            if (i < pointModelArray.count) {
                AUXElectricityConsumptionCurvePointModel *pointModel = pointModelArray[i];
                pointModel.waveType = AUXElectricityCurveWaveTypeNone;
                
                NSInteger month = [pointModel.dateString substringWithRange:NSMakeRange(5, 2)].integerValue;
                
                if (i + 1 == month) {
                    pointModel.xValue = month;
                    pointModel.waveFlatElectricity = pointModel.waveFlatElectricity / 32.0;
                    continue;
                }
            }
            
            // month i 无数据，填充一个数据
            AUXElectricityConsumptionCurvePointModel *anotherPointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
            anotherPointModel.waveFlatElectricity = 0;
            anotherPointModel.waveType = AUXElectricityCurveWaveTypeNone;
            anotherPointModel.xValue = i + 1;
            if (anotherPointModel !=nil) {
                [pointModelArray insertObject:anotherPointModel atIndex:i];
            }
            
        }
        
        //NSLog(@"填充年用电曲线 %@", [pointModelArray yy_modelToJSONObject]);
    }
    
    return pointModelArray;
}

/// 解析旧设备的月用电曲线 (旧设备数据需要除以32)
- (nullable NSArray<AUXElectricityConsumptionCurvePointModel *> *)analyzeMonthElectricityCurveData:(NSArray *)dataArray {
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = nil;
    
    /*
     list = ({
     dtval = "2017-08-01";
     dval = 12;})
     */
    
    if ([dataArray count] > 0) {
        pointModelArray = [[NSArray yy_modelArrayWithClass:[AUXElectricityConsumptionCurvePointModel class] json:dataArray] mutableCopy];
        
        // 古北云返回来的数据，不是每天都有的，所以需要补上漏掉的天数
        AUXElectricityConsumptionCurvePointModel *firstPointModel = pointModelArray.firstObject;
        
        NSInteger year;
        NSInteger month;
        
        if (firstPointModel.dateString.length == 10) {
            // 从数据的日期中提取年月
            year = [firstPointModel.dateString substringWithRange:NSMakeRange(0, 4)].integerValue;
            month = [firstPointModel.dateString substringWithRange:NSMakeRange(5, 2)].integerValue;
            NSInteger numberOfDays = [NSDate numberOfDaysInMonth:month forYear:year];
            
            for (int i = 0; i < numberOfDays; i++) {
                
                // day i 有数据，直接设置 xValue 的值。
                if (i < pointModelArray.count) {
                    AUXElectricityConsumptionCurvePointModel *pointModel = pointModelArray[i];
                    pointModel.waveType = AUXElectricityCurveWaveTypeNone;
                    
                    NSInteger day = [pointModel.dateString substringWithRange:NSMakeRange(8, 2)].integerValue;
                    
                    if (i + 1 == day) {
                        pointModel.xValue = day;
                        pointModel.waveFlatElectricity = pointModel.waveFlatElectricity / 32.0;
                        continue;
                    }
                }
                
                // day i 没有数据，填充一个数据
                AUXElectricityConsumptionCurvePointModel *anotherPointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
                anotherPointModel.waveFlatElectricity = 0;
                anotherPointModel.waveType = AUXElectricityCurveWaveTypeNone;
                anotherPointModel.xValue = i + 1;
                if (anotherPointModel !=nil) {
                    [pointModelArray insertObject:anotherPointModel atIndex:i];
                }
                
            }
        }
        
        //NSLog(@"填充月用电曲线 %@", [pointModelArray yy_modelToJSONObject]);
    }
    
    return pointModelArray;
}

/// 解析旧设备的日用电曲线 (旧设备数据需要除以32)
- (nullable NSArray<AUXElectricityConsumptionCurvePointModel *> *)analyzeDayElectricityCurveData:(NSArray *)dataArray {
    NSMutableArray<AUXElectricityConsumptionCurvePointModel *> *pointModelArray = nil;
    
    /*
     list = ({
     dtval = "2017-08-16";
     dval = "{\"0\":0,\"1\":0,\"10\":11,\"11\":25,\"12\":27,\"13\":27,\"14\":10,\"15\":39,\"16\":51,\"17\":33,\"18\":44,\"19\":50,\"2\":0,\"20\":36,\"21\":0,\"22\":0,\"23\":0,\"3\":0,\"4\":0,\"5\":0,\"6\":0,\"7\":0,\"8\":0,\"9\":0}";
     });
     */
    
    if ([dataArray count] > 0) {
        NSDictionary *dataDict = dataArray.firstObject;
        
        // 日期
        NSString *dtvalString = dataDict[@"dtval"];
        // 用电数据
        NSString *dvalJSONString = dataDict[@"dval"];
        NSData *dvalJSONData = [dvalJSONString dataUsingEncoding:NSUTF8StringEncoding];
        
        // key 为 day，value 为电量
        NSDictionary *dvalDict = [NSJSONSerialization JSONObjectWithData:dvalJSONData options:NSJSONReadingAllowFragments error:NULL];
        
        // day 从小到大排序
        NSArray *keyArray = [dvalDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *key1 = (NSString *)obj1;
            NSString *key2 = (NSString *)obj2;
            
            NSComparisonResult result = key1.integerValue < key2.integerValue ? NSOrderedAscending : NSOrderedDescending;
            return result;
        }];
        
        pointModelArray = [[NSMutableArray alloc] init];
        
        for (NSString *key in keyArray) {
            AUXElectricityConsumptionCurvePointModel *pointModel = [[AUXElectricityConsumptionCurvePointModel alloc] init];
            pointModel.dateString = dtvalString;
            pointModel.xValue = key.integerValue;
            pointModel.waveFlatElectricity = [dvalDict[key] floatValue] / 32.0;
            pointModel.waveType = AUXElectricityCurveWaveTypeNone;
            [pointModelArray addObject:pointModel];
        }
        
        //NSLog(@"填充日用电曲线 %@", [pointModelArray yy_modelToJSONObject]);
    }
    
    return pointModelArray;
}

#pragma mark 新设备

- (void)getElectricityConsumptionCurveWithDid:(NSString *)did date:(NSDate *)date dateType:(AUXElectricityCurveDateType)dateType completion:(void (^)(AUXElectricityConsumptionCurveModel * _Nullable, NSError * _Nonnull))completion {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSString *dateTypeString;
    NSString *dateString;
    
    switch (dateType) {
        case AUXElectricityCurveDateTypeDay:
            dateTypeString = @"DAY";
            dateFormatter.dateFormat = @"yyyyMMdd";
            break;
            
        case AUXElectricityCurveDateTypeMonth:
            dateTypeString = @"MONTH";
            dateFormatter.dateFormat = @"yyyyMM";
            break;
            
        default:
            dateTypeString = @"YEAR";
            dateFormatter.dateFormat = @"yyyy";
            break;
    }
    
    dateString = [dateFormatter stringFromDate:date];
    
    NSDictionary *parameters = @{@"did": did,
                                 @"time": dateString,
                                 @"dateType": dateTypeString};
    
    [self GET:kAUXURLPathElectricityCurve parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXElectricityConsumptionCurveModel *curveModel = nil;
        
        if (responseObject) {
            //NSLog(@"获取新设备用电曲线结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            curveModel = [AUXElectricityConsumptionCurveModel yy_modelWithJSON:dataDict];
        } else {
            //NSLog(@"获取新设备用电曲线失败 %@", responseError);
        }
        
        if (completion) {
            completion(curveModel, responseError);
        }
    }];
}

#pragma mark - 故障、滤网

- (void)getFaultListWithMac:(NSString *)mac completion:(void (^)(NSArray<AUXFaultInfo *> * _Nullable, NSError * _Nonnull))completion {
    NSDictionary *parameters = @{@"mac": mac};
    
    [self GET:kAUXURLPathFault parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXFaultInfo *> *faultInfoList = nil;
        
        if (responseObject) {
            //NSLog(@"获取故障列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            faultInfoList = [NSArray yy_modelArrayWithClass:[AUXFaultInfo class] json:dataArray];
        } else {
            //NSLog(@"获取故障列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(faultInfoList, responseError);
        }
    }];
}

- (void)getHistoryFaultListWithCompletion:(void (^)(NSArray<AUXFaultInfo *> * _Nullable, NSError * _Nonnull))completion {
    
    [self GET:kAUXURLPathHistoryFault parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSArray<AUXFaultInfo *> *faultInfoList = nil;
        
        if (responseObject) {
            //NSLog(@"获取历史故障列表结果 %@", responseObject);
            
            NSArray *dataArray = (NSArray *)responseObject;
            faultInfoList = [NSArray yy_modelArrayWithClass:[AUXFaultInfo class] json:dataArray];
        } else {
            //NSLog(@"获取历史故障列表失败 %@", responseError);
        }
        
        if (completion) {
            completion(faultInfoList, responseError);
        }
    }];
}

- (void)updateFilterStatus:(NSString *)mac completion:(void (^)(NSError * _Nonnull))completion {
    NSDictionary *parameters = @{@"mac": mac};
    
    [self POST:kAUXURLPathFilter parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

- (void)reportFaultWithMac:(NSString *)mac deviceSN:(NSString *)deviceSN faultType:(NSString *)faultType completion:(void (^)(NSError * _Nonnull))completion {
    NSDictionary *parameters = @{@"mac": mac,
                                 @"deviceSn": deviceSN,
                                 @"faultType": faultType};
    
    [self POST:kAUXURLPathReportFault parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark - 配网成功信息
- (void)reportConnectSuccessWithInfo:(NSDictionary *)info completion:(void (^)(NSError * _Nullable error))completion {
    [self reportConnectFaultWithInfo:info completion:completion];
}

#pragma mark 配网失败信息
- (void)reportConnectFaultWithInfo:(NSDictionary *)info completion:(void (^)(NSError * _Nullable error))completion {
    [self POSTWithDataTaskWithUrlString:[kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathReportConnectFault] Parameters:info completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        if (!responseError) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            int code = [responseDic[kAUXFieldCode] intValue];
            if (code != AUXNetworkErrorNone) {
                responseError = [NSError errorWithCode:code message:responseDic[kAUXFieldMessage]];
            }
        }
        
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark 推送消息

- (void)getMessageWithUid:(NSString *)uid fromDate:(NSString *)date completion:(void (^)(NSMutableArray * _Nullable, NSMutableArray * _Nullable,NSError * _Nonnull))completion {
    
    NSString *url = [NSString stringWithFormat:@"%@/%@" , kAUXURLPathMessage , uid];
    
    NSDictionary *parameters = @{@"time": date};
    
    [self GET:url parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSMutableArray *dateInfoArray = [NSMutableArray array];
        NSMutableArray *recordArray = [NSMutableArray array];
        if (responseObject) {
            
            NSString *dateInfo = nil;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            for (NSDictionary *dic in responseObject) {
                dateInfo = dic[@"dateInfo"];
                NSArray *list = dic[@"list"];
                
                NSMutableArray<AUXMessageContentModel *> *recordInfoArray = [NSMutableArray array];
                for (NSDictionary *obj in list) {
                    AUXMessageContentModel *contentModel = [[AUXMessageContentModel alloc]init];
                    
                    NSDictionary *content;
                    if ([obj[@"content"] isKindOfClass:[NSString class]]) {
                        NSData *jsonData = [obj[@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                        content = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    } else {
                        content = obj[@"content"];
                    }
                    
                    NSDictionary *alert = [content[@"aps"] objectForKey:@"alert"];
                    
                    
                    [contentModel yy_modelSetWithDictionary:content];
                    contentModel.body = alert[@"body"];
                    contentModel.title = alert[@"title"];
                    contentModel.uid = obj[@"uid"];
                    contentModel.pushTime = obj[@"pushTime"];
                    [recordInfoArray addObject:contentModel];
                }
                
                [recordArray addObject:recordInfoArray];
                [dateInfoArray addObject:dateInfo];
            }
            
        } else {
            NSLog(@"获取从%@至现在消息失败 %@", date, responseError);
        }
        
        if (completion) {
            completion(dateInfoArray , recordArray , responseError);
        }
    }];
}

- (void)getRemotationWithUid:(NSString *)uid fromDate:(NSString *)date completion:(void (^)(NSMutableArray * _Nullable dateInfoArray, NSMutableArray * _Nullable recordArray ,NSError * _Nonnull error))completion {
    
    NSString *url = [NSString stringWithFormat:@"%@/%@" , kAUXURLPathMessage , uid];
    
    NSDictionary *parameters = @{@"time": date};
    
    [self GET:url parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        
        NSMutableArray *dateInfoArray = [NSMutableArray array];
        NSMutableArray *recordArray = [NSMutableArray array];
        if (responseObject) {
            
            NSString *dateInfo = nil;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            for (NSDictionary *dic in responseObject) {
                dateInfo = dic[@"dateInfo"];
                NSArray *list = dic[@"list"];
                
                NSMutableArray<AUXMessageContentModel *> *recordInfoArray = [NSMutableArray array];
                for (NSDictionary *obj in list) {
                    AUXMessageContentModel *contentModel = [[AUXMessageContentModel alloc]init];
                    
                    NSDictionary *content;
                    if ([obj[@"content"] isKindOfClass:[NSString class]]) {
                        NSData *jsonData = [obj[@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                        content = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    } else {
                        content = obj[@"content"];
                    }
                    
                    NSDictionary *alert = [content[@"aps"] objectForKey:@"alert"];
                    
                    
                    [contentModel yy_modelSetWithDictionary:content];
                    contentModel.body = alert[@"body"];
                    contentModel.title = alert[@"title"];
                    contentModel.uid = obj[@"uid"];
                    contentModel.pushTime = obj[@"pushTime"];
                    
                    if ([contentModel.type isEqualToString:@"jump"]) {
                        [recordInfoArray addObject:contentModel];
                    }
                }
                
                [recordArray addObject:recordInfoArray];
                [dateInfoArray addObject:dateInfo];
            }
            
        } else {
            NSLog(@"获取从%@至现在消息失败 %@", date, responseError);
        }
        
        if (completion) {
            completion(dateInfoArray , recordArray , responseError);
        }
    }];
}

- (void)getMessageNoReadCompletion:(void (^)(NSString * count,NSError * _Nonnull error))completion {
    
    [self GET:kAUXURLPathMessageNoRead parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSString *maxcount = nil;
        if (responseError.code == 200) {
            maxcount = (NSString *)responseObject;
        } else {
            NSLog(@"获取未读消息数量失败 %@", responseError);
        }
        
        if (completion) {
            completion(maxcount , responseError);
        }
    }];
}

- (void)updateAllMessageStateCompletion:(void (^)(BOOL result,NSError * _Nonnull error))completion {
    
    [self PUT:kAUXURLPathMessageHaveBeenReaded parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        BOOL result = YES;
        if (responseError.code == 200) {
            result = YES;
        } else {
            result = NO;
        }
        
        if (completion) {
            completion(result , responseError);
        }
    }];
    
}

#pragma mark - 语意接口

- (void)speechAnalyseWithUid:(NSString *)uid speech:(NSString *)speech deviceList:(NSArray<AUXAudioDevice *> *)deviceList completion:(nonnull void (^)(NSString * _Nullable, NSMutableArray<NSNumber *> * _Nullable, NSArray<AUXAnswerAudioDevice *> * _Nullable, NSError * _Nullable))completion {
    NSDictionary *parameters = @{@"uid": uid,
                                 @"speech": speech,
                                 @"devices": deviceList};
    
    NSData *data = [parameters yy_modelToJSONData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSString *urlString = @"http://aux-nlp-engine.iotsdk.com:8081/aux_api/analyse";
    [self POSTWithDataTaskWithUrlString:urlString Parameters:dict completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        NSError *serverError = nil;
        NSString *answer = nil;
        NSMutableArray<NSNumber *> *cmdTypeList = [NSMutableArray array];
        NSArray<AUXAnswerAudioDevice *> *responseDeviceList = nil;
        
        if (!responseError) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            //NSLog(@"语意识别结果 %@", [responseDict yy_modelToJSONString]);
            
            if (responseDict) {
                answer = responseDict[@"answer"];
                //                speechType = [responseDict[@"speech_type"] integerValue];
                NSArray *devices = responseDict[@"devices"];
                
                if (devices) {
                    responseDeviceList = [NSArray yy_modelArrayWithClass:[AUXAnswerAudioDevice class] json:devices];
                    
                    [devices enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSInteger cmd_code = [obj[@"cmd_code"] integerValue];
                        switch (cmd_code) {
                            case 41:
                                [cmdTypeList addObject:@(AUXSpeechCmdShareDevicesToFamilies)];
                                break;
                            case 42:
                                [cmdTypeList addObject:@(AUXSpeechCmdShareDevicesToFriends)];
                                break;
                                
                            default:
                                [cmdTypeList addObject:@(AUXSpeechCmdOthers)];
                                break;
                        }
                        
                    }];
                }
            }
        } else {
            serverError = responseError;
            //NSLog(@"语意识别失败 %@", error);
        }
        
        if (completion) {
            completion(answer, cmdTypeList, responseDeviceList, serverError);
        }
    }];
    
}

#pragma mark - 首页

- (void)getHomepageVersionInfoWithCompletion:(void (^)(AUXHomepageVersionInfo * _Nullable, NSError * _Nonnull))completion {
    
    [self GET:kAUXURLPathHomepage parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXHomepageVersionInfo *homepageVersionInfo = nil;
        
        if (responseObject) {
            //NSLog(@"获取首页版本信息结果 %@", responseObject);
            
            NSDictionary *dataDict = (NSDictionary *)responseObject;
            homepageVersionInfo = [AUXHomepageVersionInfo MR_createEntity];
            [homepageVersionInfo yy_modelSetWithDictionary:dataDict];
        } else {
            //NSLog(@"获取首页版本信息失败 %@", responseError);
        }
        
        if (completion) {
            completion(homepageVersionInfo, responseError);
        }
    }];
}

- (void)downloadHomepage:(NSString *)zipUri savePath:(NSString *)savePath completion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion {
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:zipUri parameters:nil error:NULL];
    request.timeoutInterval = 60;
    
    [[sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *path = [savePath stringByAppendingPathExtension:response.suggestedFilename.pathExtension];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            //NSLog(@"首页下载失败 %@", error);
        } else {
            //NSLog(@"首页下载成功");
        }
        if (completion) {
            completion(filePath, error);
        }
    }] resume];
}

- (void)getAppVersionInfoWithCompletion:(void (^)(AUXAppVersionModel * _Nullable appVersionModel, NSError *error))completion {
    
    [self GET:kAUXURLPathAppVersion parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        AUXAppVersionModel *appVersionModel = nil;
        if (responseObject) {
            //NSLog(@"获取App版本信息结果 %@" , responseObject);
            
            appVersionModel = [AUXAppVersionModel alloc];
            [appVersionModel yy_modelSetWithDictionary:(NSDictionary *)responseObject];
        } else {
            //NSLog(@"获取App版本信息失败 %@" , responseError);
        }
        
        if (completion) {
            completion(appVersionModel , responseError);
        }
    }];
}

#pragma mark 场景

- (void)createSceneWith:(AUXSceneAddModel *)sceneAddModel completion:(void (^)(AUXSceneDetailModel *detailModel , NSError *error))completion {
    [self createSceneWith:sceneAddModel withSceneId:nil completion:completion];
}

- (void)editSceneWithSceneId:(NSString *)sceneId sceneAddModel:(AUXSceneAddModel *)sceneAddModel completion:(void (^)(AUXSceneDetailModel *detailModel , NSError *error))completion {
    if (!sceneAddModel || !sceneId) {
        return ;
    }
    
    [self createSceneWith:sceneAddModel withSceneId:sceneId completion:completion];
    
}

- (void)createSceneWith:(AUXSceneAddModel *)sceneAddModel withSceneId:(NSString *)sceneId completion:(void (^)(AUXSceneDetailModel *detailModel , NSError *error))completion {
    
    if (!sceneAddModel) {
        return ;
    }
    NSString *urlString;
    if (sceneId) {
        urlString = [kAUXBaseURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@" , kAUXURLPathSceneEdit , sceneId]];
    } else {
        urlString = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathSceneAdd];
    }
    
    NSDictionary *dict = (NSDictionary *)[sceneAddModel yy_modelToJSONObject];
    
    if (sceneId) {
        [self PUTWithDataTaskWithUrlString:urlString Parameters:dict completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
            [self createSceneWithResponseObject:responseObject error:responseError completion:completion];
        }];
    } else {
        [self POSTWithDataTaskWithUrlString:urlString Parameters:dict completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
            [self createSceneWithResponseObject:responseObject error:responseError completion:completion];
        }];
    }
    
}

- (void)createSceneWithResponseObject:(id)responseObject error:(NSError *)responseError  completion:(void (^)(AUXSceneDetailModel *detailModel , NSError *responseError))completion {
    
    AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
    if (!responseError) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
        NSInteger code = [responseDict[kAUXFieldCode] integerValue];
        if (code == AUXNetworkErrorNone) {
            [detailModel yy_modelSetWithDictionary:(NSDictionary *)responseDict[@"data"]];
        } else {
            responseError = [NSError errorWithCode:code message:responseDict[kAUXFieldMessage]];
        }
    }
    
    if (completion) {
        completion(detailModel , responseError);
    }
}

- (void)homePagelistSceneCompletion:(void (^)(NSArray<AUXSceneDetailModel *>* detailModelList , NSError * error))completion {
    [self GET:kAUXURLPathSceneOwner parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSMutableArray *listModel = [NSMutableArray array];
        if (responseObject) {
            
            for (NSDictionary *dict in (NSArray *)responseObject) {
                AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
                [detailModel yy_modelSetWithDictionary:dict];
                [listModel addObject:detailModel];
            }
            
        } else {
            NSLog(@"获取场景列表失败--%@" , responseError);
        }
        
        if (completion) {
            completion(listModel , responseError);
        }
    }];
}

- (void)listSceneWithKey:(NSString *)key Completion:(void (^)(NSArray<AUXSceneDetailModel *>* detailModelList , NSError * error))completion {
    NSDictionary *parameters;
    if (key) {
        parameters = @{@"key" : key};
    }
    
    [self GET:kAUXURLPathSceneOwner parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
        NSMutableArray *listModel = [NSMutableArray array];
        if (responseObject) {
            
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(listModel , responseError);
                }
                
                return ;
            }
            
            NSArray *dataArray = (NSArray *)responseObject[@"data"];
            for (NSDictionary *obj in dataArray) {
                [detailModel yy_modelSetWithDictionary:obj];
                [listModel addObject:detailModel];
            }
        } else {
            NSLog(@"获取场景列表失败--%@" , responseError);
        }
        
        if (completion) {
            completion(listModel , responseError);
        }
    }];
}

- (void)manualSceneWithSceneId:(NSString *)sceneId completion:(void (^)(BOOL result , NSError * error))completion {
    if (!sceneId) {
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@" , kAUXURLPathSceneManual , sceneId];
    [self POST:url parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        BOOL result;
        
        if (responseError.code == 200) {
            NSLog(@"手动场景执行成功");
            result = YES;
        } else {
            NSLog(@"手动场景失败--%@" , responseError);
            result = NO;
        }
        
        if (completion) {
            completion(result , responseError);
        }
    }];
}

- (void)getAutoAndManualListSceneWithKey:(NSString *)key completion:(void (^)(NSArray <NSMutableArray <AUXSceneDetailModel *>*>* detailModelList , NSError * error))completion {
    NSDictionary *parameters;
    if (key) {
        parameters = @{@"key" : key};
    }
    
    [self GET:kAUXURLPathSceneOwnerPart parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSMutableArray <AUXSceneDetailModel *>*autoListArray = [NSMutableArray array];
        NSMutableArray <AUXSceneDetailModel *>*manuaLlistArray = [NSMutableArray array];
        
        if (responseObject) {
            NSDictionary *appScenePartVo = (NSDictionary *)responseObject;
            NSArray *autoList = (NSArray *)appScenePartVo[@"autoList"];
            NSArray *manualList = (NSArray *)appScenePartVo[@"manualList"];
            
            for (NSDictionary *obj in autoList) {
                AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
                [detailModel yy_modelSetWithDictionary:obj];
                [autoListArray addObject:detailModel];
            }
            
            for (NSDictionary *obj in manualList) {
                AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
                [detailModel yy_modelSetWithDictionary:obj];
                [manuaLlistArray addObject:detailModel];
            }
            
        } else {
            NSLog(@"场景获取失败--%@" , responseError);
        }
        NSMutableArray <NSMutableArray <AUXSceneDetailModel *>*>*listArray = [NSMutableArray array];
        [listArray addObject:manuaLlistArray];
        [listArray addObject:autoListArray];
        
        if (completion) {
            completion(listArray , responseError);
        }
    }];
}

- (void)placeSceneWithSceneId:(NSString *)sceneId completion:(void (^)(BOOL success , NSError * error))completion {
    if (!sceneId) {
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@" , kAUXURLPathScenePlace , sceneId];
    [self POST:url parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        BOOL result = false;
        
        if (completion) {
            completion(result , responseError);
        }
    }];
}

- (void)openPlaceSceneWithCompletion:(void (^)(NSArray<AUXSceneDetailModel *>* detailModelList , NSError * error))completion {
    
    [self GET:kAUXURLPathSceneOpenPlace parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSMutableArray *listModel = [NSMutableArray array];
        if (responseObject) {
            
            
            NSLog(@"*************************************%@",responseObject);
            for (NSDictionary *dict in (NSArray *)responseObject) {
                AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
                [detailModel yy_modelSetWithDictionary:dict];
                [listModel addObject:detailModel];
            }
            
        } else {
            NSLog(@"获取场景列表失败--%@" , responseError);
        }
        
        if (completion) {
            completion(listModel , responseError);
        }
    }];
}

- (void)deleteSceneWithSceneId:(NSString *)sceneId completion:(void (^)(BOOL result , NSError * error))completion {
    if (!sceneId) {
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@" , kAUXURLPathSceneDelete , sceneId];
    [self DELETE:url parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        BOOL whtherSuccess = NO;
        
        if (responseError.code == 200) {
            whtherSuccess = YES;
        } else {
            whtherSuccess = NO;
            NSLog(@"删除场景失败--%@" , responseError);
        }
        if (completion) {
            completion(whtherSuccess , responseError);
        }
    }];
}

- (void)detailSceneWithSceneId:(NSString *)sceneId completion:(void (^)(AUXSceneDetailModel *detailModel , NSError * error))completion {
    if (!sceneId) {
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@" , kAUXURLPathSceneDetail , sceneId];
    [self GET:url parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
        
        if (responseObject) {
            [detailModel yy_modelSetWithDictionary:(NSDictionary *)responseObject];
        } else {
            NSLog(@"获取场景详情失败--%@" , responseError);
        }
        if (completion) {
            completion(detailModel , responseError);
        }
    }];
}

- (void)powerSceneWithSceneId:(NSString *)sceneId state:(NSInteger)state completion:(void (^)(AUXSceneDetailModel *detailModel , NSError * error))completion {
    if (!sceneId) {
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/onOff" , kAUXURLPathSceneCloseOpen , sceneId];
    NSDictionary *parames = @{@"state" : @(state)};
    [self PUT:url parameters:parames completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
        
        if (responseObject) {
            [detailModel yy_modelSetWithDictionary:(NSDictionary *)responseObject];
        } else {
            NSLog(@"开启或关闭场景失败--%@" , responseError);
        }
        
        if (completion) {
            completion(detailModel , responseError);
        }
    }];
}

- (void)renameSceneWithSceneId:(NSString *)sceneId sceneName:(NSString *)sceneName completion:(void (^)(AUXSceneDetailModel *detailModel , NSError * error))completion {
    if (!sceneId) {
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/rename" , kAUXURLPathSceneRename , sceneId];
    NSDictionary *parames = @{@"sceneName" : sceneName};
    [self PUT:url parameters:parames completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        AUXSceneDetailModel *detailModel = [[AUXSceneDetailModel alloc]init];
        
        if (responseObject) {
            [detailModel yy_modelSetWithDictionary:(NSDictionary *)responseObject[@"data"]];
        } else {
            NSLog(@"设置额名称场景失败--%@" , responseError);
        }
        
        if (completion) {
            completion(detailModel , responseError);
        }
    }];
}


///获取场景日志
- (void)getSceneHistroyWithpage:(NSInteger)page Size:(NSInteger)size compltion:(void (^) (NSDictionary * dic, NSError * error))completion {
    NSString *urlString = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathScenelog];
    NSString *url = [NSString stringWithFormat:@"%@page=%ld&size=%ld" , urlString , (long)page,(long)size];
    [self GET:url parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSDictionary *dic = [[NSDictionary alloc]init];
        if (responseObject) {
            dic = [NSDictionary dictionaryWithDictionary:responseObject];
        } else {
            NSLog(@"拉取场景日志失败--%@" , responseError);
        }
        if (completion) {
            completion(dic, responseError);
        }
    }];
}

#pragma mark - 错误信息

+ (NSDictionary *)loadErrorMessage {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ErrorCode" ofType:@"json"];
    
    NSError *error;
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        //NSLog(@"加载错误信息出错: %@", error);
        return nil;
    }
    
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *messageArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if (error) {
        //NSLog(@"错误信息解析出错: %@", error);
        return nil;
    }
    
    NSMutableDictionary<NSNumber *, NSString *> *errorDict = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *dict in messageArray) {
        NSNumber *code = dict[@"code"];
        NSString *message = dict[@"msg"];
        
        if (code && message) {
            [errorDict setObject:message forKey:code];
        }
    }
    
    return errorDict;
}

+ (NSString *)getErrorMessageWithCode:(NSInteger)code {
    
    static NSDictionary<NSNumber *, NSString *> *errorDict = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorDict = [self loadErrorMessage];
        
        if (errorDict == nil) {
            errorDict = @{};
        }
    });
    
    return errorDict[@(code)];
}

#pragma mark 三方登录  支持:微信/QQ
- (void)loginBy3rdWithSrc:(NSString *)src code:(NSString *)code token:(NSString *)token openId:(NSString *)openId completion:(void (^)(AUXUser * _Nullable user, NSString * _Nullable token, NSString * _Nullable openId, NSError * _Nonnull error))completion {
    
    NSDictionary *parameters = @{@"src": src, @"code": code, @"access_token": token, @"openid": openId, @"os_type": @"IOS"};
    
    if ((self.networkRequestType & AUXNetworkRequestTypeLogin) != 0) {
        return ;
    }
    self.networkRequestType |= AUXNetworkRequestTypeLogin;
    
    @weakify(self);
    [self POST:kAUXURL3rdLoginSkipPhone parameters:parameters completion:^(id _Nullable responseObject, NSError * _Nonnull responseError) {
        @strongify(self);
        self.networkRequestType ^= AUXNetworkRequestTypeLogin;
        
        AUXUser *user = nil;
        NSString *token;
        NSString *openId;
        
        if (responseError.code == AUXNetworkErrorNone) {
            if (responseObject && ![responseObject isKindOfClass:[NSNull class]]) {
                NSDictionary *dataDict = (NSDictionary *)responseObject;
                
                NSDictionary *userDict = dataDict[@"appUser"];
                if (userDict != nil) {
                    NSDictionary *apiDict = dataDict[@"openApiToken"];
                    
                    user = [AUXUser defaultUser];
                    
                    if (userDict) {
                        [user yy_modelSetWithDictionary:userDict];
                    }
                    
                    if (apiDict) {
                        [user yy_modelSetWithDictionary:apiDict];
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        // 更新用户头像后保存
                        user.portrait = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:user.headImg]];
                        [AUXUser archiveUser];
                    });
                } else {
                    // 不存在用户
                    token = dataDict[@"access_token"];
                    openId = dataDict[@"openid"];
                }
            } else {
                // 用户不存在
            }
        } else {
            // network error
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkManagerDidLogin:error:)]) {
            [self.delegate networkManagerDidLogin:user error:responseError];
        }
        
        if (completion) {
            completion(user, token, openId, responseError);
        }
    }];
}

- (void)bindAccountWithUid:(NSString *)uid phone:(NSString *)phone smsCode:(NSString *)smsCode completion:(void (^)(NSError * _Nonnull))completion {
    
    NSDictionary *parameters = @{@"uid":uid , @"phone":phone , @"smsCode":smsCode};
    
    @weakify(self);
    [self POST:kAUXURLBindSkipPhoneAccount parameters:parameters completion:^(id _Nullable responseObject, NSError * _Nonnull responseError) {
        @strongify(self);
        
        if (responseError.code == AUXNetworkErrorNone) {
            //NSLog(@"%@" , responseObject);
        } else {
            // network error
        }
        
        if (completion) {
            completion(responseError);
        }
    }];
}

#pragma mark 售后购买单位类型
- (void)getAfterSaleChanneltypeCompletion:(void(^)(NSArray <AUXChannelTypeModel *>* channelTypeList))completion {
    
    [self GET:kAUXAfterSaleChannelTypeURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray *dataArray = [NSMutableArray array];
        if (responseObject) {
            NSArray *Channeltype = (NSArray *)responseObject[@"Channeltype"];
            for (NSDictionary *dict in Channeltype) {
                AUXChannelTypeModel *channelTypeModel = [[AUXChannelTypeModel alloc]init];
                [channelTypeModel yy_modelSetWithDictionary:dict];
                [dataArray addObject:channelTypeModel];
            }
        }
        
        if (completion) {
            completion(dataArray);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark 获取商城配置文件
- (void)getStoreConfigurationModelWithCompletion:(void (^) (AUXStoreDomainModel *storeModel , NSError * error))completion {
    [self GET:kAUXStoreURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AUXStoreDomainModel *storeModel = [AUXStoreDomainModel sharedInstance];
        if (![AUXLocalNetworkTool isReachable]) {
            if (@available(iOS 11.0, *)) {
                responseObject = nil;
            } else {
                AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
                if (tool.networkReachability.networkReachabilityStatus == -1) {
                }else{
                    responseObject = nil;;
                }
            }
        }
        if (responseObject) {
            [storeModel yy_modelSetWithDictionary:responseObject];
        }
        if (completion) {
            completion(storeModel , nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(nil , error);
        }
    }];
    
}

#pragma mark 意见反馈
- (void)saveFeedBackInfo:(NSDictionary *)dict compltion:(void (^) (BOOL result, NSError *error))completion {
    
    NSString *urlString = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathFeedBackURL];
    
    [self POSTWithDataTaskWithUrlString:urlString Parameters:dict completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        BOOL result = NO;
        if (!responseError) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [responseDict[kAUXFieldCode] integerValue];
            if (code == AUXNetworkErrorNone) {
                result = YES;
            } else {
                responseError = [NSError errorWithCode:code message:responseDict[kAUXFieldMessage]];
            }
        }
        
        if (completion) {
            completion(result , responseError);
        }
    }];
}

#pragma mark  获取反馈列表
- (void)getFeedbackcompltion:(void (^) (NSDictionary *dic, NSError *error))completion {
    
    [self GET:kAUXURLPathFeedBackListURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(responseObject , nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(nil , error);
        }
    }];
}

#pragma mark  获取意见反馈详情
- (void)getFeedbackDetailByfeedbackId:(NSString*)feedbackId page:(NSInteger)page size:(NSInteger)size compltion:(void (^) (NSDictionary *dic, NSError *error))completion{
    
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@?page=%ld&size=%ld",kAUXBaseURL,kAUXURLPathFeedBackDetailURL,feedbackId,page,size];
    
    [self GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(responseObject , nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(nil , error);
        }
    }];
}

#pragma mark  留言上报
- (void)postFeedbackReplyWithDic:(NSDictionary*)dic compltion:(void (^) (BOOL result, NSError *error))completion{
    
    NSString *urlString = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPathFeedBackDetailReplyURL];
    [self POSTWithDataTaskWithUrlString:urlString Parameters:dic completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        BOOL result = NO;
        if (!responseError) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [responseDict[kAUXFieldCode] integerValue];
            if (code == AUXNetworkErrorNone) {
                result = YES;
            } else {
                responseError = [NSError errorWithCode:code message:responseDict[kAUXFieldMessage]];
            }
        }
        
        if (completion) {
            completion(result , responseError);
        }
    }];
}

#pragma mark 消息限制
-(void)getPushLimitDetailWithCompltion:(void (^) (AUXPushLimitModel *model , NSError *error))completion {
    [self GET:kAUXURLPushLimitDetail parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        AUXPushLimitModel *model = [[AUXPushLimitModel alloc] init];
        
        if (responseObject) {
            [model yy_modelSetWithDictionary:responseObject];
        }
        
        if (completion) {
            completion(model , responseError);
        }
    }];
}

- (void)updatePushLimitWithModel:(AUXPushLimitModel *)model compltion:(void (^) (AUXPushLimitModel *model , NSError *error))completion {
    
    NSMutableDictionary *jsonObject = [(NSDictionary *)[model yy_modelToJSONObject] mutableCopy];
    [jsonObject removeObjectForKey:@"id"];
    [jsonObject removeObjectForKey:@"uid"];
    NSString *urlString  = [kAUXBaseURL stringByAppendingPathComponent:kAUXURLPushLimitUpdate];
    
    [self POSTWithDataTaskWithUrlString:urlString Parameters:jsonObject completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        
        AUXPushLimitModel *model = [[AUXPushLimitModel alloc]init];
        if (!responseError) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:NULL];
            NSInteger code = [responseDict[kAUXFieldCode] integerValue];
            
            if (code == AUXNetworkErrorNone) {
                [model yy_modelSetWithDictionary:(NSDictionary *)responseDict[@"data"]];
            } else {
                responseError = [NSError errorWithCode:code message:responseDict[kAUXFieldMessage]];
            }
        }
        if (completion) {
            completion(model , responseError);
        }
        
    }];
}

#pragma mark 开屏广告
- (void)getAllAdvertisingDataCompletion:(void (^)(NSArray <AUXLaunchAdModel *> *array , NSError *error))completion {
    
    [self GET:kAUXURLPathAllAd parameters:nil progress:nil    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error = nil;
        NSInteger code = -9999;
        NSString *message = @"Reserve";
        id dataObject = nil;
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            code = [responseDict[kAUXFieldCode] integerValue];
            message = responseDict[kAUXFieldMessage];
            if (code == AUXNetworkErrorNone) {
                dataObject = responseDict[kAUXFieldData];
            }
        }
        
        error = [NSError errorWithCode:code message:message];
        
        NSMutableArray <AUXLaunchAdModel *>*dataArray = [NSMutableArray array];
        if ([dataObject isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in dataObject) {
                AUXLaunchAdModel *model = [[AUXLaunchAdModel alloc]init];
                [model yy_modelSetWithDictionary:dict];
                [dataArray addObject:model];
            }
        }
        
        if (completion) {
            completion(dataArray , error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(nil, error);
        }
    }];
    
}

- (void)getCurrentAdvertisingDataCompletion:(void (^)(AUXLaunchAdModel *model , NSError *error))completion {
    
    [self GET:kAUXURLPathCurrentAd parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        NSInteger code = -9999;
        NSString *message = @"Reserve";
        id dataObject = nil;
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            code = [responseDict[kAUXFieldCode] integerValue];
            message = responseDict[kAUXFieldMessage];
            if (code == AUXNetworkErrorNone) {
                dataObject = responseDict[kAUXFieldData];
            }
        }
        
        error = [NSError errorWithCode:code message:message];
        
        AUXLaunchAdModel *model = [[AUXLaunchAdModel alloc]init];
        if (dataObject && [dataObject isKindOfClass:[NSDictionary class]]) {
            
            [model yy_modelSetWithDictionary:dataObject];
            
            if (completion) {
                completion(model , error);
            }
        } else {
            
            [AUXAdvertisingCache removeCacheAdvertisingData];
            
            if (completion) {
                completion(model , error);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion) {
            completion(nil, error);
        }
    }];
    
}


#pragma mark  电子说明书
- (void)getAllelectronicUrlsByVersion:(NSString*)version completion:(void (^)(NSArray *array, NSError * _Nonnull error, NSString *resultversion,NSInteger code))completion{
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@",kAUXBaseURL,kAUXURLAllElectronicSpecification,version];
    
    [self GET:url parameters:nil completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSArray *tmparray = nil;
        NSString *version = @"";
        NSInteger code = 0;
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dict = (NSDictionary *)responseObject;
            tmparray = dict[@"data"];
            version = dict[@"version"];
            code = [dict[@"code"] integerValue];
        }
        if (completion) {
            completion(tmparray, responseError,version,code);
        }
    }];
}

- (void)getOneElectronicUrlByparameters:(NSDictionary*)parameters completion:(void (^)(NSDictionary *resultDic,NSError * _Nonnull error))completion{
    NSString *url = [NSString stringWithFormat:@"%@/%@",kAUXBaseURL,kAUXURLOneElectronicSpecification];
    [self POSTWithDataTaskWithUrlString:url Parameters:parameters completion:^(id  _Nullable responseObject, NSError * _Nonnull responseError) {
        NSDictionary *dic = nil;
        if (responseObject) {
            dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        }

        if (completion) {
            completion(dic,responseError);
        }
    }];
}

@end

