#import <Foundation/Foundation.h>

#import "Waterings.h"

@interface Status : NSObject
{
    NSString *_currentAction;
    BOOL      _inDeferralPeriod;
    int       _activeIndex;
    NSDate   *_currentDate;
    NSDate   *_deferralDate;
    Watering *_activeWatering;
    NSMutableDictionary *_zoneNames;
    NSInteger  _zoneCount;
    BOOL      _connected;
}

- (BOOL)      isIdle;
- (NSString*) statusSummary;
- (NSString*) prettyDateString;
- (NSString*) prettyDeferralDateString;
- (NSString*) prettyZoneName:(NSInteger)zoneNumber;

@property (retain) NSString* currentAction;
@property          BOOL      inDeferralPeriod;
@property          NSInteger activeIndex;
@property (retain) NSDate*   currentDate;
@property (retain) NSDate*   deferralDate;
@property (retain) Watering* activeWatering;
@property (retain) NSMutableDictionary *zoneNames;
@property          NSInteger zoneCount;
@property          BOOL connected;

@end
