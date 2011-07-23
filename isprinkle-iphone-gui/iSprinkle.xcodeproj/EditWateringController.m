#import "EditWateringController.h"
#import "ActionSheetPicker.h"

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
@synthesize editZonesButton;
@synthesize editZonesHeader;
@synthesize tempEditingZones;

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
        return (self.tableView.editing == YES ? self.tempEditingZones.count : self.watering.zoneDurations.count);
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

        ZoneDuration *zoneDuration = nil;
        if(self.tableView.editing == YES)
            zoneDuration = [self.tempEditingZones objectAtIndex:indexPath.row];
        else
            zoneDuration = [self.watering.zoneDurations objectAtIndex:indexPath.row];
        
        cell.textLabel.text       = [NSString stringWithFormat:@"Zone %d",    zoneDuration.zone];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d minutes", zoneDuration.minutes];
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

// to be used in conjunection with ActionSheetPicker
//- (void)periodWasSelected:(NSNumber*)rowNumber
//{
//}

- (void) _showPeriodPicker
{
    //[ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow] data:[NSArray arrayWithObjects:@"foo",@"bar",@"baz",nil] selectedIndex:1 target:self action:@selector(periodWasSelected:) title:@"Pick a foo!"];

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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == ZoneDurationsSection);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == ZoneDurationsSection);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == ZoneDurationsSection);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == ZoneDurationsSection ?
            40 :
            self.tableView.rowHeight);
}

- (void)addZoneClicked:(id)sender
{
    NSLog(@"TODO: Handle this case");
}

- (void) reloadZoneDurationsSection
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger)ZoneDurationsSection] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)editZonesClicked:(id)sender
{
    if (self.tableView.editing)
    {
        [self.editZonesButton setTitle:@"Delete or Move Zones" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
        
        // TODO Save the new zone durations with self.dataSender
    }
    else
    {
        [self.editZonesButton setTitle:@"Done Editing" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
        
        if (self.tempEditingZones == nil)
        {
            self.tempEditingZones = [NSMutableArray array];
        }
        
        for(ZoneDuration *zoneDuration in self.tempEditingZones)
        {
            [zoneDuration release];
        }
        
        [self.tempEditingZones removeAllObjects];

        for(ZoneDuration *zoneDuration in self.watering.zoneDurations)
        {
            ZoneDuration *tempZoneDuration = [[ZoneDuration alloc] init];
            [tempZoneDuration copyDataFromZoneDuration:zoneDuration];
            [self.tempEditingZones addObject:tempZoneDuration];
        }
    }
    
    [self performSelector:@selector(reloadZoneDurationsSection) withObject:self afterDelay:0.2];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == ZoneDurationsSection)
    {
        if(self.editZonesButton == nil)
        {
            self.editZonesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.editZonesButton setTitle:@"Delete or Move Zones" forState:UIControlStateNormal];
            [self.editZonesButton setFrame:CGRectMake(60, 3, 235, 40)];
            [self.editZonesButton setTitleColor:[[UIColor alloc] initWithRed:0.3 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
            [self.editZonesButton addTarget:self action:@selector(editZonesClicked:) forControlEvents:UIControlEventTouchUpInside];

            self.editZonesHeader  = [[UIView alloc] init];
            [self.editZonesHeader addSubview:self.editZonesButton];
        }

        return self.editZonesHeader;
    }
    else
    {
        return nil;
    }

}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == ZoneDurationsSection)
    {
        UIView *footerView  = [[UIView alloc] init];

        if(self.tableView.editing)
        {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Add new zone" forState:UIControlStateNormal];
        [button setFrame:CGRectMake(60, 3, 235, 35)];
        [button setTitleColor:[[UIColor alloc] initWithRed:0 green:0.4 blue:0 alpha:1] forState:UIControlStateNormal];
        //[button addTarget:self action:@selector(addZoneClicked:)];
        [button addTarget:self action:@selector(addZoneClicked:) forControlEvents:UIControlEventTouchUpInside];

        [footerView addSubview:button];
        }
        return footerView;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == ZoneDurationsSection ? 45 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
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

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    if (self.tableView.editing)
        [self editZonesClicked:self];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath != nil)
    {
        [[self.tempEditingZones objectAtIndex:indexPath.row] release];
        [self.tempEditingZones removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.tempEditingZones exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger)ZoneDurationsSection] withRowAnimation:UITableViewRowAnimationFade];
}

@end