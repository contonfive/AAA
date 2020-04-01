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

#import "AUXIFlySpeechResultHandler.h"

#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

// cw
@interface AUXSpeechCWModel : NSObject

@property (nonatomic, assign) CGFloat sc;
@property (nonatomic, strong) NSString *w;

@end

@implementation AUXSpeechCWModel

@end

// ws
@interface AUXSpeechWSModel : NSObject <YYModel>

@property (nonatomic, assign) NSInteger bg;

@property (nonatomic, strong) NSArray<AUXSpeechCWModel *> *cw;

@end

@implementation AUXSpeechWSModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"cw": [AUXSpeechCWModel class]};
}

@end

// result
@interface AUXSpeechResult : NSObject <YYModel>

@property (nonatomic, assign) NSInteger sn;
@property (nonatomic, assign) BOOL ls;
@property (nonatomic, assign) NSInteger bg;
@property (nonatomic, assign) NSInteger ed;

@property (nonatomic, strong) NSArray<AUXSpeechWSModel *> *ws;

@end

@implementation AUXSpeechResult

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"ws": [AUXSpeechWSModel class]};
}

@end


@implementation AUXIFlySpeechResultHandler

// {"sn":1,"ls":false,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"sc":0.00,"w":"你好"}]}]}
// {"sn":1,"ls":false,"bg":0,"ed":0,"ws":[{"bg":0,"cw":[{"sc":0.00,"w":"你"}]},{"bg":0,"cw":[{"sc":0.00,"w":"傻逼"}]}]}

+ (NSString *)analyseResults:(NSArray<NSString *> *)results {
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    for (NSString *resultString in results) {
        
        AUXSpeechResult *resultModel = [AUXSpeechResult yy_modelWithJSON:resultString];
        
        for (AUXSpeechWSModel *wsModel in resultModel.ws) {
            for (AUXSpeechCWModel *cwModel in wsModel.cw) {
                if (!cwModel.w) {
                    continue;
                }
                
                [mutableString appendString:cwModel.w];
            }
        }
    }
    
    return mutableString;
}

/*
 NSData *JSONData = [resultString dataUsingEncoding:NSUTF8StringEncoding];
 NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:NULL];
 
 id wsValue = resultDict[@"ws"];
 
 if (!wsValue) {
 continue;
 }
 
 NSArray<NSDictionary *> *wsArray = (NSArray *)wsValue;
 
 if (wsArray.count == 0) {
 continue;
 }
 
 NSDictionary *subWSDict = wsArray.firstObject;
 
 id cwValue = subWSDict[@"cw"];
 
 if (!cwValue) {
 continue;
 }
 
 NSArray<NSDictionary *> *cwArray = (NSArray *)cwValue;
 
 if (cwArray.count == 0) {
 continue;
 }
 
 NSDictionary *subCWDict = cwArray.firstObject;
 
 NSString *wString = subCWDict[@"w"];
 
 if (wString) {
 [mutableString appendString:wString];
 }
 */

@end
