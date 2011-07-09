#import <Foundation/Foundation.h>

@interface Status : NSObject
{
    NSString *_currentAction;
    BOOL      _inDeferralPeriod;
}

- (NSString*) statusSummary;

@property (retain) NSString* currentAction;
@property          BOOL      inDeferralPeriod;

@end
