#import <Foundation/Foundation.h>

@interface Settings : NSObject
{
}

+(void)addObserver:(id)target withAction:(SEL)action;
+(NSString*) hostName;
+(NSInteger) portNumber;

+(void) setHostName:(NSString*)host;

@end
