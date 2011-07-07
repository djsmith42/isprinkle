#import "RootViewController.h"
#import "iSprinkleDoc.h"
#import "iSprinkleData.h"

@implementation RootViewController

@synthesize waterings = _waterings;

static const NSInteger SectionCount    = 2;
static const NSInteger HeaderSection   = 0;
static const NSInteger WateringSection = 1;

// In the header section:
static const NSInteger StatusRow = 0;
static const NSInteger TimeRow   = 1;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"iSprinkle";
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"shouldAutorotateToInterfaceOrientation(%d)", interfaceOrientation);
    return YES;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection(%d)", section);
    if (section == HeaderSection)
        return 2;
    else if (section == WateringSection)
        return _waterings.count;
    else
        return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath: row: %d, section: %d", indexPath.row, indexPath.section);
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == WateringSection)
    {
        static NSString *WateringCellIdentifier = @"WateringCell";
        cell = [tableView dequeueReusableCellWithIdentifier:WateringCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WateringCellIdentifier] autorelease];
        }
        // Configure the cell.
        iSprinkleDoc *doc = [_waterings objectAtIndex:indexPath.row];
        cell.textLabel.text = doc.data.title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = doc.thumbImage;
    }
    else if (indexPath.section == HeaderSection)
    {
        if (indexPath.row == 0)
        {
            static NSString *StatusCellIdentifier = @"StatusCell";
            cell = [tableView dequeueReusableCellWithIdentifier:StatusCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:StatusCellIdentifier] autorelease];
            }

            cell.textLabel.text = @"iSprinkle status";
            cell.detailTextLabel.text = @"Idle";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 1)
        {
            static NSString *TimeCellIdentifier = @"TimeCell";
            cell = [tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TimeCellIdentifier] autorelease];
            }
            cell.textLabel.text = @"Current time";
            cell.detailTextLabel.text = @"July 6, 10:22 PM";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
    [_waterings release];
    _waterings = nil;
}

@end
