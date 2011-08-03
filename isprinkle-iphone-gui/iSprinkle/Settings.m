#import "Settings.h"

@implementation Settings

static NSString *HostKey = @"host";
static NSInteger PortNumber = 8080;

static NSMutableArray *observerTargets = nil;
static NSMutableArray *observerActions = nil;

+(void)addObserver:(id)target withAction:(SEL)action
{
    if(observerTargets == nil)
    {
        // FIXME one-time memory leak:
        observerTargets = [[NSMutableArray alloc] init];
        observerActions = [[NSMutableArray alloc] init];
    }

    [observerActions addObject:[NSValue valueWithPointer:action]];
    [observerTargets addObject:target];
}

+(NSString*)hostName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:HostKey];
}

+(NSInteger)portNumber
{
    return PortNumber;
}

+(void)settingsChanged
{
    for (NSInteger i=0; i<observerTargets.count; i++)
    {
        id target = [observerTargets objectAtIndex:i];
        NSValue *selectorValue = [observerActions objectAtIndex:i];
        SEL sel = [selectorValue pointerValue];
        
        [target performSelector:sel];
    }
}

+(void)setHostName:(NSString*)hostname
{
    NSLog(@"Saving hostname setting: '%@'", hostname);
    [[NSUserDefaults standardUserDefaults] setObject:hostname forKey:HostKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self settingsChanged];
}

@end
