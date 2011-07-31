#import "SettingsViewController.h"
#import "ConnectionTester.h"
#import "Settings.h"

@implementation SettingsViewController

@synthesize navigationController;
@synthesize connectionTestLabel;
@synthesize hostNameTextField;
@synthesize activityIndicator;

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

- (void)viewWillAppear:(BOOL)animated
{
    self.activityIndicator.hidden   = YES;
    self.connectionTestLabel.hidden = YES;
    
    closeOnSuccesfulTest = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)_startConnectionTest
{
    self.connectionTestLabel.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

    [[[ConnectionTester alloc] init] testConnection:self.hostNameTextField.text
                                             target:self
                                         goodAction:@selector(_connectionTestedGood)
                                          badAction:@selector(_connectionTestedBad:)];
}

-(IBAction) doneButtonClicked
{
    closeOnSuccesfulTest = YES;
    [self _startConnectionTest];
}

-(IBAction) hostNameTextFieldChanged
{
    NSLog(@"%s text: '%@'", __FUNCTION__, self.hostNameTextField.text);
}

-(void)_connectionTestedGood
{
    NSLog(@"%s", __FUNCTION__);
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.connectionTestLabel.hidden = YES;
    
    if (closeOnSuccesfulTest)
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [Settings setHostName:self.hostNameTextField.text];
    }
}

-(void)_connectionTestedBad:(NSError*)error
{
    NSLog(@"%s %@", __FUNCTION__, error);
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.connectionTestLabel.hidden = NO;
    self.connectionTestLabel.text = [NSString stringWithFormat:@"Woops: %@", [error localizedDescription]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    closeOnSuccesfulTest = NO;
    [self _startConnectionTest];
    return YES;
}

@end