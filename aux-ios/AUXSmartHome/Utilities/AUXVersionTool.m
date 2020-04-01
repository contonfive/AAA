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

#import "AUXVersionTool.h"
#import "AUXVersionAlertView.h"


@implementation AUXVersionTool

+ (instancetype)sharedInstance {
    static AUXVersionTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AUXVersionTool alloc] init];
    });
    return instance;
}

+ (void)getAppStoreVersionWithComplete:(void (^)(NSString * _Nullable, NSString * _Nullable))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *appInfo;
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:kAUXItunsUrl]];
        if (data && data.length) {
            appInfo = [data objectFromJSONData];
        }

        int appCnt = [[appInfo objectForKey:@"resultCount"] intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (appCnt == 1) {
                NSString *appStoreVersion = [[[appInfo objectForKey:@"results"] objectAtIndex:0] objectForKey:@"version"];
                NSString *updateUrl = [[[appInfo objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackViewUrl"];
                completion(appStoreVersion, updateUrl);
            } else {
                completion(nil, nil);
            }
        });
    });
}

- (BOOL)shouldUpdateWithAppStoreVersion:(NSString *)appStoreVersion {
    NSString *currentVersion = APP_VERSION;
    
    BOOL shouldUpdateApp = NO;
    NSArray *appStoreVersionArray = [appStoreVersion componentsSeparatedByString:@"."];
    NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
    for (int i = 0; i < 3; i++) {
        int v1 = [[appStoreVersionArray objectAtIndex:i] intValue];
        int v2 = [[currentVersionArray objectAtIndex:i] intValue];
        if (v1 > v2) {
            shouldUpdateApp = YES;
            break;
        } else if (v1 < v2) {
            break;
        } else {
            // compare next one
        }
    }
    return shouldUpdateApp;
}


//#warning 弹框提示升级
//- (void)whtherShowUpdateAlert:(AUXBaseViewController *)viewController {
//    
// 
//    
//}


@end
