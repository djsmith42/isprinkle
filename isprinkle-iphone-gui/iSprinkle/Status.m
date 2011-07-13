#import "Status.h"


@implementation Status

@synthesize currentAction    = _currentAction;
@synthesize inDeferralPeriod = _inDeferralPeriod;
@synthesize activeZone       = _activeZone;
@synthesize currentDate      = _currentDate;
@synthesize deferralDate     = _deferralDate;
@synthesize activeWatering   = _activeWatering;


- (id) init
{
    if ((self = [super init]))
    {
        self.currentAction = @"Loading...";
        self.inDeferralPeriod = false;
    }
    return self;
}

- (NSString*) statusSummary
{
    NSString *ret;
    if (self.inDeferralPeriod)
        ret = @"In Deferral";
    else
    {
        // Title case the current action for prettier display:
        ret = [[[self.currentAction substringToIndex:1] uppercaseString]
               stringByAppendingString:[self.currentAction substringFromIndex:1]];
        
        if ([[self.currentAction lowercaseString] isEqualToString:@"watering"] && self.activeZone > 0)
        {
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@" Zone %d", self.activeZone]];
        }
    }

    return ret;
}

- (NSString*) _prettyStringFromDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    return [formatter stringFromDate:date];    
}

- (NSString*) prettyDateString
{
    return [self _prettyStringFromDate:self.currentDate];
}

- (NSString*) prettyDeferralDateString
{
    NSString *ret = @"None";
    
    if (self.deferralDate != nil)
    {
        ret = [self _prettyStringFromDate:self.deferralDate];
        
        if (self.inDeferralPeriod == NO)
            ret = [ret stringByAppendingString:@" (past)"];
    }
    
    return ret;
}

- (void) dealloc
{
    self.currentAction = nil;
    [super dealloc];
}

@end