#import "EditZoneNamesController.h"
#import "EditableDetailCell.h"

@implementation EditZoneNamesController

@synthesize status;
@synthesize tableView;
@synthesize userZoneNames;
@synthesize dataSender;
@synthesize parentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        userZoneNames  = [[NSMutableDictionary alloc] init];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Edit Zone Names";
    self.parentView = [self.tableView superview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [userZoneNames  removeAllObjects];
    for (NSNumber *zoneNumber in [self.status.zoneNames allKeys])
    {
        NSString *zoneName = [self.status.zoneNames objectForKey:zoneNumber];
        [userZoneNames setObject:zoneName forKey:zoneNumber];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userZoneNames.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ZoneNameCell";
    EditableDetailCell *cell = (EditableDetailCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[EditableDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 textFieldFrame:CGRectMake(110, 10, 185, 30) reuseIdentifier:CellIdentifier];
        
        cell.textField.adjustsFontSizeToFitWidth = YES;
        cell.textField.textColor = [UIColor blackColor];
        cell.textField.placeholder = @"Zone name";
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.backgroundColor = [UIColor whiteColor];
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        cell.textField.textAlignment = UITextAlignmentLeft;
        cell.textField.tag = 0;
        cell.textField.delegate = self;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    NSNumber *zoneNumber = [NSNumber numberWithInteger:indexPath.row+1];
    NSString *zoneName   = [userZoneNames objectForKey:zoneNumber];
    cell.textField.text = zoneName;
    cell.textField.tag  = [zoneNumber integerValue];
    cell.textLabel.text = [NSString stringWithFormat:@"Zone %@", zoneNumber];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

# pragma mark - Text Field

// Keyboard dodging code comes from:
// http://stackoverflow.com/questions/1116669/iphone-scroll-table-view-cell-to-visible-above-custom-keyboard-aligned-toolbar

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.parentView.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [self.parentView setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    [userZoneNames setObject:textField.text forKey:[NSNumber numberWithInteger:textField.tag]];
    [self.dataSender sendZoneNames:userZoneNames];
}

- (void) textFieldDidBeginEditing:(UITextField*) textField
{
    CGRect textFieldRect = [self.parentView.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.parentView.window convertRect:self.parentView.bounds fromView:self.parentView];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    
    CGRect viewFrame = self.parentView.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.parentView setFrame:viewFrame];
    
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end