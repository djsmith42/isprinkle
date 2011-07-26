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
        
        _receivedData = [[NSMutableData alloc] init];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startFetching) userInfo:nil repeats:YES];
        
        _firstTime = YES;
    }
    return self;
}

- (void) startFetching
{
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

    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (_connection == nil)
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // FIXME Inform the user about the breakage
    NSLog(@"Error fetching data: %@", [error localizedDescription]);
    [_connection release];
    _connection = nil;
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
    NSDate *ret = [[self createDateFormatter:@"yyyy-MM-dd HH:mm:ss"] dateFromString:string];
    if (ret == nil)
        ret = [[self createDateFormatter:@"yyyy-MM-dd"] dateFromString:string];
    return ret;
}

-(NSDate*) stringToTime:(NSString*)string
{
    return [[self createDateFormatter:@"HH:mm:ss"] dateFromString:string];
}

- (void) _handleStatusResponse:(NSData*)data;
{
    @try
    {
        NSMutableArray *array = [YAMLSerialization YAMLWithData:data options:kYAMLReadOptionStringScalars error:nil];
        if ([array count] > 0)
        {
            if(![[array objectAtIndex:0] isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"Got bogus YAML results. Ignoring.");
                return;
            }

            NSDictionary *statusDictionary = (NSDictionary*)[array objectAtIndex:0];
            Watering *activeWatering = nil;
            for (NSString *key in [statusDictionary allKeys])
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

- (void)_handleWateringsResponse:(NSData*)data
{
    @try
    {
        NSMutableArray *array = [YAMLSerialization YAMLWithData:data options:kYAMLReadOptionStringScalars error:nil];

        if ([array count] > 0)
        {
            array = [array objectAtIndex:0];

            NSMutableArray *uuidsReceived = [[NSMutableArray alloc] init];
            for(NSDictionary *wateringDictionary in array)
            {
                Watering *tempWatering = [[Watering alloc] init];
                NSArray * keys = [wateringDictionary allKeys];
                for (NSString *key in keys)
                {
                    NSObject *value = [wateringDictionary objectForKey:key];
                    if ([key isEqualToString:@"zone durations"])
                    {
                        NSMutableArray *array = (NSMutableArray*)value;
                        NSMutableArray *tempZoneDurations = [[NSMutableArray alloc] initWithCapacity:[array count]];
                        for(NSMutableArray *subArray in array)
                        {
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
                        [uuidsReceived addObject:tempWatering.uuid];
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
                        tempWatering.startDate = [self stringToDate:(NSString*)value];
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

                [tempWatering release];
            }

            // Are there any waterings that we have that no longer exist on the unit?
            NSArray *tempWaterings = [NSArray arrayWithArray:_waterings.waterings];
            for (Watering *watering in tempWaterings)
            {
                BOOL existsOnUnit = NO;
                for (NSString *uuid in uuidsReceived)
                {
                    if ([watering.uuid isEqualToString:uuid])
                    {
                        existsOnUnit = YES;
                        break;
                    }
                }

                if (!existsOnUnit)
                {
                    NSLog(@"Removing watering: %@", [watering prettyDescription]);
                    [_waterings removeWatering:watering];
                    [watering release];
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
    [_connection release];
    _connection = nil;

    switch (self.state)
    {
        case FetchingStatus:
            [self _handleStatusResponse:_receivedData];
            self.state = FetchingWaterings;
            break;
        case FetchingWaterings:
            [self _handleWateringsResponse:_receivedData];
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