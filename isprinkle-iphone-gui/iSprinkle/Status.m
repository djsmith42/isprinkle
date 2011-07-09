#import "Status.h"


@implementation Status

@synthesize currentAction    = _currentAction;
@synthesize inDeferralPeriod = _inDeferralPeriod;

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
        // Title case the current action for prettier display:
        ret = [[[self.currentAction substringToIndex:1] uppercaseString]
               stringByAppendingString:[self.currentAction substringFromIndex:1]];

    return ret;
}

- (void) dealloc
{
    self.currentAction = nil;
    [super dealloc];
}

@end
