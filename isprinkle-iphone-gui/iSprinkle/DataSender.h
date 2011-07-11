#import <Foundation/Foundation.h>


@interface DataSender : NSObject {
    NSMutableData *_receivedData;
}

- (void) sendDeferralDate:(NSDate*)date;
- (void) clearDeferralDate;

@end
