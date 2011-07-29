#import <UIKit/UIKit.h>
#import "Waterings.h"
#import "Status.h"

@interface EditZoneDurationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSInteger zone;
    NSInteger minutes;
    NSInteger zoneDurationIndex;
    Status *status;
}

@property (retain) IBOutlet UITableView *tableView;
@property NSInteger zone;
@property NSInteger minutes;
@property NSInteger zoneDurationIndex;
@property (retain) Status *status;

@end
