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
    NSString *postPath = @"clear-deferral-time";
    
    NSLog(@"Posting to '%@'", postPath);
    [self doHttpPost:postPath withData:@""];
}

- (void) runWateringNow:(Watering *)watering
{
    NSString *postPath = @"run-watering-now";
    NSString *postData = watering.uuid;
    [self doHttpPost:postPath withData:postData];
}

- (void) deleteWatering:(Watering *)watering
{
    [self doHttpPost:@"delete-watering" withData:watering.uuid];
}

@end
