#import "Settings.h"

@implementation Settings

static NSString *HostKey = @"host";
static NSInteger PortNumber = 8080;

+(NSString*)hostName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:HostKey];
}

+(NSInteger)portNumber
{
    return PortNumber;
}

+(void)setHostName:(NSString*)hostname
{
    NSLog(@"Saving hostname setting: '%@'", hostname);
    [[NSUserDefaults standardUserDefaults] setObject:hostname forKey:HostKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
