#import <Foundation/Foundation.h>
#import "Waterings.h"

@interface DataSender : NSObject
{
    NSMutableData *_receivedData;
}

- (void) sendDeferralDate:(NSDate*)date;
- (void) clearDeferralDate;
- (void) runWateringNow:(Watering*)watering;
- (void) deleteWatering:(Watering*)watering;

@end
