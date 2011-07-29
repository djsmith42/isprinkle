#import <Foundation/Foundation.h>

#import "Waterings.h"

@interface Status : NSObject
{
    NSString *_currentAction;
    BOOL      _inDeferralPeriod;
    int       _activeZone;
    NSDate   *_currentDate;
    NSDate   *_deferralDate;
    Watering *_activeWatering;
    NSMutableDictionary *_zoneNames;
}

- (NSString*) statusSummary;
- (NSString*) prettyDateString;
- (NSString*) prettyDeferralDateString;
- (NSString*) prettyZoneName:(NSInteger)zoneNumber;

@property (retain) NSString* currentAction;
@property          BOOL      inDeferralPeriod;
@property          NSInteger activeZone;
@property (retain) NSDate*   currentDate;
@property (retain) NSDate*   deferralDate;
@property (retain) Watering* activeWatering;
@property (retain) NSMutableDictionary *zoneNames;

@end
