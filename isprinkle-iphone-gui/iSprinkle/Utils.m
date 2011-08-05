#import "Utils.h"


@implementation Utils

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)scale:(UIImage *)image toHeight:(CGFloat)height
{
    CGFloat scale = height / image.size.height;
    CGSize imageSize = image.size;
    imageSize.height *= scale;
    imageSize.width *= scale;
    return [self scale:image toSize:imageSize];
}

@end
