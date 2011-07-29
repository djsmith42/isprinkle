#import <Foundation/Foundation.h>
#import "Status.h"
#import "Waterings.h"

@interface DataFetcher : NSObject {
    Status        *_status;
    Waterings     *_waterings;
    NSMutableData *_receivedData;
    enum State { FetchingStatus, FetchingWaterings, FetchingZoneInfo } _state;
    BOOL           _firstTime;
    NSURLConnection *_connection;
}

@property enum State state;

- (id) initWithModels:(Status*)status waterings:(Waterings*)waterings;
- (void) startFetching;

@end
