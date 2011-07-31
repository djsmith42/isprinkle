#import <Foundation/Foundation.h>

@interface Settings : NSObject
{
}

+(NSString*) hostName;
+(NSInteger) portNumber;

+(void) setHostName:(NSString*)host;

@end
