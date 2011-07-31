#import "iSprinkleAppDelegate.h"
#import "RootViewController.h"
#import "Settings.h"

@implementation iSprinkleAppDelegate

@synthesize window               = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    settingsViewController = nil;
    
    if ([[Settings hostName] length] == 0)
    {
        [self settingsButtonClicked];
    }
    
    return YES;
}

- (void)dealloc
{
    [_window               release];
    [_navigationController release];
    [settingsViewController release];
    [super dealloc];
}

- (IBAction) settingsButtonClicked
{
    if (settingsViewController == nil)
    {
        settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
        settingsViewController.navigationController = self.navigationController;
    }

    [self.navigationController presentModalViewController:settingsViewController animated:YES];
    [settingsViewController populateDisplay];
}

// - (void)applicationWillResignActive:(UIApplication *)application    {}
// - (void)applicationDidEnterBackground:(UIApplication *)application  {}
// - (void)applicationWillEnterForeground:(UIApplication *)application {}
// - (void)applicationDidBecomeActive:(UIApplication *)application     {}
// - (void)applicationWillTerminate:(UIApplication *)application       {}

@end