//
// XMLWriter.h
//
//  Changed by RealZYC on 10/31/2016
//

#import <Foundation/Foundation.h>

@interface XMLWriter : NSObject{
@private
    NSMutableData* xml;
}
+(NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary; //New
+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary;
@end
