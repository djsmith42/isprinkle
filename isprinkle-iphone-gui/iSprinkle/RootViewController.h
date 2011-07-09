#import <UIKit/UIKit.h>
#import "DataFetcher.h"
#import "Status.h"

@interface RootViewController : UITableViewController {
    NSMutableArray *_waterings;
    Status         *_status;
    DataFetcher    *_dataFetcher;
}

@property (retain) NSMutableArray *waterings;
@property (retain) DataFetcher    *dataFetcher;
@property (retain) Status         *status;

@end
