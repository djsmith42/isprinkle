#import "RootViewController.h"
#import "ActionSheetPicker.h"
#import "Waterings.h"
#import "Utils.h"

@implementation RootViewController

@synthesize waterings                  = _waterings;
@synthesize status                     = _status;
@synthesize dataFetcher                = _dataFetcher;
@synthesize dataSender                 = _dataSender;
@synthesize deferralDatePicker         = _deferralDatePicker;
@synthesize editWateringController     = _editWateringController;
@synthesize editZoneNamesController    = _editZoneNamesController;
@synthesize deferralActionSheet        = _deferralActionSheet;
@synthesize connetingViewController    = _connectingViewController;

// Sections in the root table view:
static const NSInteger SectionCount    = 3;
static const NSInteger HeaderSection   = 0;
static const NSInteger WateringSection = 1;
static const NSInteger SetupSection    = 2;

// Rows in the header section:
static const NSInteger HeaderSectionRows = 2;
static const NSInteger StatusRow         = 0;
static const NSInteger TimeRow           = 1;

// Rows in the setup section:
static const NSInteger SetupSectionRows  = 3;
static const NSInteger SetupDeferralRow  = 0;
static const NSInteger SetupZoneNamesRow = 1;
static const NSInteger QuickRunRow       = 2;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title       = @"iSprinkle";
    self.waterings   = [[Waterings alloc] init];
    self.status      = [[Status alloc] init];
    self.dataFetcher = [[DataFetcher alloc] initWithModels:self.status waterings:self.waterings];
    self.dataSender  = [[DataSender  alloc] init];

    [self.status    addObserver:self forKeyPath:@"currentAction"    options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"currentDate"      options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"inDeferralPeriod" options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"activeIndex"      options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"deferralDate"     options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"activeWatering"   options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"connected"        options:0 context:nil];
    [self.waterings addObserver:self forKeyPath:@"watcherKey"       options:0 context:nil];

    [self.dataFetcher startFetching];
}

-(void)doneHidingConnectionOverlay
{
    [self.tableView.superview sendSubviewToBack:self.connetingViewController.view];
}

