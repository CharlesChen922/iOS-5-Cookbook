/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>

// 解決從PNG格式建立CI Image JPEG格式的臭蟲
CIImage *ciImageFromPNG(NSString *pngFileName);

@interface UIImage (Utilities)

// 取出圖像裡的一部分
- (UIImage *) subImageWithBounds:(CGRect) rect;

// 從CIImage建立UIImage，這是個暫時解法
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;
@end
