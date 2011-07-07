#import <Foundation/Foundation.h>

@class iSprinkleData;

@interface Watering : NSObject {
    NSString *_wateringName;
}

@property (retain) NSString *wateringName;

- (id)initWithName:(NSString*)name;

@end
