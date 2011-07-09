#import <UIKit/UIKit.h>
#import "DataFetcher.h"
#import "Status.h"

@class EditDeferralTimeController;

@interface RootViewController : UITableViewController {
    NSMutableArray *_waterings;
    Status         *_status;
    DataFetcher    *_dataFetcher;
    EditDeferralTimeController *_editDeferralTimeController;
}

@property (retain) NSMutableArray *waterings;
@property (retain) DataFetcher    *dataFetcher;
@property (retain) Status         *status;
@property (retain) EditDeferralTimeController *editDeferralTimeController;

@end
