#import "iSprinkleData.h"


@implementation iSprinkleData
@synthesize title = _title;
@synthesize rating = _rating;

- (id)initWithTitle:(NSString *)title rating:(float)rating {
    if ((self = [super init])) {
        _title = [title copy];
        _rating = rating;
    }
    return self;
}

- (void)dealloc {
    [_title release];
    _title = nil;
    [super dealloc];
}

@end
