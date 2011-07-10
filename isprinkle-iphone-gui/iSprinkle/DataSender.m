#import "DataSender.h"

@implementation DataSender

static const NSString *HostName = @"10.42.42.11";
static const NSInteger Port     = 8080;

- (void) sendDeferralDate:(NSDate *)date
{
    // TODO Send it
    
    NSString *dateString = @"";
    NSString *postPath = @"clear-deferral-time";
    
    if (date != nil)
    {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        dateString = [formatter stringFromDate:date];
        postPath   = @"set-deferral-time";
    }
    
    NSLog(@"Posting date string: '%@'", dateString);

    NSData *postData = [dateString dataUsingEncoding:NSUTF8StringEncoding];

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

@end
