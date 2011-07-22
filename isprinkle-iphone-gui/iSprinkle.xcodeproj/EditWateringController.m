#import "EditWateringController.h"

@implementation EditWateringController

@synthesize tableView;
@synthesize watering;
@synthesize startDatePicker;
@synthesize startDateActionSheet;
@synthesize startTimePicker;
@synthesize startTimeActionSheet;
@synthesize deleteActionSheet;
@synthesize runNowActionSheet;
@synthesize toolBar;
@synthesize dataSender;
@synthesize periodPicker;
@synthesize periodActionSheet;

static const NSInteger EnabledSection = 0;
static const NSInteger ScheduleTypeSection = 1;
static const NSInteger WateringEditSection = 2;
static const NSInteger ZoneDurationsSection = 3;

static const NSInteger StartTimeRow = 0;
static const NSInteger StartDateRow = 1;
static const NSInteger PeriodRow    = 1;

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
    self.title = @"Edit Watering";
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
    {
        return 1;
    }
    else if(section == ScheduleTypeSection)
    {
        return 3;
    }
    else if(section == WateringEditSection)
    {
        if(self.watering.scheduleType == SingleShot)
        {
            return 2;
        }
        else if(self.watering.scheduleType  == EveryNDays)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
    else if(section == ZoneDurationsSection)
    {
        return [self.watering.zoneDurations count];
    }
    else
    {
        return 0;
    }
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
    else if(indexPath.section == WateringEditSection)
    {
        static NSString *CellIdentifier = @"DateCell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if(indexPath.row == StartTimeRow)
        {
            cell.textLabel.text = @"Start Time";
            cell.detailTextLabel.text = [self.watering prettyStartTime];
        }
        else
        {
            if(self.watering.scheduleType == SingleShot)
            {
                if(indexPath.row == StartDateRow)
                {
                    cell.textLabel.text = @"Start Date";
                    cell.detailTextLabel.text = [self.watering prettyStartDate];
                }   
            }
            else if(self.watering.scheduleType == EveryNDays)
            {
                if(indexPath.row == PeriodRow)
                {
                    cell.textLabel.text = @"How Often";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Every %d days", self.watering.periodDays];
                }   
            }
        }
    }

    return cell;
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.startDateActionSheet)
    {
        self.watering.startDate = self.startDatePicker.date;
        [self.dataSender updateWatering:self.watering];
        [self.tableView reloadData];
    }
    else if (actionSheet == self.startTimeActionSheet)
    {
        self.watering.startTime = self.startTimePicker.date;
        [self.dataSender updateWatering:self.watering];
        [self.tableView reloadData];
    }
    else if (actionSheet == self.deleteActionSheet && buttonIndex == 0)
    {
        [self.dataSender deleteWatering:self.watering];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (actionSheet == self.runNowActionSheet && buttonIndex == 0)
    {
        [self.dataSender runWateringNow:self.watering];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (actionSheet == self.periodActionSheet)
    {
        NSInteger newPeriod = [self.periodPicker selectedRowInComponent:0] + 1;
        self.watering.periodDays = newPeriod;
        [self.dataSender updateWatering:self.watering];
        [self.tableView reloadData];
    }
}

- (void) _showDeleteConfirmation
{
    if (self.deleteActionSheet == nil)
    {
        self.deleteActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"Confirm watering deletion"
                                     delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete this watering"
                                     otherButtonTitles:nil, nil];
    }
    
    [self.deleteActionSheet showInView:self.tableView];
}

- (void) _showRunNowConfirmation
{
    if (self.runNowActionSheet == nil)
    {
        self.runNowActionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"You wanna run this watering now?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Run this watering now", nil];
    }
    
    [self.runNowActionSheet showInView:self.tableView];
}


- (void) _showStartDatePicker
{
    if (self.startDatePicker == nil)
    {
        CGRect pickerFrame = CGRectMake(0, 100, 0, 0);
        self.startDatePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        self.startDatePicker.datePickerMode = UIDatePickerModeDate;
        self.startDatePicker.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    }
    
    if (self.startDateActionSheet == nil)
    {
        self.startDateActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"Choose a start date"
                                     delegate:self
                                     cancelButtonTitle:nil 
                                     destructiveButtonTitle:nil
                                     otherButtonTitles:@"Done", nil];

        [self.startDateActionSheet addSubview:self.startDatePicker];
    }
    
    self.startDatePicker.date = self.watering.startDate;
    
    [self.startDateActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.startDateActionSheet setBounds:CGRectMake(0, 0, 320, 520)];
}

- (void) _showStartTimePicker
{
    if (self.startTimePicker == nil)
    {
        CGRect pickerFrame = CGRectMake(0, 100, 0, 0);
        self.startTimePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        self.startTimePicker.datePickerMode = UIDatePickerModeTime;
        self.startTimePicker.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    }
    
    if (self.startTimeActionSheet == nil)
    {
        self.startTimeActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"Choose a start time"
                                     delegate:self
                                     cancelButtonTitle:nil 
                                     destructiveButtonTitle:nil
                                     otherButtonTitles:@"Done", nil];

        [self.startTimeActionSheet addSubview:self.startTimePicker];
    }
    
    self.startTimePicker.date = self.watering.startTime;

    [self.startTimeActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.startTimeActionSheet setBounds:CGRectMake(0, 0, 320, 520)];
}

- (void) _showPeriodPicker
{
    if (self.periodPicker == nil)
    {
        CGRect pickerFrame = CGRectMake(0, 100, 0, 0);
        self.periodPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.periodPicker.dataSource = self;
        self.periodPicker.delegate   = self;
        self.periodPicker.showsSelectionIndicator = YES;
    }
    
    if (self.periodActionSheet == nil)
    {
        self.periodActionSheet = [[UIActionSheet alloc]
                                     initWithTitle:@"How often to water?"
                                     delegate:self
                                     cancelButtonTitle:nil 
                                     destructiveButtonTitle:nil
                                     otherButtonTitles:@"Done", nil];
        [self.periodActionSheet addSubview:self.periodPicker];
    }

    [self.periodPicker reloadAllComponents];
    [self.periodPicker selectRow:(self.watering.periodDays-1) inComponent:0 animated:YES];
    [self.periodActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.periodActionSheet setBounds:CGRectMake(0,0,320, 520)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WateringEditSection)
    {
        if(self.watering.scheduleType == SingleShot)
        {
            if (indexPath.row == StartDateRow)
            {
                [self _showStartDatePicker];
            }
        }
        else if(self.watering.scheduleType == EveryNDays)
        {
            if (indexPath.row == PeriodRow)
            {
                [self _showPeriodPicker];
            }
        }

        if (indexPath.row == StartTimeRow)
        {
            [self _showStartTimePicker];
        }
    }
}

- (IBAction) runNowButtonPressed:(id)sender
{
    [self _showRunNowConfirmation];
}

- (IBAction) deleteButtonPressed:(id)sender
{
    [self _showDeleteConfirmation];
}

#pragma mark - periodPicker methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.periodPicker == pickerView)
    {
        return 50;
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(self.periodPicker == pickerView)
    {
        return 1;
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(row == 0)
        return @"Every day";
    else
        return [NSString stringWithFormat:@"Every %d days", (row+1)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Ignore
}

@end