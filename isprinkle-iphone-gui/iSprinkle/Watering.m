#import "Watering.h"

@implementation Watering
@synthesize wateringName = _wateringName;

- (id)initWithName:(NSString*)name
{
    if ((self = [super init]))
    {
        _wateringName = name;
    }
    return self;
}

- (void)dealloc
{
    self.wateringName = nil;   
    [super dealloc];
}

@end
