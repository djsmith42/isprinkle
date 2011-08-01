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
@synthesize zoneActionSheet;
@synthesize zonePicker;
@synthesize minutesPicker;
@synthesize minutesActionSheet;
@synthesize clickedZoneDurationNumber;
@synthesize editZoneDurationViewController;
@synthesize editingZoneDuration;
@synthesize status;

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
    self.title = @"Edit Watering";
    
    // To catch navigation events so we can commit changes to zone durations
    self.navigationController.delegate = self;
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

- (void)navigateToZoneDuration:(ZoneDuration*)zoneDuration
{
    if (self.editZoneDurationViewController == nil)
    {
        self.editZoneDurationViewController = [[[EditZoneDurationViewController alloc] initWithNibName:@"EditZoneDurationViewController" bundle:[NSBundle mainBundle]] autorelease];
    }

    self.editZoneDurationViewController.status  = self.status;
    self.editZoneDurationViewController.zone    = zoneDuration.zone;
    self.editZoneDurationViewController.minutes = zoneDuration.minutes;
    self.editingZoneDuration = YES; // so we know when the user comes back to this screen (and we can send the changes to the device)

    [self.navigationController pushViewController:self.editZoneDurationViewController animated:YES];
}

#pragma mark - UITableView Methods

- (void) reloadZoneDurationsSection
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger)ZoneDurationsSection] withRowAnimation:UITableViewRowAnimationNone];
}

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
        return (self.tableView.editing == YES ?
                self.tempEditingZones.count + 1 : // Extra row for the "Add" button at the bottom
                self.watering.zoneDurations.count);
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

