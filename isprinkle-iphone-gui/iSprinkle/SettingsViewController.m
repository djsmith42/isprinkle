#import "SettingsViewController.h"
#import "Settings.h"

@implementation SettingsViewController

@synthesize navigationController;
@synthesize hostNameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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