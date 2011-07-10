#import <UIKit/UIKit.h>
#import "Status.h"
#import "DataSender.h"


@interface EditDeferralTimeController : UIViewController {
    Status *_status;
    UIDatePicker *_datePicker;
    DataSender *_dataSender;
}

@property (retain) Status *status;
@property (retain) DataSender *dataSender;
@property (retain) IBOutlet UIDatePicker *datePicker;

- (IBAction) dateEntered:(id)sender;

@end
