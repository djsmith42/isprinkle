#import <UIKit/UIKit.h>
#import "Waterings.h"
#import "DataSender.h"

@interface EditWateringController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    UITableView   *tableView;
    Watering      *watering;
    DataSender    *dataSender;
    UIDatePicker  *startDatePicker;
    UIActionSheet *startDateActionSheet;
    UIDatePicker  *startTimePicker;
    UIActionSheet *startTimeActionSheet;
    UIActionSheet *deleteActionSheet;
    UIView        *tableFooterView;
}

- (IBAction) runNowButtonPressed:(id)sender;
- (IBAction) deleteButtonPressed:(id)sender;

@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UIToolbar   *toolBar;

@property (retain) Watering      *watering;
@property (retain) UIDatePicker  *startDatePicker;
@property (retain) UIActionSheet *startDateActionSheet;
@property (retain) UIDatePicker  *startTimePicker;
@property (retain) UIActionSheet *startTimeActionSheet;
@property (retain) UIActionSheet *deleteActionSheet;
@property (retain) DataSender    *dataSender;
@end
