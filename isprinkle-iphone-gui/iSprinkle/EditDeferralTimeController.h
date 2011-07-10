#import <UIKit/UIKit.h>
#import "Status.h"


@interface EditDeferralTimeController : UIViewController {
    Status *_status;
    UIDatePicker *_datePicker;
}

@property (retain) Status *status;
@property (retain) IBOutlet UIDatePicker *datePicker;

- (IBAction) dateEntered:(id)sender;

@end
