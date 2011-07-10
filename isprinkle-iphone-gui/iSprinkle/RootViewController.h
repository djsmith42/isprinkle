#import <UIKit/UIKit.h>
#import "DataFetcher.h"
#import "DataSender.h"
#import "Status.h"
#import "EditDeferralTimeController.h"

@class EditDeferralTimeController;

@interface RootViewController : UITableViewController
{
    NSMutableArray *_waterings;
    Status         *_status;
    DataFetcher    *_dataFetcher;
    DataSender     *_dataSender;
    EditDeferralTimeController *_editDeferralTimeController;
}

@property (retain) NSMutableArray *waterings;
@property (retain) DataFetcher    *dataFetcher;
@property (retain) DataSender     *dataSender;
@property (retain) Status         *status;
@property (retain) EditDeferralTimeController *editDeferralTimeController;

@end