#import "DataSender.h"

@implementation DataSender

// FIXME The host and port need to come from user input, not hard-coded:
static const NSString *HostName = @"10.42.42.11";
static const NSInteger Port     = 8080;

- (void) doHttpPost:(NSString*)postPath withData:(NSString*)withData
{
    NSData *postData = [withData dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", HostName, Port, postPath]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) 
    {
        _receivedData = [[NSMutableData data] retain];
    } 
    else 
    {
        NSLog(@"Fail to POST");
        // inform the user that the download could not be made
    }
}

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

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self _alert:[NSString stringWithFormat:@"Woops. %@", [error localizedDescription]]];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] != 200)
    {
        [self _alert:[NSString stringWithFormat:@"Woops. Could not update the sprinkler unit (code %d)!", [httpResponse statusCode]]];
    }
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

@end