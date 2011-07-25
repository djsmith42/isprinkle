#import <UIKit/UIKit.h>
#import "Waterings.h"
#import "DataSender.h"
#import "EditZoneDurationViewController.h"

@interface EditWateringController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate>
{
    UITableView   *tableView;
    Watering      *watering;
    DataSender    *dataSender;
    UIDatePicker  *startDatePicker;
    UIActionSheet *startDateActionSheet;
    UIDatePicker  *startTimePicker;
    UIActionSheet *startTimeActionSheet;
    UIActionSheet *deleteActionSheet;
    UIPickerView  *periodPicker;
    UIButton      *editZonesButton;
    UIView        *editZonesHeader;
    NSMutableArray *tempEditingZones;
    UIActionSheet *zoneActionSheet;
    UIPickerView  *zonePicker;
    UIActionSheet *minutesActionSheet;
    UIPickerView  *minutesPicker;
    NSInteger      clickedZoneDurationNumber;
    EditZoneDurationViewController *editZoneDurationViewController;
    BOOL editingZoneDuration;
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
@property (retain) UIActionSheet *runNowActionSheet;
@property (retain) DataSender    *dataSender;
@property (retain) UIPickerView  *periodPicker;
@property (retain) UIActionSheet *periodActionSheet;
@property (retain) UIButton      *editZonesButton;
@property (retain) UIView        *editZonesHeader;
@property (retain) NSMutableArray *tempEditingZones;
@property (retain) UIActionSheet *zoneActionSheet;
@property (retain) UIPickerView  *zonePicker;
@property (retain) UIActionSheet *minutesActionSheet;
@property (retain) UIPickerView  *minutesPicker;
@property ()       NSInteger     clickedZoneDurationNumber;
@property (retain) EditZoneDurationViewController *editZoneDurationViewController;
@property ()       BOOL          editingZoneDuration;
@end