- (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void) updateCellImage:(UITableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == ZoneDurationsSection)
    {
        UIImage *image = [UIImage imageNamed:@"GrayLight.png"];
        if([self.status.activeWatering.uuid isEqualToString:self.watering.uuid] && self.status.activeIndex == indexPath.row)
            image = [UIImage imageNamed:@"GreenLight.png"];

        CGSize imageSize = [self.tableView rectForRowAtIndexPath:indexPath].size;
        imageSize.height *= 0.66;
        imageSize.width = imageSize.height;

        image = [self scale:image toSize:imageSize];

        cell.imageView.image = image;
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
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
        static NSString *AddCellIdentifier = @"AddZoneDurationCell";
        
        if(self.tableView.editing && indexPath.row == self.tempEditingZones.count) // Create the "Add" row at the bottom of the list
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier] autorelease];
            }
            
            cell.textLabel.text = @"Add zone to water";
        }
        else
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            }
            
            ZoneDuration *zoneDuration = nil;
            if(self.tableView.editing == YES)
                zoneDuration = [self.tempEditingZones objectAtIndex:indexPath.row];
            else
                zoneDuration = [self.watering.zoneDurations objectAtIndex:indexPath.row];

            cell.textLabel.text = [self.status prettyZoneName:zoneDuration.zone];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d minutes", zoneDuration.minutes];
            [self updateCellImage:cell];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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
    else if (actionSheet == self.zoneActionSheet)
    {
        NSInteger newZone = [self.zonePicker selectedRowInComponent:0] + 1;
        ZoneDuration *newZoneDuration = [[ZoneDuration alloc] init];
        newZoneDuration.zone    = newZone;
        newZoneDuration.minutes = 10;
        [self.tempEditingZones addObject:newZoneDuration];
        [newZoneDuration release];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.tempEditingZones.count-1 inSection:ZoneDurationsSection]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (actionSheet == self.minutesActionSheet)
    {
        NSInteger newMinutes = [self.minutesPicker selectedRowInComponent:0] + 1;
        NSLog(@"New minutes: %d", newMinutes);
        ZoneDuration *zoneDuration = [self.watering.zoneDurations objectAtIndex:self.clickedZoneDurationNumber];
        zoneDuration.minutes = newMinutes;
        [self reloadZoneDurationsSection];
        [self.dataSender updateWatering:self.watering];
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

- (void) _showZonePicker
{
    //[ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow] data:[NSArray arrayWithObjects:@"foo",@"bar",@"baz",nil] selectedIndex:1 target:self action:@selector(periodWasSelected:) title:@"Pick a foo!"];

    // TODO Get the zone count from the device (not yet implemented)

    if (self.zonePicker == nil)
    {
        CGRect pickerFrame = CGRectMake(0, 100, 0, 0);
        self.zonePicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.zonePicker.dataSource = self;
        self.zonePicker.delegate   = self;
        self.zonePicker.showsSelectionIndicator = YES;
    }

    if (self.zoneActionSheet == nil)
    {
        self.zoneActionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Which zone?"
                                  delegate:self
                                  cancelButtonTitle:nil 
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Done", nil];
        [self.zoneActionSheet addSubview:self.zonePicker];
    }

    [self.zonePicker reloadAllComponents];
    [self.zonePicker selectRow:(self.watering.periodDays-1) inComponent:0 animated:YES];
    [self.zoneActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.zoneActionSheet setBounds:CGRectMake(0,0,320, 520)];
}

- (void) _showMinutesPicker:(int)withSelectedMinutes
{
    //[ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow] data:[NSArray arrayWithObjects:@"foo",@"bar",@"baz",nil] selectedIndex:1 target:self action:@selector(periodWasSelected:) title:@"Pick a foo!"];
    
    if (self.minutesPicker == nil)
    {
        CGRect pickerFrame = CGRectMake(0, 100, 0, 0);
        self.minutesPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.minutesPicker.dataSource = self;
        self.minutesPicker.delegate   = self;
        self.minutesPicker.showsSelectionIndicator = YES;
    }

    if (self.minutesActionSheet == nil)
    {
        self.minutesActionSheet = [[UIActionSheet alloc]
                                initWithTitle:@"How long to water this zone?"
                                delegate:self
                                cancelButtonTitle:nil 
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Done", nil];
        [self.minutesActionSheet addSubview:self.minutesPicker];
    }

    [self.minutesPicker reloadAllComponents];
    [self.minutesPicker selectRow:(withSelectedMinutes-1) inComponent:0 animated:YES];
    [self.minutesActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.minutesActionSheet setBounds:CGRectMake(0,0,320, 520)];
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
                return;
            }
        }
        else if(self.watering.scheduleType == EveryNDays)
        {
            if (indexPath.row == PeriodRow)
            {
                [self _showPeriodPicker];
                return;
            }
        }

        if (indexPath.row == StartTimeRow)
        {
            [self _showStartTimePicker];
        }
    }
    else if (indexPath.section == ZoneDurationsSection)
    {
        ZoneDuration *zoneDuration = nil;
        if (self.tableView.editing)
        {
            if(indexPath.row < self.tempEditingZones.count)
                zoneDuration = [self.tempEditingZones objectAtIndex:indexPath.row];
        }
        else
        {
            if(indexPath.row < self.watering.zoneDurations.count)
                zoneDuration = [self.watering.zoneDurations objectAtIndex:indexPath.row];
        }
        
        if (zoneDuration != nil)
            [self navigateToZoneDuration:zoneDuration];

    }
    else if (indexPath.section == ScheduleTypeSection)
    {
        NSLog(@"This does not work -- need to fix it");
        //self.watering.scheduleType = indexPath.row;
        //[self.dataSender updateWatering:self.watering];
        //[self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == ZoneDurationsSection);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Allow the zone durations to move, but not the last one (it's the "Add" button)
    return (indexPath.section == ZoneDurationsSection && indexPath.row < self.tempEditingZones.count);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == ZoneDurationsSection);
}

- (void)addZoneClicked:(id)sender
{
    NSLog(@"TODO: Handle this case");
}


