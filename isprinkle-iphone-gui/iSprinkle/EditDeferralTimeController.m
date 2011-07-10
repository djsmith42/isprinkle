#import "EditDeferralTimeController.h"

@implementation EditDeferralTimeController

@synthesize status     = _status;
@synthesize dataSender = _dataSender;

// Widgets:
@synthesize datePicker   = _datePicker;
@synthesize enableSwitch = _enableSwitch;

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

- (void)sendDeferralDate
{
    NSDate *dateToSend = nil;
    if ([self.enableSwitch isOn])
    {
        dateToSend = [self.datePicker date];
    }
    
    NSLog(@"Sending deferral date: %@", dateToSend);
    [self.dataSender sendDeferralDate:dateToSend];
}

- (void)dateEntered:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    [self sendDeferralDate];
}

- (void)enableSwitchToggled:(id)sender
{
    NSLog(@"%s switch state: %@", __FUNCTION__, [self.enableSwitch isOn] ? @"On" : @"Off");
    [self.datePicker setEnabled:[self.enableSwitch isOn]];
    [self sendDeferralDate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end