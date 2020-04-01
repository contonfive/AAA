//
//  XMLWriter.m
//
#import "XMLWriter.h"
#define PREFIX_STRING_FOR_ELEMENT @"@" //From XMLReader
@implementation XMLWriter

-(void)serialize:(id)root
{    
    if ([root isKindOfClass:[NSDictionary class]])
    {
        for (NSString* key in root)
        {
            [xml appendData:
             [[NSString stringWithFormat:@"<%@>",key]
              dataUsingEncoding:NSUTF8StringEncoding]];
            
            if ([[root objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                [self serialize:[root objectForKey:key]];
            } else {
                [xml appendData:[[NSString stringWithFormat:@"%@",[root objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
            }

//            [xml appendData:[[NSString stringWithFormat:@"%@",[root objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [xml appendData:
             [[NSString stringWithFormat:@"</%@>",key]
              dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        xml = [[NSMutableData alloc] init];
        [self serialize:dictionary];
    }
    
    return self;
}

-(NSData *)getXML
{
    return xml;
}

+(NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary allKeys] count])
        return NULL;
    XMLWriter* fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary];
    return [fromDictionary getXML];
}

+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
{
    return [[NSString alloc]
            initWithData:[XMLWriter XMLDataFromDictionary:dictionary]
            encoding:NSUTF8StringEncoding];
}

@end
