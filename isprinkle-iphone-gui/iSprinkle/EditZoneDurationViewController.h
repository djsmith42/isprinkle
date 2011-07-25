#import <UIKit/UIKit.h>
#import "Waterings.h"

@interface EditZoneDurationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSInteger zone;
    NSInteger minutes;
    NSInteger zoneDurationIndex;
}

@property (retain) IBOutlet UITableView *tableView;
@property NSInteger zone;
@property NSInteger minutes;
@property NSInteger zoneDurationIndex;

@end
