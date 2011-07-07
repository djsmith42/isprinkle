#import <UIKit/UIKit.h>
#import "RateView.h"

@class iSprinkleDoc;

@interface EditWateringViewController : UIViewController<UITextFieldDelegate, RateViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    iSprinkleDoc *_bugDoc;
    UITextField *_titleField;
    UIImageView *_imageView;
    RateView *_rateView;
    UIImagePickerController *_picker;
}

@property (retain) iSprinkleDoc *wateringDoc;
@property (retain) IBOutlet UITextField *titleField;
@property (retain) IBOutlet UIImageView *imageView;
@property (retain) IBOutlet RateView *rateView;
@property (retain) UIImagePickerController *picker;

- (IBAction)titleFieldValueChanged:(id)sender;
- (IBAction)addPictureTapped:(id)sender;

@end
