/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>


@interface DragView : UIImageView <UIGestureRecognizerDelegate>
{
	CGFloat tx; // x位移
	CGFloat ty; // y位移
	CGFloat scale; // 縮放率
	CGFloat theta; // 旋轉角度
}
@end
