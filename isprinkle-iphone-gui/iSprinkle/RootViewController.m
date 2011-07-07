#import "RootViewController.h"
#import "Watering.h"

@implementation RootViewController

@synthesize waterings = _waterings;

static const NSInteger SectionCount    = 3;
static const NSInteger HeaderSection   = 0;
static const NSInteger WateringSection = 1;
static const NSInteger SetupSection    = 2;

// In the header section:
static const NSInteger HeaderSectionRows = 2;
static const NSInteger StatusRow = 0;
static const NSInteger TimeRow   = 1;

// In the setup section:
static const NSInteger SetupSectionRows  = 2;
static const NSInteger SetupDeferralRow  = 0;
static const NSInteger SetupZoneNamesRow = 1;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Downloading crap");
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.42.42.11:8080/status"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];

    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
        NSLog(@"Fail!");
    }
    
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
        return HeaderSectionRows;
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
        Watering *doc = [_waterings objectAtIndex:indexPath.row];
        cell.textLabel.text = doc.wateringName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"waterdrop.png"];
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
            cell.detailTextLabel.text = @"Loading...";
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
            cell.detailTextLabel.text = @"None";
            cell.accessoryType = UITableViewCellAccessoryNone;
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


// TESTING

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [receivedData appendData:data];
    NSString *s = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    NSLog(@"Got data from web server: %@", s);
    // TODO Somehow update the view
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Once this method is invoked, "responseData" contains the complete result
}

@end