BOOL overlayIsShowing = NO;
-(void)updateConnectingOverlay
{
    if(self.tableView == nil || self.tableView.superview == nil)
    {
        return;
    }

    if(self.connetingViewController == nil)
    {
        self.connetingViewController = [[ConnectingViewController alloc] initWithNibName:@"ConnectingViewController" bundle:[NSBundle mainBundle]];
        [self.tableView.superview addSubview:self.connetingViewController.view];
    }
    
    if(self.tableView.superview.isHidden)
    {
        return;
    }

    if (self.status.connected)
    {
        if (overlayIsShowing)
        {
            overlayIsShowing = NO;
            NSLog(@"Starting overlay fade out");

            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(doneHidingConnectionOverlay)];
            [self.connetingViewController.view setAlpha:0.0];
            [UIView commitAnimations];
        }
    }
    else
    {
        if (!overlayIsShowing)
        {
            overlayIsShowing = YES;
            NSLog(@"Starting overlay fade in");

            [self.tableView.superview bringSubviewToFront:self.connetingViewController.view];

            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [self.connetingViewController.view setAlpha:0.85];
            [UIView commitAnimations];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateConnectingOverlay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if      (section == HeaderSection)   return HeaderSectionRows;
    else if (section == WateringSection) return self.waterings.count;
    else if (section == SetupSection)    return SetupSectionRows;
    else                                 return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == WateringSection)
    {
        static NSString *WateringCellIdentifier = @"WateringCell";
        cell = [tableView dequeueReusableCellWithIdentifier:WateringCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WateringCellIdentifier] autorelease];
        }
        // Configure the cell.
        if (indexPath.row < [self.waterings.waterings count])
        {
            Watering *watering = [self.waterings wateringAtIndex:indexPath.row];
            cell.textLabel.text = [watering prettyDescription];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = (self.status.activeWatering == watering ?
                                        [UIColor blueColor] : [UIColor blackColor]);
        }
        else
        {
            cell.textLabel.text = @"Deleted";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor redColor];
        }

        cell.imageView.image = [Utils scale:[UIImage imageNamed:@"waterdrop.png"]
                                   toHeight:0.66 * [self.tableView rectForRowAtIndexPath:indexPath].size.height];
    }
    else if (indexPath.section == HeaderSection)
    {
        if (indexPath.row == StatusRow)
        {
            static NSString *StatusCellIdentifier = @"StatusCell";
            cell = [tableView dequeueReusableCellWithIdentifier:StatusCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:StatusCellIdentifier] autorelease];
            }

            cell.accessoryType = UITableViewCellAccessoryNone;           
            cell.detailTextLabel.text = [self.status statusSummary];
            cell.textLabel.text = @"Currently";
            cell.imageView.image = [Utils scale:[UIImage imageNamed:([self.status isIdle] ? @"GrayLight.png" : @"GreenLight.png")]
                                       toHeight:0.55 * [self.tableView rectForRowAtIndexPath:indexPath].size.height];
        }
        else if (indexPath.row == TimeRow)
        {
            static NSString *TimeCellIdentifier = @"TimeCell";
            cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TimeCellIdentifier] autorelease];
            }
            cell.textLabel.text = @"Current time";
            cell.detailTextLabel.text = [self.status prettyDateString];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [Utils scale:[UIImage imageNamed:@"Clock.png"]
                                       toHeight:0.55 * [self.tableView rectForRowAtIndexPath:indexPath].size.height];
        }
             
        // Don't the user tap rows in the header section -- they are display only        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    else if (indexPath.section == SetupSection)
    {
        if (indexPath.row == SetupDeferralRow)
        {
            static NSString *SetupCellIdentifier = @"SetupCell";
            cell = [tableView dequeueReusableCellWithIdentifier:SetupCellIdentifier];
            if (cell == nil)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SetupCellIdentifier] autorelease];
            cell.textLabel.text = @"Defer until:";
            cell.detailTextLabel.text = [_status prettyDeferralDateString];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.textColor = self.status.inDeferralPeriod ? [UIColor redColor] : [UIColor grayColor];
            cell.imageView.image = [Utils scale:[UIImage imageNamed:@"Defer.png"]
                                       toHeight:0.55 * [self.tableView rectForRowAtIndexPath:indexPath].size.height];
        }
        else if (indexPath.row == SetupZoneNamesRow)
        {
            static NSString *ZoneNamesCellIdentifier = @"SetupZoneNamesCell";
            cell = [tableView dequeueReusableCellWithIdentifier:ZoneNamesCellIdentifier];
            if (cell == nil)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZoneNamesCellIdentifier] autorelease];
            cell.textLabel.text = @"Zone Names";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [Utils scale:[UIImage imageNamed:@"Settings.png"]
                                       toHeight:0.66 * [self.tableView rectForRowAtIndexPath:indexPath].size.height];

        }
        else if (indexPath.row == QuickRunRow)
        {
            static NSString *CellIdentifier = @"QuickRunCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.text = @"Quick Run";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [Utils scale:[UIImage imageNamed:@"Play.png"]
                                       toHeight:0.66 * [self.tableView rectForRowAtIndexPath:indexPath].size.height];
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == WateringSection)
    {
        return @"Waterings";
    }
    else if (section == SetupSection)
    {
        return @"Setup";
    }
    else
    {
        return nil;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    static const NSInteger ClearButtonIndex = 0;
    static const NSInteger DoneButtonIndex  = 1;

    if (buttonIndex == DoneButtonIndex)
    {
        [self.dataSender sendDeferralDate:self.deferralDatePicker.date];
    }
    else if (buttonIndex == ClearButtonIndex)
    {
        [self.dataSender clearDeferralDate];
    }
    else
    {
        NSAssert(false, @"Bogus button index in didDismissWithButtonIndex");
    }
}

