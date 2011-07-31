#import <Foundation/Foundation.h>

@interface ConnectionTester : NSObject
{
    NSURLConnection *_connection;
    id _target;
	SEL _goodAction;
    SEL _badAction;
}

-(void) testConnection:(NSString*)hostName target:(id)target goodAction:(SEL)goodAction badAction:(SEL)badAction;

@end
