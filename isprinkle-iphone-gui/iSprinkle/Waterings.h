#import <Foundation/Foundation.h>

@interface ZoneDuration : NSObject
{
    NSInteger _zone;
    NSInteger _minutes;
}

@property NSInteger zone;
@property NSInteger minutes;

-(void) copyDataFromZoneDuration:(ZoneDuration*)zoneDuration;
@end

@interface Watering : NSObject
{
    NSString *_uuid;
    BOOL _enabled;
    enum ScheduleType { EveryNDays = 0, FixedDaysOfWeek = 1, SingleShot = 2 } _scheduleType;
    NSInteger _periodDays;
    NSDate *_startTime;
    NSMutableArray *_zoneDurations;
}

@property (retain) NSString *uuid;
@property          BOOL enabled;
@property          enum ScheduleType scheduleType;
@property          NSInteger periodDays;
@property (retain) NSDate *startTime;
@property (retain) NSMutableArray *zoneDurations;

-(NSString*) prettyDescription;
-(void) copyDataFromWatering:(Watering*) watering;

@end

@interface Waterings : NSObject
{
    NSMutableArray *_waterings;
    NSString *_watcherKey;
}

@property (retain) NSMutableArray *waterings;
@property (retain) NSString *watcherKey; // For KVO to work easily

-(NSInteger) count;
-(void) addOrUpdateWatering:(Watering*)watering;
-(Watering*) wateringAtIndex: (NSInteger)index;
-(Watering*) wateringWithUuid:(NSString*)uuid;

@end
