#import "ConnectionTester.h"
#import "Settings.h"

@implementation ConnectionTester

-(void) testConnection:(NSString*)hostName target:(id)target goodAction:(SEL)goodAction badAction:(SEL)badAction;
{
    _target     = target;
    _goodAction = goodAction;
    _badAction  = badAction;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/isprinkle-identify",
                           hostName,
                           [Settings portNumber]];
    
    NSURLRequest *urlRequest=[NSURLRequest
                              requestWithURL:[NSURL URLWithString:urlString]
                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                              timeoutInterval:5.0];
    
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)cleanup
{
    [_connection release];
    _connection = nil;
    [self release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_target performSelector:_badAction withObject:error];
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_target performSelector:_goodAction];
    [self cleanup];
}


@end
