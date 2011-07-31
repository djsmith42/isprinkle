#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>
{
    UINavigationController *navigationController;
    UITextField *hostNameTextField;
    UIActivityIndicatorView *activityIndicator;
    UILabel *connectionTestLabel;
    BOOL closeOnSuccesfulTest;
}

-(IBAction) doneButtonClicked;
-(IBAction) hostNameTextFieldChanged;
-(void) populateDisplay;

@property (retain) UINavigationController *navigationController;
@property (retain) IBOutlet UITextField *hostNameTextField;
@property (retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain) IBOutlet UILabel *connectionTestLabel;

@end