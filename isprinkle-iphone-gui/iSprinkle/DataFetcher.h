#import <Foundation/Foundation.h>
#import "Status.h"
#import "Waterings.h"

@interface DataFetcher : NSObject {
    Status        *_status;
    Waterings     *_waterings;
    NSMutableData *_receivedData;
    NSTimer       *_timer;
    enum State { FetchingStatus, FetchingWaterings } _state;
    BOOL           _firstTime;
}

@property enum State state;

- (id) initWithModels:(Status*)status waterings:(Waterings*)waterings;
- (void) startFetching;

@end
