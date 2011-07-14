#import <UIKit/UIKit.h>
#import "Waterings.h"

@interface EditWateringController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    UITableView   *tableView;
    Watering      *watering;
    UIDatePicker  *startDatePicker;
    UIActionSheet *startDateActionSheet;
    UIDatePicker  *startTimePicker;
    UIActionSheet *startTimeActionSheet;
}

@property (retain) IBOutlet UITableView *tableView;
@property (retain) Watering      *watering;
@property (retain) UIDatePicker  *startDatePicker;
@property (retain) UIActionSheet *startDateActionSheet;
@property (retain) UIDatePicker  *startTimePicker;
@property (retain) UIActionSheet *startTimeActionSheet;
@end
