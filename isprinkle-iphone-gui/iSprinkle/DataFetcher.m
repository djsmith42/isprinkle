#import "YAMLSerialization.h"
#import "DataFetcher.h"

// FIXME The host and port need to come from user input, not hard-coded:
static const NSString *HostName = @"10.42.42.11";
static const NSInteger Port     = 8080;

@implementation DataFetcher

@synthesize state = _state;

- (id) initWithModels:(Status *)status waterings:(Waterings*) waterings;
{
    if ((self = [super init]))
    {
        _status    = status;
        _waterings = waterings;
        
        _receivedData = [[NSMutableData data] retain];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startFetching) userInfo:nil repeats:YES];
        
        _firstTime = YES;
    }
    return self;
}

- (void) startFetching
{
    //NSLog(@"DataFetcher: Fetching");
    [_receivedData setLength:0];

    NSString *pathToFetch = nil;
    switch(self.state)
    {
        case FetchingStatus:
            pathToFetch = @"status";
            break;
        case FetchingWaterings:
            pathToFetch = @"waterings";
            break;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/%@", HostName, Port, pathToFetch];
    
    NSURLRequest *urlRequest=[NSURLRequest
                              requestWithURL:[NSURL URLWithString:urlString]
                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                             timeoutInterval:60.0];
    
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
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

// Status keys:
static NSString *CurrentActionString    = @"current action";
static NSString *InDeferralPeriodString = @"in deferral period";
static NSString *ActiveZoneString       = @"active zone";
static NSString *CurrentDateTimeString  = @"current time";
static NSString *DeferralDateTimeString = @"deferral datetime";

// Watering keys:
static NSString *ZoneDurations = @"zone durations";

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

-(NSDateFormatter*) createDateFormatter:(NSString*)format
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return formatter;
}

-(NSDate*) stringToDate:(NSString*)string
{
    return [[self createDateFormatter:@"yyyy-MM-dd HH:mm:ss"] dateFromString:string];
}

-(NSDate*) stringToTime:(NSString*)string
{
    return [[self createDateFormatter:@"HH:mm:ss"] dateFromString:string];
}

- (void)_handleStatusResponseWithStream:(NSInputStream*)stream
{
    @try
    {
        NSMutableArray *array = [YAMLSerialization YAMLWithStream:stream options:kYAMLReadOptionStringScalars error:nil];
        if ([array count] > 0)
        {
            NSDictionary *statusDictionary = (NSDictionary*)[array objectAtIndex:0];
            Watering *activeWatering = nil;
            NSArray * keys = [statusDictionary allKeys];
            for (NSString *key in keys)
            {
                NSString *value = [statusDictionary objectForKey:key];
                if ([key isEqualToString:CurrentActionString])
                {
                    [_status setCurrentAction:value];
                }
                else if ([key isEqualToString:InDeferralPeriodString])
                {
                    [_status setInDeferralPeriod:([value isEqualToString:@"true"]) ? YES : NO];
                }
                else if ([key isEqualToString:ActiveZoneString])
                {
                    [_status setActiveZone:([value intValue])];
                    NSLog(@"Active zone: %d", _status.activeZone);
                }
                else if ([key isEqualToString:CurrentDateTimeString])
                {
                    _status.currentDate = [self stringToDate:value];
                }
                else if ([key isEqualToString:DeferralDateTimeString])
                {
                    _status.deferralDate = [self stringToDate:value];
                }
                else if ([key isEqualToString:@"active watering"])
                {
                    _status.activeWatering = [_waterings wateringWithUuid:value];
                    activeWatering = _status.activeWatering;
                }
                else
                {
                    NSLog(@"TODO: Implement handling for status '%@' (with value '%@')", key, value);
                }
            }
            
            if (activeWatering == nil)
            {
                _status.activeWatering = nil;
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

- (void)_handleWateringsResponseWithStream:(NSInputStream*)stream
{
    @try
    {
        NSMutableArray *array = [YAMLSerialization YAMLWithStream:stream options:kYAMLReadOptionStringScalars error:nil];
        if ([array count] > 0)
        {
            array = [array objectAtIndex:0];

            NSEnumerator * enumerator = [array objectEnumerator];
            NSDictionary *wateringDictionary;
            while((wateringDictionary = (NSDictionary*)[enumerator nextObject]) != nil)
            {
                Watering *tempWatering = [[Watering alloc] init];
                NSArray * keys = [wateringDictionary allKeys];
                for (NSString *key in keys)
                {
                    NSObject *value = [wateringDictionary objectForKey:key];
                    if ([key isEqualToString:ZoneDurations])
                    {
                        NSMutableArray *array = (NSMutableArray*)value;
                        NSMutableArray *tempZoneDurations = [[NSMutableArray alloc] initWithCapacity:[array count]];
                        NSEnumerator *subArrayEnumerator = [array objectEnumerator];

                        NSMutableArray *subArray;
                        while ((subArray = (NSMutableArray*)[subArrayEnumerator nextObject]) != nil)
                        {
                            //NSLog(@"Zone %d for %d minutes", [[subArray objectAtIndex:0] integerValue], [[subArray objectAtIndex:1] integerValue]);
                            ZoneDuration *tempZoneDuration = [[ZoneDuration alloc] init];
                            tempZoneDuration.zone    = [[subArray objectAtIndex:0] integerValue];
                            tempZoneDuration.minutes = [[subArray objectAtIndex:1] integerValue];
                            [tempZoneDurations addObject:tempZoneDuration];
                        }

                        tempWatering.zoneDurations = tempZoneDurations;
                    }
                    else if ([key isEqualToString:@"uuid"])
                    {
                        tempWatering.uuid = [NSString stringWithString:(NSString*)value];
                    }
                    else if ([key isEqualToString:@"enabled"])
                    {
                        tempWatering.enabled = [(NSString*)value isEqualToString:@"true"];
                    }
                    else if ([key isEqualToString:@"period days"])
                    {
                        tempWatering.periodDays = [(NSString*)value integerValue];
                    }
                    else if ([key isEqualToString:@"schedule type"])
                    {
                        tempWatering.scheduleType = [(NSString*)value integerValue];
                    }
                    else if ([key isEqualToString:@"start time"])
                    {
                        tempWatering.startTime = [self stringToTime:(NSString*)value];
                    }
                    else if ([key isEqualToString:@"start date"])
                    {
                        tempWatering.startDate = [self stringToTime:(NSString*)value];
                    }
                    else
                    {
                        NSLog(@"TODO: Handle the watering key: '%@'", key);
                    }
                }
                
                if ([tempWatering.uuid length] > 0)
                {
                    [_waterings addOrUpdateWatering:tempWatering];
                }
                else
                {
                    NSLog(@"Got bogus watering from YAML with no UUID");
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSInputStream *stream = [[NSInputStream alloc] initWithData:_receivedData];

    switch (self.state)
    {
        case FetchingStatus:
            [self _handleStatusResponseWithStream:stream];
            self.state = FetchingWaterings;
            break;
        case FetchingWaterings:
            [self _handleWateringsResponseWithStream:stream];
            self.state = FetchingStatus;
            break;
    }
    
    if (_firstTime)
    {
        // Immediately fetch watering info so we don't have to wait for the timer
        _firstTime = NO;
        [self startFetching];
    }
}


@end
