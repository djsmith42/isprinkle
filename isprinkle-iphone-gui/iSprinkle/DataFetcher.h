#import <Foundation/Foundation.h>
#import "Status.h"

@interface DataFetcher : NSObject {
    Status        *_status;
    NSMutableData *_receivedData;
    NSTimer       *_timer;
}

- (id) initWithModels:(Status*)status;
- (void) startFetching;

@end
