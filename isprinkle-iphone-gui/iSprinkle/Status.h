#import <Foundation/Foundation.h>

@interface Status : NSObject
{
    NSString *_currentAction;
    BOOL      _inDeferralPeriod;
    int       _activeZone;
    NSDate   *_currentDate;
    NSDate   *_deferralDate;
}

- (NSString*) statusSummary;
- (NSString*) prettyDateString;
- (NSString*) prettyDeferralDateString;

@property (retain) NSString* currentAction;
@property          BOOL      inDeferralPeriod;
@property          NSInteger activeZone;
@property (retain) NSDate*   currentDate;
@property (retain) NSDate*   deferralDate;


@end
