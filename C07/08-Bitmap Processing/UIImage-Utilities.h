/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>

// 解決從PNG格式建立CI Image JPEG格式的臭蟲
CIImage *ciImageFromPNG(NSString *pngFileName);

// RGBA offsets
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w);

@interface UIImage (Utilities)
// 取出圖像裡的一部分
- (UIImage *) subImageWithBounds:(CGRect) rect;

// Return a bitmap representation of the image
- (UInt8 *) createBitmap;

// Perform a basic Canny detection
- (UIImage *) convolveImageWithEdgeDetection;

// 從CIImage建立UIImage，這是個暫時解法
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;

// Create an image from a bitmap
+ (UIImage *) imageWithBits: (UInt8 *) bits withSize: (CGSize) size;
@end