- (void)editZonesClicked:(id)sender
{
    if (self.tableView.editing)
    {
        [self.editZonesButton setTitle:@"Edit Zones" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
        [self.watering.zoneDurations removeAllObjects];
        for(ZoneDuration *zoneDuration in self.tempEditingZones)
            [self.watering.zoneDurations addObject:zoneDuration];
        [self.dataSender updateWatering:self.watering];
    }
    else
    {
        [self.editZonesButton setTitle:@"Done Editing" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];

        if (self.tempEditingZones == nil)
        {
            self.tempEditingZones = [NSMutableArray array];
        }

        [self.tempEditingZones removeAllObjects];

        for(ZoneDuration *zoneDuration in self.watering.zoneDurations)
        {
            ZoneDuration *tempZoneDuration = [[ZoneDuration alloc] init];
            [tempZoneDuration copyDataFromZoneDuration:zoneDuration];
            [self.tempEditingZones addObject:tempZoneDuration];
            [tempZoneDuration release];
        }
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.tempEditingZones.count-1 inSection:ZoneDurationsSection]]
                              withRowAnimation:UITableViewRowAnimationFade];
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
            [self.editZonesButton setTitle:@"Edit Zones" forState:UIControlStateNormal];
            [self.editZonesButton setFrame:CGRectMake(40, 3, 245, 40)];
            [self.editZonesButton setTitleColor:[UIColor colorWithRed:0.3 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == ZoneDurationsSection)
    {
        return 45; // gives room for the edit button
    }
    else if(section == ScheduleTypeSection)
    {
        return 25;
    }
    else
    {
        return 0;
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
    if (self.periodPicker == pickerView)
    {
        return 50;
    }
    else if (self.zonePicker == pickerView)
    {
        return self.status.zoneCount;
    }
    else if (self.minutesPicker == pickerView)
    {
        return 120;
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == self.periodPicker)
    {
        if(row == 0)
            return @"Every day";
        else
            return [NSString stringWithFormat:@"Every %d days", (row+1)];
    }
    else if (pickerView == self.zonePicker)
    {
        return [self.status prettyZoneName:row+1];
    }
    else if (pickerView == self.minutesPicker)
    {
        if(row == 0)
            return @"1 minute";
        else
            return [NSString stringWithFormat:@"%d minutes", row+1];
    }
    else
    {
        return @"Error dude!";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Ignore
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    if (self.tableView.editing)
        [self editZonesClicked:self];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath != nil)
    {
        [self.tempEditingZones removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        [self _showZonePicker];
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == ZoneDurationsSection, @"The only editable section is the ZoneDurationSection");

    if (indexPath.row == self.tempEditingZones.count)
    {
        return UITableViewCellEditingStyleInsert; // The "Add" button at the bottom of the table
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.row >= self.tempEditingZones.count || destinationIndexPath.row >= self.tempEditingZones.count)
        return;

    [self.tempEditingZones exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController == self && self.editingZoneDuration)
    {
        self.editingZoneDuration = NO;
        NSLog(@"Back from the zone duration screen");

        ZoneDuration *zoneDuration = nil;
        NSInteger index = self.editZoneDurationViewController.zoneDurationIndex;
        if(self.tableView.editing)
        {
            if (index < self.tempEditingZones.count)
                zoneDuration = [self.tempEditingZones objectAtIndex:index];
        }
        else
        {
            if (index < self.watering.zoneDurations.count)
                zoneDuration = [self.watering.zoneDurations objectAtIndex:index];
        }
        
        if (zoneDuration != nil)
        {
            zoneDuration.minutes = self.editZoneDurationViewController.minutes;
            zoneDuration.zone    = self.editZoneDurationViewController.zone;

            if (self.tableView.editing == NO)
            {
                [self.dataSender updateWatering:self.watering];
            }
        }
        else
        {        
            NSLog(@"Woops, zone durations appear to have changed out from under the user while editing. Not updating.");
        }
        
        [self.tableView reloadData];
    }
}

- (void) updateWateringDisplay
{
    for (UITableViewCell *cell in [self.tableView visibleCells])
    {
        [self updateCellImage:cell];
        [cell setNeedsLayout];
    }
}

@end