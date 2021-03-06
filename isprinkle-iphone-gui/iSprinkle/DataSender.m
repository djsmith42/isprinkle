#import "DataSender.h"
#import "Settings.h"

@implementation DataSender

- (void) _alert:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Communication Error"
                          message: message
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void) doHttpPost:(NSString*)postPath withData:(NSString*)withData
{
    NSData *postData = [withData dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [Settings hostName], [Settings portNumber], postPath]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (_connection == nil)
    {
        [self _alert:@"Failed to communicate with device"];
    } 
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self _alert:[NSString stringWithFormat:@"Woops. %@", [error localizedDescription]]];
    [_connection release];
    _connection = nil;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] != 200)
    {
        [self _alert:[NSString stringWithFormat:@"Woops. Could not update the sprinkler unit (code %d)!", [httpResponse statusCode]]];
    }

    [_connection release];
    _connection = nil;
}

- (void) sendDeferralDate:(NSDate *)date
{
    NSString *postPath = @"set-deferral-time";
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

    NSString *dateString = [formatter stringFromDate:date];

    NSLog(@"Posting date string: '%@' to path '%@'", dateString, postPath);
    [self doHttpPost:postPath withData:dateString];
}

- (void) clearDeferralDate
{
    NSLog(@"Clearing deferral date");
    [self doHttpPost:@"clear-deferral-time" withData:@""];
}

- (void) runWateringNow:(Watering *)watering
{
    NSLog(@"Running watering %@ now", watering.uuid);
    [self doHttpPost:@"run-watering-now" withData:watering.uuid];
}

- (void) deleteWatering:(Watering *)watering
{
    NSLog(@"Deleting watering %@", watering.uuid);
    [self doHttpPost:@"delete-watering" withData:watering.uuid];
}


-(NSDateFormatter*) createDateFormatter:(NSString*)format
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return formatter;
}

- (void) updateWatering:(Watering *)watering
{
    NSLog(@"Updating watering %@", watering.uuid);
    NSString *yamlString = [NSString stringWithFormat:
                            @"uuid: %@\n"
                            "enabled: %@\n"
                            "schedule type: %d\n"
                            "period days: %d\n"
                            "start time: '%@'\n"
                            , watering.uuid
                            , watering.enabled ? @"true" : @"false"
                            , watering.scheduleType
                            , watering.periodDays
                            , [[self createDateFormatter:@"HH:mm:ss"] stringFromDate:watering.startTime]
                            ];
    
    if (watering.scheduleType == SingleShot)
    {
        yamlString = [yamlString stringByAppendingFormat:
                      @"start date: '%@'\n"
                      , [[self createDateFormatter:@"yyyy-MM-dd"] stringFromDate:watering.startDate]
                      ];
    }

    yamlString = [yamlString stringByAppendingString:@"zone durations:\n"];
    for (ZoneDuration *duration in watering.zoneDurations)
    {
        yamlString = [yamlString stringByAppendingFormat:
                      @"- [%d, %d]\n"
                      , duration.zone, duration.minutes
                      ];
    }

    yamlString = [yamlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSLog(@"  YAML:\n%@", yamlString);
    [self doHttpPost:@"update-watering" withData:yamlString];
}

- (void) sendZoneNames:(NSDictionary *)names
{
    NSString *yamlString = @"{";
    BOOL first = YES;
    for (NSString *key in [names allKeys])
    {
        NSInteger zoneNumber = [key integerValue];
        NSString  *zoneName  = [names objectForKey:key];
        yamlString = [yamlString stringByAppendingFormat:@"%@%d: %@", first ? @"" : @", ", zoneNumber, zoneName];
        first = NO;
    }
    yamlString = [yamlString stringByAppendingString:@"}"];
    NSLog(@"   YAML:\n%@", yamlString);
    [self doHttpPost:@"update-zone-info" withData:yamlString];
}

- (void) runZoneNow:(NSInteger)zone forMinutes:(NSInteger)minutes
{
    [self doHttpPost:@"run-zone-now" withData:[NSString stringWithFormat:@"%d %d", zone, minutes]];
}

@end