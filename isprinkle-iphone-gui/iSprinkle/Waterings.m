#import "Waterings.h"

@implementation ZoneDuration
@synthesize zone    = _zone;
@synthesize minutes = _minutes;

-(void) copyDataFromZoneDuration:(ZoneDuration *)zoneDuration
{
    self.zone    = zoneDuration.zone;
    self.minutes = zoneDuration.minutes;
}
@end

@implementation Watering
@synthesize uuid         = _uuid;
@synthesize enabled      = _enabled;
@synthesize periodDays   = _periodDays;
@synthesize startTime    = _startTime;
@synthesize scheduleType = _scheduleType;
@synthesize zoneDurations = _zoneDurations;

- (id)init
{
    if ((self = [super init]))
    {
        self.zoneDurations = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (NSString*) prettyDescription
{
    switch (self.scheduleType)
    {
        case EveryNDays:
            return [NSString stringWithFormat:@"Every %d days", self.periodDays];
        case FixedDaysOfWeek:
            return @"Days of week (FIXME)";
        case SingleShot:
            return @"Single shot (FIXME)";
    }
    
    NSAssert(false, @"Unhandled schedule type in switch statement");
    return @"";
}

- (void)copyDataFromWatering:(Watering*)watering
{
    self.uuid = watering.uuid;
    self.enabled = watering.enabled;
    self.periodDays = watering.periodDays;
    self.startTime = watering.startTime;
    self.scheduleType = watering.scheduleType;
    
    [self.zoneDurations removeAllObjects];
    NSEnumerator *e = [watering.zoneDurations objectEnumerator];
    ZoneDuration *tempZoneDuration;
    while ((tempZoneDuration = [e nextObject]) != nil)
    {
        ZoneDuration *z = [[ZoneDuration alloc] init];
        [z copyDataFromZoneDuration:tempZoneDuration];
        [self.zoneDurations addObject:z];
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation Waterings

@synthesize waterings = _waterings;
@synthesize watcherKey = _watcherKey;

-(NSInteger) count
{
    return [self.waterings count];
}

-(id) init
{
    if ((self = [super init]))
    {
        self.waterings = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(void) addOrUpdateWatering:(Watering *)watering
{
    Watering *w = [self wateringWithUuid:watering.uuid];
    if (w != nil)
    {
        [w copyDataFromWatering:watering];
    }
    else
    {
        Watering *newWatering = [[Watering alloc] init];
        [newWatering copyDataFromWatering:watering];
        [_waterings addObject:newWatering];
    }
    
    self.watcherKey = @"magic";
}

-(Watering*) wateringWithUuid:(NSString *)uuid
{
    NSEnumerator *e = [self.waterings objectEnumerator];
    Watering *w;
    while ((w = [e nextObject]) != nil)
    {
        if ([w.uuid isEqualToString:uuid])
        {
            return w;
        }
    }
    
    return nil;
}

-(Watering*) wateringAtIndex:(NSInteger)index
{
    return [self.waterings objectAtIndex:index];
}

@end
