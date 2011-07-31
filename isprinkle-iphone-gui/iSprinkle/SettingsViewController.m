#import "SettingsViewController.h"
#import "Settings.h"

@implementation SettingsViewController

@synthesize navigationController;
@synthesize hostNameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)populateDisplay
{
    NSLog(@"Populating host name text field with '%@'", [Settings hostName]);
    if(self.hostNameTextField == nil)
        NSLog(@"It's nil dude!!!!");
    self.hostNameTextField.text = [Settings hostName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) doneButtonClicked
{
    [Settings setHostName:hostNameTextField.text];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end