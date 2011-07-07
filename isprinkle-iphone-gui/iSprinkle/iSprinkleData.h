#import <Foundation/Foundation.h>


@interface iSprinkleData : NSObject {
    NSString *_title;
    float _rating;
}

@property (copy) NSString *title;
@property float rating;

- (id)initWithTitle:(NSString*)title rating:(float)rating;

@end
