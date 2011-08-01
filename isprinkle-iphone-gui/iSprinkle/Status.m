#import "Status.h"


@implementation Status

@synthesize currentAction    = _currentAction;
@synthesize inDeferralPeriod = _inDeferralPeriod;
@synthesize activeIndex      = _activeIndex;
@synthesize currentDate      = _currentDate;
@synthesize deferralDate     = _deferralDate;
@synthesize activeWatering   = _activeWatering;
@synthesize zoneNames        = _zoneNames;
@synthesize zoneCount        = _zoneCount;

- (id) init
{
    if ((self = [super init]))
    {
        self.currentAction = @"Loading...";
        self.inDeferralPeriod = false;
        self.zoneNames = [[NSMutableDictionary alloc] init];
        self.zoneCount = 16; // TODO Get this from the device
        self.activeIndex = -1;
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

        if ([[self.currentAction lowercaseString] isEqualToString:@"watering"] &&
            self.activeIndex >= 0 &&
            self.activeIndex < self.activeWatering.zoneDurations.count)
        {
            ZoneDuration *zoneDuration = [self.activeWatering.zoneDurations objectAtIndex:self.activeIndex];
            NSInteger activeZone = zoneDuration.zone;
            ret = [ret stringByAppendingString:[NSString stringWithFormat:@" %@", [self prettyZoneName:activeZone]]];
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

- (NSString*) prettyZoneName:(NSInteger)zoneNumber
{
    NSString *zoneName = [self.zoneNames objectForKey:[NSNumber numberWithInt:zoneNumber]];
    
    if (zoneName == nil || [zoneName length] == 0)
        zoneName = [NSString stringWithFormat:@"Zone %d", zoneNumber];
    
    return zoneName;
}

- (void) dealloc
{
    self.currentAction = nil;
    self.zoneNames     = nil;
    [super dealloc];
}

@end
