#import <UIKit/UIKit.h>
#import "Status.h"
#import "DataSender.h"

@interface EditZoneNamesController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    Status *status;
    DataSender *dataSender;
    NSMutableDictionary *userZoneNames; // strings of each zone name
    UITableView *tableView;
    CGFloat animatedDistance;
    UIView *parentView;
}

@property (retain) Status* status;
@property (retain) DataSender *dataSender;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) NSMutableDictionary *userZoneNames;

@property (retain) UIView *parentView;

@end