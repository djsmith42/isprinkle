#import <Foundation/Foundation.h>

@class iSprinkleData;

@interface iSprinkleDoc : NSObject {
    iSprinkleData *_data;
    UIImage *_thumbImage;
    UIImage *_fullImage;
}

@property (retain) iSprinkleData *data;
@property (retain) UIImage *thumbImage;
@property (retain) UIImage *fullImage;

- (id)initWithTitle:(NSString*)title rating:(float)rating thumbImage:(UIImage *)thumbImage fullImage:(UIImage *)fullImage;

@end
