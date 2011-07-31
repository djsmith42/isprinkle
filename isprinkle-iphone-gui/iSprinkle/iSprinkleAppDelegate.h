#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface iSprinkleAppDelegate : NSObject <UIApplicationDelegate>
{
    SettingsViewController *settingsViewController;
}

-(IBAction) settingsButtonClicked;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
