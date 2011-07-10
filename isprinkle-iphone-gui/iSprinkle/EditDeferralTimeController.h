#import <UIKit/UIKit.h>
#import "Status.h"
#import "DataSender.h"


@interface EditDeferralTimeController : UIViewController {
    Status     *_status;
    DataSender *_dataSender;
    
    UIDatePicker *_datePicker;
    UISwitch     *_enableSwitch;
}

@property (retain) Status *status;
@property (retain) DataSender *dataSender;

@property (retain) IBOutlet UIDatePicker *datePicker;
@property (retain) IBOutlet UISwitch     *enableSwitch;

- (IBAction) dateEntered:(id)sender;
- (IBAction) enableSwitchToggled:(id)sender;

@end
