#import "RootViewController.h"
#import "Waterings.h"

@implementation RootViewController

@synthesize waterings                  = _waterings;
@synthesize status                     = _status;
@synthesize dataFetcher                = _dataFetcher;
@synthesize dataSender                 = _dataSender;
@synthesize deferralDatePicker         = _deferralDatePicker;
@synthesize editWateringController     = _editWateringController;
@synthesize deferralActionSheet        = _deferralActionSheet;

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
static const NSInteger SetupSectionRows  = 2;
static const NSInteger SetupDeferralRow  = 0;
static const NSInteger SetupZoneNamesRow = 1;

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
    [self.status    addObserver:self forKeyPath:@"activeZone"       options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"deferralDate"     options:0 context:nil];
    [self.status    addObserver:self forKeyPath:@"activeWatering"   options:0 context:nil];
    [self.waterings addObserver:self forKeyPath:@"watcherKey"       options:0 context:nil];

    [self.dataFetcher startFetching];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
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
            cell.imageView.image = [UIImage imageNamed:@"waterdrop.png"];
            cell.textLabel.textColor = (self.status.activeWatering == watering ?
                                        [UIColor blueColor] : [UIColor blackColor]);
        }
        else
        {
            cell.textLabel.text = @"Deleted";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor redColor];
        }
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
            cell.textLabel.text = @"Current action";
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
            cell.detailTextLabel.textColor = self.status.inDeferralPeriod ? [UIColor redColor] : [UIColor blackColor];
        }
        else if (indexPath.row == SetupZoneNamesRow)
        {
            static NSString *ZoneNamesCellIdentifier = @"SetupZoneNamesCell";
            cell = [tableView dequeueReusableCellWithIdentifier:ZoneNamesCellIdentifier];
            if (cell == nil)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZoneNamesCellIdentifier] autorelease];
            cell.textLabel.text = @"Zone names";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == HeaderSection)
    {
        return @"Status";
    }
    else if (section == WateringSection)
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
        self.deferralDatePicker = [[UIDatePicker alloc] init];
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
    }
    
    self.deferralDatePicker.date = self.status.deferralDate != nil ?
    self.status.deferralDate :
    self.status.currentDate;
    
    [self.deferralActionSheet showInView:self.tableView];
    [self.deferralActionSheet addSubview:self.deferralDatePicker];
    [self.deferralActionSheet sendSubviewToBack:self.deferralDatePicker];
    [self.deferralActionSheet setBounds:CGRectMake(0,0,320, 590)];

    CGRect pickerRect = [self.deferralDatePicker bounds];
    pickerRect.origin.y = -160;
    [self.deferralDatePicker setBounds:pickerRect];
}

- (void)navigateToWatering:(Watering*)watering
{
    if (self.editWateringController == nil)
    {
        self.editWateringController = [[[EditWateringController alloc] initWithNibName:@"EditWateringController" bundle:[NSBundle mainBundle]] autorelease];
    }

    self.editWateringController.watering = watering;
    self.editWateringController.dataSender = self.dataSender;
    [self.navigationController pushViewController:self.editWateringController animated:YES];
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
}

@end