- (void)showDeferralDatePicker
{
    if (self.deferralDatePicker == nil)
    {
        CGRect pickerFrame = CGRectMake(0, 160, 0, 0);
        self.deferralDatePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        self.deferralDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.deferralDatePicker.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    }
 
    if (self.deferralActionSheet == nil)
    {
        self.deferralActionSheet = [[UIActionSheet alloc]
                                              initWithTitle:@"Choose a deferral date"
                                                   delegate:self
                                          cancelButtonTitle:nil 
                                     destructiveButtonTitle:@"Clear Deferral Date"
                                          otherButtonTitles:@"Done", nil];
        [self.deferralActionSheet addSubview:self.deferralDatePicker];
    }
    
    self.deferralDatePicker.date = self.status.deferralDate != nil ?
    self.status.deferralDate :
    self.status.currentDate;
    
    [self.deferralActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.deferralActionSheet setBounds:CGRectMake(0,0,320, 590)];
}

- (void)navigateToWatering:(Watering*)watering
{
    if (self.editWateringController == nil)
    {
        self.editWateringController = [[[EditWateringController alloc] initWithNibName:@"EditWateringController" bundle:[NSBundle mainBundle]] autorelease];
    }

    self.editWateringController.watering = watering;
    self.editWateringController.dataSender = self.dataSender;
    self.editWateringController.status = self.status;
    [self.navigationController pushViewController:self.editWateringController animated:YES];
}

- (void)navigateToZoneNames
{
    if (self.editZoneNamesController == nil)
    {
        self.editZoneNamesController = [[[EditZoneNamesController alloc] initWithNibName:@"EditZoneNamesController" bundle:[NSBundle mainBundle]] autorelease];
    }
    
    self.editZoneNamesController.status = self.status;
    self.editZoneNamesController.dataSender = self.dataSender;
    [self.navigationController pushViewController:self.editZoneNamesController animated:YES];
}

- (void)quickRunTimeWasSelected:(NSNumber*)minutes
{
    NSLog(@"Doing quick run on %@ for %d minutes", [self.status prettyZoneName:_quickRunZoneNumber], [minutes integerValue]+1);
    [self.dataSender runZoneNow:_quickRunZoneNumber forMinutes:[minutes integerValue]+1];
}

- (void)quickRunZoneWasSelected:(NSNumber*)zone
{
    _quickRunZoneNumber = [zone integerValue]+1;

    NSMutableArray *choices = [[NSMutableArray alloc] init];
    for(int i=0; i<60; i++)
    {
        NSString *minutes = i > 0 ?
        [NSString stringWithFormat:@"%d minutes", i+1] :
        @"1 minute";
        
        [choices addObject:minutes];
    }

    [ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow]
                                              data:choices
                                     selectedIndex:((NSInteger)0)
                                            target:self
                                            action:@selector(quickRunTimeWasSelected:)
                                             title:@"How long to water it?"];
    [choices release];
}

- (void)showQuickRun
{
    NSMutableArray *choices = [[NSMutableArray alloc] init];
    for(int i=0; i<self.status.zoneCount; i++)
    {
        NSString *zoneName = [self.status prettyZoneName:(NSInteger)i+1];
        [choices addObject:zoneName];
    }
    
    [ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow]
                                              data:choices
                                     selectedIndex:((NSInteger)0)
                                            target:self
                                            action:@selector(quickRunZoneWasSelected:)
                                             title:@"Which zone to water?"];
    [choices release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SetupSection && indexPath.row == SetupDeferralRow)
    {
        [self showDeferralDatePicker];
    }
    else if (indexPath.section == WateringSection)
    {
        [self navigateToWatering:[self.waterings.waterings objectAtIndex:indexPath.row]];
    }
    else if (indexPath.section == SetupSection && indexPath.row == SetupZoneNamesRow)
    {
        [self navigateToZoneNames];
    }
    else if (indexPath.section == SetupSection && indexPath.row == QuickRunRow)
    {
        [self showQuickRun];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Memory Warning");
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    NSLog(@"RootViewController viewDidUnload");
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
    [_waterings release];
    _waterings = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // This means that our data model has changed somehow
    // (the keyPath and object parameters tell us what changed, if we care)
    //NSLog(@"Model value changed for key '%@'", keyPath);

    // Refresh the entire table view:
    [self.tableView reloadData];
    
    if (self.editWateringController != nil && self.navigationController.visibleViewController == self.editWateringController)
        [self.editWateringController updateWateringDisplay];

    [self updateConnectingOverlay];
}

@end