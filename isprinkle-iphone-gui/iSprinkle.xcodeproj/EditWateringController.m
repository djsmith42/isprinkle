#import "EditWateringController.h"

@implementation EditWateringController

@synthesize tableView;
@synthesize watering;

static const NSInteger EnabledSection = 0;
static const NSInteger ScheduleTypeSection = 1;
static const NSInteger DateSection = 2;
static const NSInteger ZoneDurationsSection = 3;


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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.watering.enabled)
        return 4;
    else
        return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == EnabledSection)
        return 1;
    else if(section == ScheduleTypeSection)
        return 3;
    else if(section == DateSection)
    {
        if(self.watering.scheduleType == SingleShot)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
    else if(section == ZoneDurationsSection)
        return [self.watering.zoneDurations count];
    else
        return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == ScheduleTypeSection)
    {
        return @"Watering type";
    }
    else if (section == ZoneDurationsSection)
    {
        return @"Zone Waterings";
    }
    else
    {
        return @"";
    }
}

-(void) enabledSwitchToggled:(id)sender
{
    UISwitch *switchView = (UISwitch*)sender;
    self.watering.enabled = switchView.on;
 
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(ScheduleTypeSection, ZoneDurationsSection)];

    [self.tableView beginUpdates];
    if (switchView.on)
    {
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section == EnabledSection)
    {
        static NSString *CellIdentifier = @"EnabledCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.text = @"Enable";
            cell.accessoryType = UITableViewCellAccessoryNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView addTarget:self action:@selector(enabledSwitchToggled:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        UISwitch *switchView = (UISwitch*)cell.accessoryView;
        [switchView setOn:self.watering.enabled animated:NO];
    }
    else if(indexPath.section == ScheduleTypeSection)
    {
        static NSString *CellIdentifier = @"CheckMarkCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if (indexPath.row == 0)
            cell.textLabel.text = @"Every N days";
        else if (indexPath.row == 1)
            cell.textLabel.text = @"Days of the week";
        else if (indexPath.row == 2)
            cell.textLabel.text = @"Single shot";
        
        cell.detailTextLabel.text = self.watering.uuid;
        
        if (self.watering.scheduleType == indexPath.row)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if(indexPath.section == ZoneDurationsSection)
    {
        static NSString *CellIdentifier = @"ZoneDurationCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }

        cell.textLabel.text       = [NSString stringWithFormat:@"Zone %d",    [[self.watering.zoneDurations objectAtIndex:indexPath.row] zone]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d minutes", [[self.watering.zoneDurations objectAtIndex:indexPath.row] minutes]];
    }
    else if(indexPath.section == DateSection)
    {
        static NSString *CellIdentifier = @"DateCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = @"Start Time";
            cell.detailTextLabel.text = [self.watering prettyStartTime];
        }
        else if(indexPath.row == 1)
        {
            cell.textLabel.text = @"Start Date";
            cell.detailTextLabel.text = [self.watering prettyStartDate];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        
    }
}

@end
