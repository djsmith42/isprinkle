#import "iSprinkleAppDelegate.h"
#import "RootViewController.h"

@implementation iSprinkleAppDelegate

@synthesize window               = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

// - (void)applicationWillResignActive:(UIApplication *)application    {}
// - (void)applicationDidEnterBackground:(UIApplication *)application  {}
// - (void)applicationWillEnterForeground:(UIApplication *)application {}
// - (void)applicationDidBecomeActive:(UIApplication *)application     {}
// - (void)applicationWillTerminate:(UIApplication *)application       {}

@end