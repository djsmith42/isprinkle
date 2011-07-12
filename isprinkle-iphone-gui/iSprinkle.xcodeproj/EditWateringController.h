#import <UIKit/UIKit.h>
#import "Waterings.h"

@interface EditWateringController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    Watering    *watering;
}

@property (retain) IBOutlet UITableView *tableView;
@property (retain) Watering *watering;
@end
