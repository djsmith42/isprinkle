#import <UIKit/UIKit.h>
#import "DataFetcher.h"
#import "DataSender.h"
#import "Status.h"

@interface RootViewController : UITableViewController <UIActionSheetDelegate>
{
    Waterings      *_waterings;
    Status         *_status;
    DataFetcher    *_dataFetcher;
    DataSender     *_dataSender;
    UIDatePicker   *_deferralDatePicker;
}

@property (retain) Waterings    *waterings;
@property (retain) DataFetcher  *dataFetcher;
@property (retain) DataSender   *dataSender;
@property (retain) Status       *status;
@property (retain) UIDatePicker *deferralDatePicker;

@end