#import "RootViewController.h"
#import "EditDeferralTimeController.h"
#import "Watering.h"

@implementation RootViewController

@synthesize waterings                  = _waterings;
@synthesize status                     = _status;
@synthesize dataFetcher                = _dataFetcher;
@synthesize editDeferralTimeController = _editDeferralTimeController;

static const NSInteger SectionCount    = 3;
static const NSInteger HeaderSection   = 0;
static const NSInteger WateringSection = 1;
static const NSInteger SetupSection    = 2;

// In the header section:
static const NSInteger HeaderSectionRows = 2;
static const NSInteger StatusRow         = 0;
static const NSInteger TimeRow           = 1;

// In the setup section:
static const NSInteger SetupSectionRows  = 2;
static const NSInteger SetupDeferralRow  = 0;
static const NSInteger SetupZoneNamesRow = 1;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup fake waterings (FIXME: We'll need to download these from the server)
    Watering *watering1 = [[Watering alloc] initWithName:@"Watering 1"];
    Watering *watering2 = [[Watering alloc] initWithName:@"Watering 2"];
    Watering *watering3 = [[Watering alloc] initWithName:@"Watering 3"];

    self.title       = @"iSprinkle";
    self.waterings   = [NSMutableArray arrayWithObjects:watering1, watering2, watering3, nil];
    self.status      = [[Status alloc] init];
    self.dataFetcher = [[DataFetcher alloc] initWithModels:self.status];

    [self.status addObserver:self forKeyPath:@"currentAction"    options:0 context:nil];
    [self.status addObserver:self forKeyPath:@"inDeferralPeriod" options:0 context:nil];
    [self.dataFetcher startFetching];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if (section == HeaderSection)
    {
        return HeaderSectionRows;
    }
    else if (section == WateringSection)
        return _waterings.count;
    else if (section == SetupSection)
        return SetupSectionRows;
    else
        return 0;
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
        Watering *doc = [_waterings objectAtIndex:indexPath.row];
        cell.textLabel.text = doc.wateringName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"waterdrop.png"];
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
            cell.textLabel.text = @"Deferral time";
            cell.detailTextLabel.text = [_status prettyDeferralDateString];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SetupSection && indexPath.row == SetupDeferralRow)
    {
        if (_editDeferralTimeController == nil)
        {
            _editDeferralTimeController = [[[EditDeferralTimeController alloc] initWithNibName:@"EditDeferralTimeController" bundle:[NSBundle mainBundle]] autorelease];
        }
        
        [self.navigationController pushViewController:_editDeferralTimeController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.editDeferralTimeController = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
    [_waterings release];
    _waterings = nil;
    [_editDeferralTimeController release];
    _editDeferralTimeController = nil;
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
