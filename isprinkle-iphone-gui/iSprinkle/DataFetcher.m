#import "YAMLSerialization.h"
#import "DataFetcher.h"
#import "Settings.h"

@implementation DataFetcher

@synthesize state = _state;

- (id) initWithModels:(Status *)status waterings:(Waterings*) waterings;
{
    if ((self = [super init]))
    {
        _status    = status;
        _waterings = waterings;
        _status.connected = NO;

        _receivedData = [[NSMutableData alloc] init];
        _firstTime = YES;
        _lastConnectedHost = nil;
        _connectingHost = nil;
        
        [Settings addObserver:self withAction:@selector(settingsChanged)];
    }
    return self;
}

- (void) settingsChanged
{
    NSLog(@"Settings have changed. Fetching new data.");

    [_connection cancel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    _firstTime = YES;
    _lastConnectedHost = nil;

    [self startFetching];
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
        case FetchingZoneInfo:
            pathToFetch = @"zone-info";
            break;
    }

    if (_lastConnectedHost == nil || ![_lastConnectedHost isEqualToString:[Settings hostName]])
    {
        _status.connected = NO;
        _firstTime = YES;
    }
    
    _connectingHost = [Settings hostName];

    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/%@", [Settings hostName], [Settings portNumber], pathToFetch];
    
    NSURLRequest *urlRequest=[NSURLRequest
                              requestWithURL:[NSURL URLWithString:urlString]
                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                              timeoutInterval:5.0];
    
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void) pause
{
    [_connection cancel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _state = FetchingStatus;
    _firstTime = YES; // When we resume, this will fetch all the status right away
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Don't care
}

// Status keys:
static NSString *CurrentActionString    = @"current action";
static NSString *InDeferralPeriodString = @"in deferral period";
static NSString *ActiveIndexString      = @"active index";
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
    
    _status.connected = NO;

    // Retry laster:
    [self performSelector:@selector(startFetching) withObject:self afterDelay:1.0];
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
                NSLog(@"Got bogus YAML status results. Ignoring.");
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
                else if ([key isEqualToString:ActiveIndexString])
                {
                    _status.activeIndex = [value integerValue];
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
                if(![wateringDictionary isKindOfClass:[NSDictionary class]])
                {
                    NSLog(@"Got bogus YAML watering info. Ignoring.");
                    return;
                }

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
                            [tempZoneDuration release]; // the array owns it now
                        }

                        tempWatering.zoneDurations = tempZoneDurations;
                        [tempZoneDurations release]; // the Watering owns it now
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
                }
            }

            [uuidsReceived release];
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
        NSLog(@"Could not read status YAML from server: %@", [exception reason]);
    }
}

-(void)_handleZoneInfoResponse:(NSData*)data
{
    @try
    {
        NSArray *array = [YAMLSerialization YAMLWithData:data options:kYAMLReadOptionStringScalars error:nil];
        if (array.count > 0)
        {
            if(![[array objectAtIndex:0] isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"Got bogus YAML zone info. Ignoring.");
                return;
            }

            NSDictionary *zoneInfo = [array objectAtIndex:0];
            for (NSString *zoneNumberString in [zoneInfo allKeys])
            {
                NSNumber *zoneNumber = [NSNumber numberWithInteger:[zoneNumberString integerValue]];
                NSString *zoneName   = [zoneInfo valueForKey:zoneNumberString];
                [_status.zoneNames setObject:zoneName forKey:zoneNumber];
            }
        }
    }
    @catch (NSException *exception)
    {
        // FIXME Inform the user about the breakage
        NSLog(@"Could not read zone info YAML from server: %@", [exception reason]);
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
            self.state = FetchingZoneInfo;
            break;
        case FetchingZoneInfo:
            [self _handleZoneInfoResponse:_receivedData];
            self.state = FetchingStatus;
            _firstTime = NO;
            break;
    }
    
    if (_firstTime)
    {
        // Fetch all the info the first time
        [self startFetching];
    }
    else
    {
        _status.connected = YES;
        _lastConnectedHost = _connectingHost;
        [self performSelector:@selector(startFetching) withObject:self afterDelay:1.0];
    }
}

@end