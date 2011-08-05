#import <Foundation/Foundation.h>

@interface Utils : NSObject 
{
}

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scale:(UIImage *)image toHeight:(CGFloat)height;

@end
