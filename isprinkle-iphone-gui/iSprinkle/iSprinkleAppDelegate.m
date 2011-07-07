#import "Watering.h"
#import "iSprinkleAppDelegate.h"
#import "RootViewController.h"

@implementation iSprinkleAppDelegate

@synthesize window               = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup fake waterings (FIXME: We'll need to download these from the server)
    Watering *watering1 = [[Watering alloc] initWithName:@"Watering 1"];
    Watering *watering2 = [[Watering alloc] initWithName:@"Watering 2"];
    Watering *watering3 = [[Watering alloc] initWithName:@"Watering 3"];

    NSMutableArray *waterings = [NSMutableArray arrayWithObjects:watering1, watering2, watering3, nil];
    
    RootViewController *rootController = (RootViewController *) [self.navigationController.viewControllers objectAtIndex:0];
    
    rootController.waterings = waterings;
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

// - (void)applicationWillResignActive:(UIApplication *)application    {}
// - (void)applicationDidEnterBackground:(UIApplication *)application  {}
// - (void)applicationWillEnterForeground:(UIApplication *)application {}
// - (void)applicationDidBecomeActive:(UIApplication *)application     {}
// - (void)applicationWillTerminate:(UIApplication *)application       {}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end