#import "YAMLSerialization.h"
#import "DataFetcher.h"

@implementation DataFetcher

- (id) initWithModels:(Status *)status
{
    if ((self = [super init]))
    {
        _status = status;
        _receivedData = [[NSMutableData data] retain];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startFetching) userInfo:nil repeats:YES];
    }
    return self;
}

- (void) startFetching
{
    //NSLog(@"DataFetcher: Fetching");
    [_receivedData setLength:0];

    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.42.42.11:8080/status"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (!connection)
    {
        // FIXME Inform the user that the connection failed.
        NSLog(@"Fail!");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Don't care
}

static NSString *CurrentActionString = @"current action";
static NSString *InDeferralPeriodString = @"in deferral period";

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"DataFetcher: Received incremental data: %d bytes", [data length]);
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // FIXME Inform the user about the breakage
    NSLog(@"Error fetching data: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"DataFetcher: Done receiving all data: %d bytes", [_receivedData length]);

    NSInputStream *stream = [[NSInputStream alloc] initWithData:_receivedData];
    
    @try
    {
        NSMutableArray *array = [YAMLSerialization YAMLWithStream:stream options:kYAMLReadOptionStringScalars error:nil];
        if ([array count] > 0)
        {
            NSDictionary *dictionary = (NSDictionary*)[array objectAtIndex:0];
            NSArray * keys = [dictionary allKeys];
            for (NSString *key in keys)
            {
                NSString *value = [dictionary objectForKey:key];
                if ([key isEqualToString:CurrentActionString])
                {
                    [_status setCurrentAction:value];
                }
                else if ([key isEqualToString:InDeferralPeriodString])
                {
                    [_status setInDeferralPeriod:([value isEqualToString:@"true"]) ? YES : NO];
                }
                else
                {
                    NSLog(@"TODO: Implement handling for status '%@' (with value '%@')", key, value);
                }
            }
        }
        else
        {
            // FIXME Inform the user about the breakage
            NSLog(@"Got an empty status array from the server.");
        }
    }
    @catch (NSException *exception)
    {
        // FIXME Inform the user about the breakage
        NSLog(@"Could not read YAML from server: %@", [exception reason]);
    }
    
    
}


@end
