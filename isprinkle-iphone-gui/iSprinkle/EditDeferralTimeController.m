#import "EditDeferralTimeController.h"

@implementation EditDeferralTimeController

@synthesize status     = _status;
@synthesize datePicker = _datePicker;
@synthesize dataSender = _dataSender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"EditDeferralTimeController being deallocated");
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDate *date = self.status.deferralDate != nil ?
        self.status.deferralDate :
        self.status.currentDate;
    
    [self.datePicker setDate:date];
}

- (void)dateEntered:(id)sender
{
    NSLog(@"%s date: %@", __FUNCTION__, [self.datePicker date]);
    [self.dataSender sendDeferralDate:[self.datePicker date]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end