#import <UIKit/UIKit.h>
#import "Status.h"


@interface EditDeferralTimeController : UIViewController {
    Status *_status;
    BOOL    _deferralEnabled;
    NSDate* _deferralDate;
}

@property (retain) NSDate *deferralDate;
@property          BOOL    deferralEnabled;

- (IBAction) toggleOnForEnabledSwitch:(id)sender;
- (IBAction) dateChosen:(id)sender;

@end
