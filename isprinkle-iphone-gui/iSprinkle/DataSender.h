#import <Foundation/Foundation.h>
#import "Waterings.h"

@interface DataSender : NSObject
{
    NSMutableData *_receivedData;
    NSURLConnection *connection;
}

@property (retain) NSURLConnection *connection;

- (void) sendDeferralDate:(NSDate*)date;
- (void) clearDeferralDate;
- (void) runWateringNow:(Watering*)watering;
- (void) deleteWatering:(Watering*)watering;
- (void) updateWatering:(Watering*)watering;

@end
