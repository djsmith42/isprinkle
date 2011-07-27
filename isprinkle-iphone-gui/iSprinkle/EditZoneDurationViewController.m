#import "EditZoneDurationViewController.h"
#import "ActionSheetPicker.h"

@implementation EditZoneDurationViewController
@synthesize zone;
@synthesize minutes;
@synthesize zoneDurationIndex;
@synthesize tableView;

static const NSInteger RowCount    = 2;
static const NSInteger ZoneRow     = 0;
static const NSInteger DurationRow = 1;

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

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return RowCount;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if(indexPath.row == ZoneRow)
    {
        cell.textLabel.text = @"Zone";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.zone];
    }
    else if(indexPath.row == DurationRow)
    {
        cell.textLabel.text = @"Duration";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d minute%@", self.minutes, (self.minutes == 1 ? @"" : @"s")];
    }

    return cell;
}

- (void)zoneWasSelected:(NSNumber*)z
{
    self.zone = ([z integerValue]+1);
    [self.tableView reloadData];
}

- (void)durationWasSelected:(NSNumber*)m

{
    self.minutes = ([m integerValue]+1);
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == ZoneRow)
    {
        NSMutableArray *choices = [[NSMutableArray alloc] init];
        for(int i=0; i<16; i++) // TODO Get the zone count from the device
        {
            [choices addObject:[NSString stringWithFormat:@"Zone %d", i+1]];
        }

        [ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow]
                                                  data:choices
                                         selectedIndex:(self.zone-1)
                                                target:self
                                                action:@selector(zoneWasSelected:)
                                                 title:@"Which zone to water?"];
        [choices release];
    }
    else if(indexPath.row == DurationRow)
    {
        NSMutableArray *choices = [[NSMutableArray alloc] init];
        for(int i=0; i<120; i++)
        {
            [choices addObject:[NSString stringWithFormat:@"%d minute%@", i+1, i+1 == 1 ? @"" : @"s"]];
        }
        
        [ActionSheetPicker displayActionPickerWithView:[[UIApplication sharedApplication] keyWindow]
                                                  data:choices
                                         selectedIndex:(self.minutes-1)
                                                target:self
                                                action:@selector(durationWasSelected:)
                                                 title:@"How long to water this zone?"];
        [choices release];
    }
}

@end
