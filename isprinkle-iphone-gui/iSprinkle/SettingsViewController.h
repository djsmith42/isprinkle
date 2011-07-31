#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    UINavigationController *navigationController;
    UITextField *hostNameTextField;
}

-(IBAction) doneButtonClicked;
-(void) populateDisplay;

@property (retain) UINavigationController *navigationController;
@property (retain) IBOutlet UITextField *hostNameTextField;

@end